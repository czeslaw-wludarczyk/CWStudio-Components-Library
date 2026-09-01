unit CWSInteractiveUserTheme;

//////////////////////////////////////////////////////////////////////////
//                                                                      //
//  Wykrywanie motywu (jasny/ciemny) ZALOGOWANEGO uzytkownika, nawet    //
//  gdy proces dziala na koncie NT AUTHORITY\SYSTEM (np. uruchomiony    //
//  przez ServiceUI.exe z Intune / MDT).                                //
//                                                                      //
//  Zmiany wzgledem wersji pierwotnej:                                  //
//                                                                      //
//  1. Ustalanie sesji uzytkownika w trzech krokach zamiast jednego:    //
//       a) ProcessIdToSessionId  - sesja WLASNEGO procesu; pod         //
//          ServiceUI to juz jest sesja uzytkownika i jest to           //
//          najpewniejsze zrodlo,                                       //
//       b) WTSGetActiveConsoleSessionId - sesja konsoli fizycznej,     //
//       c) WTSEnumerateSessions - pierwsza sesja w stanie WTSActive    //
//          (ratuje przypadek RDP / odlaczonej konsoli).                //
//     Pierwotnie uzywany byl wylacznie wariant (b), ktory zwraca 0     //
//     lub $FFFFFFFF przy odlaczonej konsoli i w scenariuszach RDP.     //
//                                                                      //
//  2. Zapasowa sciezka ustalania SID bez przywileju SE_TCB_NAME:       //
//     WTSQuerySessionInformation (nazwa uzytkownika i domeny) +        //
//     LookupAccountName.                                               //
//                                                                      //
//  3. Watek obserwatora startuje przez inherited Create(False), a nie  //
//     przez Create(True) + Start. Ten drugi wariant rzuca EThread      //
//     'Cannot call Start on a running or suspended thread' w nowszych  //
//     wersjach RTL. Pola ustawiamy PRZED inherited - pamiec instancji  //
//     jest juz wyzerowana przez NewInstance, wiec Execute nigdy nie    //
//     zobaczy niezainicjowanych wartosci.                              //
//                                                                      //
//  4. Logowanie diagnostyczne do %TEMP%\CWSTheme.log - wlaczane        //
//     zmienna ThemeLogEnabled lub przelacznikiem /themelog.            //
//     Pod SYSTEM sciezka to C:\Windows\Temp.                           //
//                                                                      //
//  UWAGA co do uzycia: motyw inicjalizuj w FormShow, NIE w FormCreate. //
//  W FormCreate zmienna globalna formularza jest jeszcze nil, a okno   //
//  nie ma uchwytu - wywolanie ApplyFluentTheme w tym momencie konczy   //
//  sie naruszeniem ochrony pamieci.                                    //
//                                                                      //
//    FormCreate:  RegisterThemeChange(ApplyTheme);                     //
//    FormShow:    StartFollowingUserTheme;                             //
//                 ApplyTheme;   // jawnie - nie polegaj na callbacku   //
//    FormDestroy: StopFollowingUserTheme;                              //
//                 UnregisterThemeChange(ApplyTheme);                   //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

interface

/// Ustawia motyw wg ustawien zalogowanego uzytkownika i uruchamia
/// obserwacje zmian. Bezpieczne do wielokrotnego wywolania.
/// Wolaj z FormShow, nie z FormCreate.
procedure StartFollowingUserTheme;

/// Zatrzymuje obserwacje. Wywolaj w FormDestroy (i tak wola to finalization).
procedure StopFollowingUserTheme;

/// True gdy proces dziala na koncie NT AUTHORITY\SYSTEM (S-1-5-18).
function RunningAsLocalSystem: Boolean;

/// SID uzytkownika aktywnej sesji interaktywnej, np. 'S-1-5-21-...-1001'.
function TryGetInteractiveUserSid(out ASid: string): Boolean;

/// Odczyt AppsUseLightTheme z galezi HKEY_USERS\<ASid>.
/// Result = False oznacza brak klucza/wartosci (a nie motyw jasny).
function TryGetDarkModeForSid(const ASid: string; out ADark: Boolean): Boolean;

/// Pelny zrzut stanu wykrywania - do diagnostyki na maszynie docelowej.
function ThemeDiagnostics: string;

var
  /// Wlacza zapis logu do %TEMP%\CWSTheme.log. Ustawiane takze przez
  /// przelacznik /themelog w wierszu polecen.
  ThemeLogEnabled: Boolean = False;

implementation

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.IOUtils,
  System.Win.Registry,
  CWSFluentColorsMulti;

const
  cPersonalizeKey =
    'Software\Microsoft\Windows\CurrentVersion\Themes\Personalize';
  cLocalSystemSid = 'S-1-5-18';
  cWtsApi32 = 'Wtsapi32.dll';
  cLogFileName = 'CWSTheme.log';

  // WTS_INFO_CLASS
  cWtsUserName = 5;
  cWtsDomainName = 7;

  WTS_CURRENT_SERVER_HANDLE = THandle(0);

{$Z4} // enumy 4-bajtowe, tak jak w naglowkach Windows
type
  TWtsConnectStateClass = (WTSActive, WTSConnected, WTSConnectQuery, WTSShadow,
    WTSDisconnected, WTSIdle, WTSListen, WTSReset, WTSDown, WTSInit);
{$Z1}

  PWtsSessionInfoW = ^TWtsSessionInfoW;

  TWtsSessionInfoW = record
    SessionId: DWORD;
    pWinStationName: PWideChar;
    State: TWtsConnectStateClass;
  end;

// Deklaracje jawne, zeby unit nie zalezal od wersji naglowkow RTL.
function WTSGetActiveConsoleSessionId: DWORD; stdcall;
  external kernel32 name 'WTSGetActiveConsoleSessionId';

function WTSQueryUserToken(ASessionId: ULONG; var APhToken: THandle): BOOL; stdcall;
  external cWtsApi32 name 'WTSQueryUserToken';

function WTSEnumerateSessionsW(AServer: THandle; AReserved, AVersion: DWORD;
  var APSessionInfo: PWtsSessionInfoW; var ACount: DWORD): BOOL; stdcall;
  external cWtsApi32 name 'WTSEnumerateSessionsW';

function WTSQuerySessionInformationW(AServer: THandle; ASessionId: DWORD;
  AInfoClass: Integer; var APBuffer: PWideChar; var ABytesReturned: DWORD): BOOL; stdcall;
  external cWtsApi32 name 'WTSQuerySessionInformationW';

procedure WTSFreeMemory(APMemory: Pointer); stdcall;
  external cWtsApi32 name 'WTSFreeMemory';

function ConvertSidToStringSidW(ASid: PSID; out AStringSid: PWideChar): BOOL; stdcall;
  external advapi32 name 'ConvertSidToStringSidW';

{ ------------------------------------------------------------------------ }
{ Logowanie diagnostyczne                                                  }
{ ------------------------------------------------------------------------ }

var
  GLogLock: TRTLCriticalSection;
  GLogReady: Boolean = False;

procedure ThemeLog(const AMessage: string); overload;
var
  logPath: string;
  stream: TFileStream;
  line: UTF8String;
begin
  if (not ThemeLogEnabled) or (not GLogReady) then
    Exit;

  try
    logPath := TPath.Combine(TPath.GetTempPath, cLogFileName);
    line := UTF8String(FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + '  ' +
      AMessage + sLineBreak);

    EnterCriticalSection(GLogLock);
    try
      if TFile.Exists(logPath) then
        stream := TFileStream.Create(logPath, fmOpenWrite or fmShareDenyNone)
      else
        stream := TFileStream.Create(logPath, fmCreate or fmShareDenyNone);
      try
        stream.Seek(0, soEnd);
        stream.WriteBuffer(PAnsiChar(line)^, Length(line));
      finally
        stream.Free;
      end;
    finally
      LeaveCriticalSection(GLogLock);
    end;
  except
    // Diagnostyka nie moze wywrocic aplikacji - swiadomie polykamy blad IO.
    on E: Exception do
      ;
  end;
end;

procedure ThemeLog(const AFormat: string; const AArgs: array of const); overload;
begin
  if ThemeLogEnabled and GLogReady then
    ThemeLog(Format(AFormat, AArgs));
end;

{ ------------------------------------------------------------------------ }
{ Pomocnicze - tokeny i SID                                                }
{ ------------------------------------------------------------------------ }

function TryGetTokenSidString(AToken: THandle; out ASid: string): Boolean;
var
  bufferSize: DWORD;
  buffer: TBytes;
  tokenUserInfo: PTokenUser;
  sidText: PWideChar;
begin
  Result := False;
  ASid := '';

  bufferSize := 0;
  GetTokenInformation(AToken, TokenUser, nil, 0, bufferSize);
  if bufferSize = 0 then
  begin
    ThemeLog('TryGetTokenSidString: GetTokenInformation (sonda) blad %d',
      [GetLastError]);
    Exit;
  end;

  SetLength(buffer, bufferSize);
  if not GetTokenInformation(AToken, TokenUser, @buffer[0], bufferSize, bufferSize) then
  begin
    ThemeLog('TryGetTokenSidString: GetTokenInformation blad %d', [GetLastError]);
    Exit;
  end;

  tokenUserInfo := PTokenUser(@buffer[0]);
  if tokenUserInfo.User.Sid = nil then
    Exit;

  if not ConvertSidToStringSidW(tokenUserInfo.User.Sid, sidText) then
  begin
    ThemeLog('TryGetTokenSidString: ConvertSidToStringSid blad %d', [GetLastError]);
    Exit;
  end;
  try
    ASid := string(sidText);
    Result := ASid <> '';
  finally
    LocalFree(HLOCAL(sidText));
  end;
end;

function RunningAsLocalSystem: Boolean;
var
  processToken: THandle;
  sid: string;
begin
  Result := False;
  if not OpenProcessToken(GetCurrentProcess, TOKEN_QUERY, processToken) then
    Exit;
  try
    Result := TryGetTokenSidString(processToken, sid) and
      SameText(sid, cLocalSystemSid);
  finally
    CloseHandle(processToken);
  end;
end;

function GetCurrentProcessSid: string;
var
  processToken: THandle;
begin
  Result := '';
  if OpenProcessToken(GetCurrentProcess, TOKEN_QUERY, processToken) then
  try
    TryGetTokenSidString(processToken, Result);
  finally
    CloseHandle(processToken);
  end;
end;

{ ------------------------------------------------------------------------ }
{ Ustalanie sesji uzytkownika - trzy niezalezne metody                     }
{ ------------------------------------------------------------------------ }

function IsUsableSessionId(ASessionId: DWORD): Boolean;
begin
  // Sesja 0 to sesja uslug (Session 0 Isolation) - nie ma tam uzytkownika.
  Result := (ASessionId <> 0) and (ASessionId <> DWORD(-1));
end;

function GetOwnSessionId: DWORD;
begin
  if not ProcessIdToSessionId(GetCurrentProcessId, Result) then
  begin
    ThemeLog('GetOwnSessionId: ProcessIdToSessionId blad %d', [GetLastError]);
    Result := DWORD(-1);
  end;
end;

function GetFirstActiveSessionId: DWORD;
var
  sessions: PWtsSessionInfoW;
  count: DWORD;
  i: Integer;
  entry: PWtsSessionInfoW;
  stationName: string;
begin
  Result := DWORD(-1);
  sessions := nil;
  count := 0;

  if not WTSEnumerateSessionsW(WTS_CURRENT_SERVER_HANDLE, 0, 1, sessions, count) then
  begin
    ThemeLog('GetFirstActiveSessionId: WTSEnumerateSessions blad %d', [GetLastError]);
    Exit;
  end;

  if sessions = nil then
    Exit;

  try
    for i := 0 to Integer(count) - 1 do
    begin
      entry := PWtsSessionInfoW(PByte(sessions) + i * SizeOf(TWtsSessionInfoW));
      if entry.pWinStationName <> nil then
        stationName := string(entry.pWinStationName)
      else
        stationName := '';
      ThemeLog('  sesja %d, stan %d, stacja "%s"',
        [entry.SessionId, Ord(entry.State), stationName]);
      if (entry.State = WTSActive) and IsUsableSessionId(entry.SessionId) then
      begin
        Result := entry.SessionId;
        Break;
      end;
    end;
  finally
    WTSFreeMemory(sessions);
  end;
end;

/// Zapasowa metoda: SID z nazwy konta uzytkownika sesji. Nie wymaga SE_TCB_NAME.
function TryGetSessionUserSidByName(ASessionId: DWORD; out ASid: string): Boolean;

  function QueryString(AInfoClass: Integer): string;
  var
    buffer: PWideChar;
    bytes: DWORD;
  begin
    Result := '';
    buffer := nil;
    bytes := 0;
    if WTSQuerySessionInformationW(WTS_CURRENT_SERVER_HANDLE, ASessionId,
      AInfoClass, buffer, bytes) then
    try
      if buffer <> nil then
        Result := string(buffer);
    finally
      WTSFreeMemory(buffer);
    end;
  end;

var
  userName, domainName, fullName: string;
  sidBuffer: TBytes;
  sidSize: DWORD;
  domainBuffer: array [0 .. 255] of Char;
  domainSize: DWORD;
  sidUse: SID_NAME_USE;
  sidText: PWideChar;
begin
  Result := False;
  ASid := '';

  if not IsUsableSessionId(ASessionId) then
    Exit;

  userName := QueryString(cWtsUserName);
  if userName = '' then
  begin
    ThemeLog('TryGetSessionUserSidByName: brak nazwy uzytkownika dla sesji %d',
      [ASessionId]);
    Exit;
  end;

  domainName := QueryString(cWtsDomainName);
  if domainName <> '' then
    fullName := domainName + '\' + userName
  else
    fullName := userName;

  sidSize := 0;
  domainSize := Length(domainBuffer);
  LookupAccountName(nil, PChar(fullName), nil, sidSize, domainBuffer,
    domainSize, sidUse);
  if sidSize = 0 then
  begin
    ThemeLog('TryGetSessionUserSidByName: LookupAccountName (sonda) blad %d',
      [GetLastError]);
    Exit;
  end;

  SetLength(sidBuffer, sidSize);
  domainSize := Length(domainBuffer);
  if not LookupAccountName(nil, PChar(fullName), PSID(@sidBuffer[0]), sidSize,
    domainBuffer, domainSize, sidUse) then
  begin
    ThemeLog('TryGetSessionUserSidByName: LookupAccountName blad %d', [GetLastError]);
    Exit;
  end;

  if not ConvertSidToStringSidW(PSID(@sidBuffer[0]), sidText) then
    Exit;
  try
    ASid := string(sidText);
    Result := ASid <> '';
    ThemeLog('TryGetSessionUserSidByName: %s -> %s', [fullName, ASid]);
  finally
    LocalFree(HLOCAL(sidText));
  end;
end;

function TryGetSidForSession(ASessionId: DWORD; out ASid: string): Boolean;
var
  userToken: THandle;
begin
  Result := False;
  ASid := '';

  if not IsUsableSessionId(ASessionId) then
    Exit;

  // Sciezka podstawowa - wymaga SE_TCB_NAME (ma je SYSTEM).
  if WTSQueryUserToken(ASessionId, userToken) then
  try
    Result := TryGetTokenSidString(userToken, ASid);
    if Result then
      ThemeLog('TryGetSidForSession: sesja %d -> %s (WTSQueryUserToken)',
        [ASessionId, ASid]);
  finally
    CloseHandle(userToken);
  end
  else
    ThemeLog('TryGetSidForSession: WTSQueryUserToken(%d) blad %d',
      [ASessionId, GetLastError]);

  // Sciezka zapasowa - bez SE_TCB_NAME.
  if not Result then
    Result := TryGetSessionUserSidByName(ASessionId, ASid);
end;

function TryGetInteractiveUserSid(out ASid: string): Boolean;
var
  sessionId: DWORD;
begin
  ASid := '';

  // 1. Sesja wlasnego procesu. Pod ServiceUI to juz sesja uzytkownika.
  sessionId := GetOwnSessionId;
  ThemeLog('TryGetInteractiveUserSid: sesja wlasna = %d', [sessionId]);
  if TryGetSidForSession(sessionId, ASid) then
    Exit(True);

  // 2. Sesja konsoli fizycznej.
  sessionId := WTSGetActiveConsoleSessionId;
  ThemeLog('TryGetInteractiveUserSid: sesja konsoli = %d', [sessionId]);
  if TryGetSidForSession(sessionId, ASid) then
    Exit(True);

  // 3. Pierwsza sesja w stanie WTSActive (RDP, odlaczona konsola).
  ThemeLog('TryGetInteractiveUserSid: enumeracja sesji');
  sessionId := GetFirstActiveSessionId;
  ThemeLog('TryGetInteractiveUserSid: pierwsza aktywna = %d', [sessionId]);
  if TryGetSidForSession(sessionId, ASid) then
    Exit(True);

  ThemeLog('TryGetInteractiveUserSid: nie udalo sie ustalic SID');
  Result := False;
end;

{ ------------------------------------------------------------------------ }
{ Odczyt motywu z galezi uzytkownika                                       }
{ ------------------------------------------------------------------------ }

function TryGetDarkModeForSid(const ASid: string; out ADark: Boolean): Boolean;
var
  reg: TRegistry;
  keyPath: string;
begin
  Result := False;
  ADark := False;
  if ASid = '' then
    Exit;

  keyPath := ASid + '\' + cPersonalizeKey;

  reg := TRegistry.Create(KEY_READ);
  try
    reg.RootKey := HKEY_USERS;
    if not reg.KeyExists(keyPath) then
    begin
      ThemeLog('TryGetDarkModeForSid: brak klucza HKU\%s ' +
        '(profil niezaladowany?)', [keyPath]);
      Exit;
    end;

    if reg.OpenKeyReadOnly(keyPath) then
    try
      if reg.ValueExists('AppsUseLightTheme') then
      begin
        ADark := reg.ReadInteger('AppsUseLightTheme') = 0;
        Result := True;
        ThemeLog('TryGetDarkModeForSid: AppsUseLightTheme=%d -> dark=%s',
          [Ord(not ADark), BoolToStr(ADark, True)]);
      end
      else
        ThemeLog('TryGetDarkModeForSid: brak wartosci AppsUseLightTheme');
    finally
      reg.CloseKey;
    end
    else
      ThemeLog('TryGetDarkModeForSid: OpenKeyReadOnly nieudane dla HKU\%s',
        [keyPath]);
  finally
    reg.Free;
  end;
end;

{ ------------------------------------------------------------------------ }
{ Watek obserwujacy zmiane motywu w galezi uzytkownika                     }
{ ------------------------------------------------------------------------ }

type
  TUserThemeWatchThread = class(TThread)
  strict private
    FSid: string;
    FKey: HKEY;
    FNotifyEvent: THandle;
    FStopEvent: THandle;
    procedure ApplyInMainThread;
  protected
    procedure Execute; override;
  public
    constructor Create(const ASid: string);
    destructor Destroy; override;
  end;

constructor TUserThemeWatchThread.Create(const ASid: string);
var
  status: Longint;
begin
  // Pola ustawiamy PRZED inherited Create. Pamiec instancji jest juz
  // wyzerowana przez NewInstance, a watek systemowy powstaje dopiero
  // w inherited - Execute nigdy nie zobaczy niezainicjowanych pol.
  // Dzieki temu nie wolamy Start, ktore po Create(True) rzuca EThread
  // 'Cannot call Start on a running or suspended thread'.
  FreeOnTerminate := False;
  FSid := ASid;
  FKey := 0;
  FNotifyEvent := CreateEvent(nil, True, False, nil);
  FStopEvent := CreateEvent(nil, True, False, nil);

  status := RegOpenKeyEx(HKEY_USERS, PChar(ASid + '\' + cPersonalizeKey), 0,
    KEY_READ or KEY_NOTIFY, FKey);
  if status <> ERROR_SUCCESS then
  begin
    ThemeLog('TUserThemeWatchThread: RegOpenKeyEx blad %d - obserwacja wylaczona',
      [status]);
    FKey := 0;
  end;

  inherited Create(False);
end;

destructor TUserThemeWatchThread.Destroy;
begin
  Terminate;
  if FStopEvent <> 0 then
    SetEvent(FStopEvent);

  TThread.RemoveQueuedEvents(Self);

  inherited Destroy; // czeka na zakonczenie Execute

  if FKey <> 0 then
    RegCloseKey(FKey);
  if FNotifyEvent <> 0 then
    CloseHandle(FNotifyEvent);
  if FStopEvent <> 0 then
    CloseHandle(FStopEvent);
end;

procedure TUserThemeWatchThread.ApplyInMainThread;
var
  dark: Boolean;
begin
  if TryGetDarkModeForSid(FSid, dark) then
  begin
    ThemeLog('Watcher: wykryto zmiane, dark=%s', [BoolToStr(dark, True)]);
    FluentSetDarkMode(dark);
  end;
end;

procedure TUserThemeWatchThread.Execute;
var
  waitHandles: array [0 .. 1] of THandle;
  waitResult: DWORD;
begin
  if (FKey = 0) or (FNotifyEvent = 0) or (FStopEvent = 0) then
    Exit;

  waitHandles[0] := FNotifyEvent;
  waitHandles[1] := FStopEvent;

  while not Terminated do
  begin
    ResetEvent(FNotifyEvent);

    if RegNotifyChangeKeyValue(FKey, False, REG_NOTIFY_CHANGE_LAST_SET,
      FNotifyEvent, True) <> ERROR_SUCCESS then
      Break;

    waitResult := WaitForMultipleObjects(2, @waitHandles[0], False, INFINITE);
    if (waitResult <> WAIT_OBJECT_0) or Terminated then
      Break;

    TThread.Queue(Self, ApplyInMainThread);
  end;
end;

{ ------------------------------------------------------------------------ }
{ API unitu                                                                }
{ ------------------------------------------------------------------------ }

var
  GWatcher: TUserThemeWatchThread = nil;

procedure StopFollowingUserTheme;
begin
  FreeAndNil(GWatcher);
end;

procedure StartFollowingUserTheme;
var
  sid: string;
  dark: Boolean;
begin
  StopFollowingUserTheme;

  ThemeLog('--- StartFollowingUserTheme, proces SID=%s, SYSTEM=%s ---',
    [GetCurrentProcessSid, BoolToStr(RunningAsLocalSystem, True)]);

  if TryGetInteractiveUserSid(sid) then
  begin
    if not TryGetDarkModeForSid(sid, dark) then
      dark := False; // brak wartosci = domyslnie jasny
    ThemeLog('StartFollowingUserTheme: FluentSetDarkMode(%s)',
      [BoolToStr(dark, True)]);
    FluentSetDarkMode(dark);
    GWatcher := TUserThemeWatchThread.Create(sid);
  end
  else
  begin
    ThemeLog('StartFollowingUserTheme: fallback na FluentApplySystemTheme (HKCU)');
    FluentApplySystemTheme;
  end;
end;

function ThemeDiagnostics: string;
var
  lines: TStringList;
  sid: string;
  dark: Boolean;
begin
  lines := TStringList.Create;
  try
    lines.Add('SID procesu:        ' + GetCurrentProcessSid);
    lines.Add('Dziala jako SYSTEM: ' + BoolToStr(RunningAsLocalSystem, True));
    lines.Add('Sesja procesu:      ' + IntToStr(GetOwnSessionId));
    lines.Add('Sesja konsoli:      ' + IntToStr(WTSGetActiveConsoleSessionId));
    lines.Add('Pierwsza aktywna:   ' + IntToStr(GetFirstActiveSessionId));

    if TryGetInteractiveUserSid(sid) then
    begin
      lines.Add('SID uzytkownika:    ' + sid);
      if TryGetDarkModeForSid(sid, dark) then
        lines.Add('Motyw ciemny:       ' + BoolToStr(dark, True))
      else
        lines.Add('Motyw ciemny:       BRAK WARTOSCI W REJESTRZE');
    end
    else
      lines.Add('SID uzytkownika:    NIE USTALONO');

    Result := lines.Text;
  finally
    lines.Free;
  end;
end;

function CommandLineHasThemeLog: Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 1 to ParamCount do
    if SameText(ParamStr(i), '/themelog') or SameText(ParamStr(i), '-themelog') then
      Exit(True);
end;

initialization
  InitializeCriticalSection(GLogLock);
  GLogReady := True;
  if CommandLineHasThemeLog then
    ThemeLogEnabled := True;

finalization
  StopFollowingUserTheme;
  GLogReady := False;
  DeleteCriticalSection(GLogLock);

end.
unit CWSInteractiveUserTheme;

//////////////////////////////////////////////////////////////////////////
//                                                                      //
//  Detects the theme (light/dark) of the LOGGED-ON user, even when the //
//  process runs under the NT AUTHORITY\SYSTEM account (e.g. started by //
//  ServiceUI.exe from Intune / MDT).                                   //
//                                                                      //
//  Changes compared to the original version:                           //
//                                                                      //
//  1. The user session is determined in three steps instead of one:    //
//       a) ProcessIdToSessionId  - the session of OUR OWN process;     //
//          under ServiceUI this already is the user session and it is  //
//          the most reliable source,                                   //
//       b) WTSGetActiveConsoleSessionId - the physical console session,//
//       c) WTSEnumerateSessions - the first session in the WTSActive   //
//          state (covers the RDP / disconnected console case).         //
//     Originally only variant (b) was used, which returns 0 or         //
//     $FFFFFFFF with a disconnected console and in RDP scenarios.      //
//                                                                      //
//  2. A fallback path for determining the SID without the SE_TCB_NAME  //
//     privilege: WTSQuerySessionInformation (user and domain name) +   //
//     LookupAccountName.                                               //
//                                                                      //
//  3. The watcher thread is started through inherited Create(False),   //
//     not through Create(True) + Start. The latter variant raises      //
//     EThread 'Cannot call Start on a running or suspended thread' in  //
//     newer RTL versions. The fields are set BEFORE inherited - the    //
//     instance memory is already zeroed by NewInstance, so Execute     //
//     never sees uninitialized values.                                 //
//                                                                      //
//  4. Diagnostic logging to %TEMP%\CWSTheme.log - enabled by the       //
//     ThemeLogEnabled variable or the /themelog switch.                //
//     Under SYSTEM the path is C:\Windows\Temp.                        //
//                                                                      //
//  NOTE on usage: initialize the theme in FormShow, NOT in FormCreate. //
//  In FormCreate the form's global variable is still nil and the window//
//  has no handle - calling ApplyFluentTheme at that point ends with an //
//  access violation.                                                   //
//                                                                      //
//    FormCreate:  RegisterThemeChange(ApplyTheme);                     //
//    FormShow:    StartFollowingUserTheme;                             //
//                 ApplyTheme;   // explicit - do not rely on callback  //
//    FormDestroy: StopFollowingUserTheme;                              //
//                 UnregisterThemeChange(ApplyTheme);                   //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

interface

/// Applies the theme according to the logged-on user's settings and starts
/// watching for changes. Safe to call multiple times.
/// Call it from FormShow, not from FormCreate.
procedure StartFollowingUserTheme;

/// Stops watching. Call it in FormDestroy (finalization calls it anyway).
procedure StopFollowingUserTheme;

/// True when the process runs under the NT AUTHORITY\SYSTEM account (S-1-5-18).
function RunningAsLocalSystem: Boolean;

/// SID of the user of the active interactive session, e.g. 'S-1-5-21-...-1001'.
function TryGetInteractiveUserSid(out ASid: string): Boolean;

/// Reads AppsUseLightTheme from the HKEY_USERS\<ASid> branch.
/// Result = False means the key/value is missing (not that the theme is light).
function TryGetDarkModeForSid(const ASid: string; out ADark: Boolean): Boolean;

/// A full dump of the detection state - for diagnostics on the target machine.
function ThemeDiagnostics: string;

var
  /// Enables writing the log to %TEMP%\CWSTheme.log. Also set by the
  /// /themelog command line switch.
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

{$Z4} // 4-byte enums, just like in the Windows headers
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

// Explicit declarations, so the unit does not depend on the RTL header version.
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
{ Diagnostic logging                                                       }
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
    // Diagnostics must not bring the application down - the IO error is swallowed on purpose.
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
    ThemeLog('TryGetTokenSidString: GetTokenInformation (probe) error %d',
      [GetLastError]);
    Exit;
  end;

  SetLength(buffer, bufferSize);
  if not GetTokenInformation(AToken, TokenUser, @buffer[0], bufferSize, bufferSize) then
  begin
    ThemeLog('TryGetTokenSidString: GetTokenInformation error %d', [GetLastError]);
    Exit;
  end;

  tokenUserInfo := PTokenUser(@buffer[0]);
  if tokenUserInfo.User.Sid = nil then
    Exit;

  if not ConvertSidToStringSidW(tokenUserInfo.User.Sid, sidText) then
  begin
    ThemeLog('TryGetTokenSidString: ConvertSidToStringSid error %d', [GetLastError]);
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
{ Determining the user session - three independent methods                 }
{ ------------------------------------------------------------------------ }

function IsUsableSessionId(ASessionId: DWORD): Boolean;
begin
  // Session 0 is the services session (Session 0 Isolation) - no user there.
  Result := (ASessionId <> 0) and (ASessionId <> DWORD(-1));
end;

function GetOwnSessionId: DWORD;
begin
  if not ProcessIdToSessionId(GetCurrentProcessId, Result) then
  begin
    ThemeLog('GetOwnSessionId: ProcessIdToSessionId error %d', [GetLastError]);
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
    ThemeLog('GetFirstActiveSessionId: WTSEnumerateSessions error %d', [GetLastError]);
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
      ThemeLog('  session %d, state %d, station "%s"',
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

/// Fallback method: the SID from the session user's account name. Does not require SE_TCB_NAME.
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
    ThemeLog('TryGetSessionUserSidByName: no user name for session %d',
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
    ThemeLog('TryGetSessionUserSidByName: LookupAccountName (probe) error %d',
      [GetLastError]);
    Exit;
  end;

  SetLength(sidBuffer, sidSize);
  domainSize := Length(domainBuffer);
  if not LookupAccountName(nil, PChar(fullName), PSID(@sidBuffer[0]), sidSize,
    domainBuffer, domainSize, sidUse) then
  begin
    ThemeLog('TryGetSessionUserSidByName: LookupAccountName error %d', [GetLastError]);
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
      ThemeLog('TryGetSidForSession: session %d -> %s (WTSQueryUserToken)',
        [ASessionId, ASid]);
  finally
    CloseHandle(userToken);
  end
  else
    ThemeLog('TryGetSidForSession: WTSQueryUserToken(%d) error %d',
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

  // 1. The session of our own process. Under ServiceUI this already is the user session.
  sessionId := GetOwnSessionId;
  ThemeLog('TryGetInteractiveUserSid: own session = %d', [sessionId]);
  if TryGetSidForSession(sessionId, ASid) then
    Exit(True);

  // 2. The physical console session.
  sessionId := WTSGetActiveConsoleSessionId;
  ThemeLog('TryGetInteractiveUserSid: console session = %d', [sessionId]);
  if TryGetSidForSession(sessionId, ASid) then
    Exit(True);

  // 3. The first session in the WTSActive state (RDP, disconnected console).
  ThemeLog('TryGetInteractiveUserSid: enumerating sessions');
  sessionId := GetFirstActiveSessionId;
  ThemeLog('TryGetInteractiveUserSid: first active = %d', [sessionId]);
  if TryGetSidForSession(sessionId, ASid) then
    Exit(True);

  ThemeLog('TryGetInteractiveUserSid: failed to determine the SID');
  Result := False;
end;

{ ------------------------------------------------------------------------ }
{ Reading the theme from the user's registry branch                        }
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
      ThemeLog('TryGetDarkModeForSid: no HKU\%s key ' +
        '(profile not loaded?)', [keyPath]);
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
        ThemeLog('TryGetDarkModeForSid: no AppsUseLightTheme value');
    finally
      reg.CloseKey;
    end
    else
      ThemeLog('TryGetDarkModeForSid: OpenKeyReadOnly failed for HKU\%s',
        [keyPath]);
  finally
    reg.Free;
  end;
end;

{ ------------------------------------------------------------------------ }
{ Thread watching for a theme change in the user's registry branch         }
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
  // The fields are set BEFORE inherited Create. The instance memory is already
  // zeroed by NewInstance, and the system thread is created only inside
  // inherited - Execute never sees uninitialized fields.
  // This way Start is never called, which after Create(True) raises EThread
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
    ThemeLog('TUserThemeWatchThread: RegOpenKeyEx error %d - watching disabled',
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
    ThemeLog('Watcher: change detected, dark=%s', [BoolToStr(dark, True)]);
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

  ThemeLog('--- StartFollowingUserTheme, process SID=%s, SYSTEM=%s ---',
    [GetCurrentProcessSid, BoolToStr(RunningAsLocalSystem, True)]);

  if TryGetInteractiveUserSid(sid) then
  begin
    if not TryGetDarkModeForSid(sid, dark) then
      dark := False; // no value = light by default
    ThemeLog('StartFollowingUserTheme: FluentSetDarkMode(%s)',
      [BoolToStr(dark, True)]);
    FluentSetDarkMode(dark);
    GWatcher := TUserThemeWatchThread.Create(sid);
  end
  else
  begin
    ThemeLog('StartFollowingUserTheme: falling back to FluentApplySystemTheme (HKCU)');
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
    lines.Add('Process SID:        ' + GetCurrentProcessSid);
    lines.Add('Running as SYSTEM:  ' + BoolToStr(RunningAsLocalSystem, True));
    lines.Add('Process session:    ' + IntToStr(GetOwnSessionId));
    lines.Add('Console session:    ' + IntToStr(WTSGetActiveConsoleSessionId));
    lines.Add('First active:       ' + IntToStr(GetFirstActiveSessionId));

    if TryGetInteractiveUserSid(sid) then
    begin
      lines.Add('User SID:           ' + sid);
      if TryGetDarkModeForSid(sid, dark) then
        lines.Add('Dark theme:         ' + BoolToStr(dark, True))
      else
        lines.Add('Dark theme:         NO VALUE IN THE REGISTRY');
    end
    else
      lines.Add('User SID:           NOT DETERMINED');

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
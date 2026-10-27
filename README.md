<div align="center">

# CWStudio Components Library

**Nowoczesne komponenty VCL w stylu Windows 11 / WinUI 3 dla Delphi**

*Modern Windows 11 / WinUI 3 styled VCL components for Delphi*

[![Version: 1.9.33](https://img.shields.io/badge/version-1.9.33-blue.svg)](CHANGELOG.md)
[![License: MIT](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)
[![Platform: VCL](https://img.shields.io/badge/platform-VCL%20%7C%20Delphi-red.svg)](#-wymagania-systemowe)
[![Windows 11](https://img.shields.io/badge/style-Windows%2011%20%7C%20WinUI%203-0078D4.svg)](#-wymagania-systemowe)
[![Donate: PayPal](https://img.shields.io/badge/donate-PayPal-00457C.svg?logo=paypal)](https://paypal.me/czeslaw80)

</div>

---

## 🇵🇱 Wersja polska

CWStudio to zestaw nowoczesnych, wysokiej jakości komponentów VCL dla środowiska Delphi, zaprojektowanych w celu nadania aplikacjom desktopowym wyglądu znanego z systemu Windows 11 / WinUI 3. Komponenty bazują na oficjalnych tokenach kolorystycznych Fluent UI v9 i wspierają motyw jasny oraz ciemny — z automatyczną detekcją ustawień Windows.

### ✨ Kluczowe cechy

- **Wygląd Windows 11 / WinUI 3** — wszystkie komponenty są stylizowane spójnie i zgodnie z najnowszymi wytycznymi Microsoft.
- **Pełna obsługa motywów Light / Dark** z automatyczną synchronizacją z motywem systemowym.
- **Renderowanie GDI+** — gładkie krawędzie, antyaliasing, zaokrąglone narożniki.
- **Wydajność** — buforowanie podwójne, brak migotania, płynne animacje.
- **DPI-aware** — komponenty poprawnie skalują się na monitorach HiDPI.
- **Open Source** — całkowicie darmowe do użytku w projektach komercyjnych i niekomercyjnych.

---

## 📦 Komponenty

### Kontenery i panele

| Komponent | Opis |
|-----------|------|
| **`TCWSCornerPanel`** | Panel z konfigurowalnymi, zaokrąglonymi narożnikami i kolorową ramką. |
| **`TCWSSettingsPanel`** | Klikalny panel-kontener w stylu „karty" z zaokrąglonym tłem rysowanym bezpośrednio przez GDI+ (`FillColor`, `BorderColor`, `CornerRadius`) oraz zdarzeniami hover / click. |
| **`TCWSScrollBox`** | Scrollowalny kontener z pływającymi (overlay) paskami przewijania w stylu Fluent — pionowym i poziomym — które nakładają się na treść (nie rezerwują miejsca), pogrubiają się przy najechaniu i nie powodują migotania (treść przesuwana jedną operacją `SetWindowPos`). Kierunki przewijania wybiera `ScrollStyle` (`none` / `horizontal` / `vertical` / `both`). Konfigurowalne kolory, szerokości i przezroczystość suwaka, krok kółka oraz ramka; kontrolki dodawane w czasie działania trafiają na `ContentPanel`. Suwak jest wyśrodkowany w swoim pasie, pogrubia się, gdy kursor jest gdziekolwiek w tym pasie, i cały pas jest wtedy klikalny — obok suwaka zaczyna przeciąganie, nad/pod nim przeskok. Sposób osadzenia paska wybiera `ScrollbarRenderMode`: `srmShaped` (domyślnie — okno paska jest samym suwakiem, tor nigdy nie zasłania treści, a wygładzone końce są wtapiane w piksele naprawdę leżące pod paskiem) lub `srmBlended` (kryjący tor w kolorze tła). |
| **`TCWSOptionsPanel`** | Rozwijana „karta" ustawień w stylu Windows 11 / WinUI 3 (*Expander*) z nagłówkiem (ikona + tytuł + podtytuł + chevron). Zwinięta jest pojedynczym zaokrąglonym prostokątem; po rozwinięciu nagłówek zachowuje zaokrąglone górne narożniki, a pod nim układają się jedna lub więcej sekcji `TCWSOptionsSection` (zwykłe panele przyjmujące dowolne kontrolki — checkboxy, przyciski itp.). Sekcje dodaje się w czasie działania (`AddSection`) lub w IDE przez edytor komponentu („Add section"). Dwa style glifu (`ChevronStyle`: `csVertical` — chevron rozwijania; `csRight` — strzałka nawigacji w stylu wiersza Ustawień), tryb nierozwijalny (`Expandable = False`), niezależne czcionki tytułu i podtytułu (`TitleFont` / `SubtitleFont`) z regulowanym odstępem między nimi (`TitleSpacing`), podświetlenie nagłówka przy najechaniu (`HoverColor`), zaokrąglanie każdego narożnika z osobna oraz opcjonalne zaokrąglenie dolnych rogów ostatniej sekcji po rozwinięciu (`RoundLastSection`), przełączane krawędzie ramki, ikona nagłówka jako obraz z `TCustomImageList` **lub glif z fontu ikon** (`IconMode` = `icmImageList` / `icmGlyph`, `IconGlyph` / `IconFontName` / `IconFontSize` / `IconColor` — jak w `TCWSButton`) oraz zdarzenie `OnExpandedChanged`. Rysowanie GDI+, DPI-aware. |

### Przyciski

| Komponent | Opis |
|-----------|------|
| **`TCWSButton`** | Wielofunkcyjny przycisk Fluent (Primary / Neutral / Custom) z obsługą ikon — glif z fontu ikon lub obraz z listy `TCustomImageList` (`Images` / `ImageIndex`, osobny `ImageIndexPressed`) — oraz konfigurowalnym położeniem ikony (lewo / prawo / góra / dół). |
| **`TCWSStoreButton`** | Przycisk w stylu Microsoft Store — z opisem i animowanym wskaźnikiem aktywności. |
| **`TCWSMenuButton`** | Przycisk paska bocznego (sidebar / hamburger menu) z obsługą grupowania. |
| **`TCWSRadioButton`** | Przycisk radiowy w stylu Windows 11 — okrągły wskaźnik (pierścień + kropka) rysowany przez `TCWSShape`, antyaliasing w każdym DPI. Kolory wskaźnika i tekstu osobno dla stanów Normal / Checked / Disabled, `RadioSize`, `TextSpacing`, `AutoSize`. |
| **`TCWSCheckBox`** | Pole wyboru w stylu Windows 11 — kwadratowy, zaokrąglony wskaźnik (`TCWSShape`) z antyaliasowanym znacznikiem GDI+. Niezależne od siebie (bez `GroupIndex`). `BoxSize`, `CornerRadius`, kolory per stan, `TextSpacing`, `AutoSize`. |
| **`TCWSSwitch`** | Przełącznik (toggle) w stylu Windows 11 — torowa „pigułka" i okrągła gałka (`TCWSShape`) z charakterystyczną animacją przesuwania (gałka rozciąga się w pigułkę w połowie drogi). Klik lub Spacja przełącza `Checked`; identyczny zestaw zdarzeń co `TCWSCheckBox` / `TCWSRadioButton`. |

> 🎯 **Obsługa akcji (`Action`)** — `TCWSButton`, `TCWSCheckBox`, `TCWSRadioButton` i `TCWSSwitch` mają właściwość `Action`, która wiąże je z `TAction` z `TActionList` — dokładnie jak standardowe kontrolki VCL. Akcja steruje `Caption`, `Enabled`, `Visible`, `Hint` (oraz `Checked` w kontrolkach przełączanych), a kliknięcie wykonuje `OnExecute`. Ręczne ustawienie właściwości odłącza ją od akcji (semantyka linkowania po wartości, jak w VCL).

### Pola wprowadzania danych

| Komponent | Opis |
|-----------|------|
| **`TCWSEdit`** | Pole edycji w stylu Fluent z wbudowanymi przyciskami akcji (clear, search, password reveal, custom). |
| **`TCWSEditMask`** | Pole edycji z **maską wejścia** (jak `Vcl.TMaskEdit`) — wszystkie właściwości i zdarzenia `TCWSEdit` plus `EditMask`, `EditText` oraz walidacja maski (`IsValid`, `ValidateEdit`, zdarzenie `OnValidationError`, `ValidateOnExit`). W Object Inspectorze przycisk „…" otwiera ten sam edytor maski („Input Mask Editor") co VCL. Bez natywnego okna błędu — niezgodność z maską zgłasza zdarzenie. |
| **`TCWSComboBox`** | ComboBox z dropdownem renderowanym przez GDI+, własnym scrollbarem i pełną obsługą klawiatury. Tryby `csDropDown` / `csDropDownList`. |
| **`TCWSMemo`** | Wielowierszowe pole tekstowe z dyskretnymi, zanikającymi paskami przewijania w stylu Fluent (pionowy **i** poziomy) oraz właściwością `ScrollBars` (`both` / `vertical` / `horizontal` / `none`) jak w `Vcl.Memo`. |
| **`TCWSDatePicker`** | Picker daty z rozwijanym kalendarzem w stylu Windows 11 / WinUI 3 — warstwowe okno z miękkim „fluentowym" cieniem (alfa per-piksel), renderowanie GDI+, DPI-aware. Trzy widoki nawigacji: **dni → miesiące → lata (dekada)** — kliknięcie nagłówka miesiąca/roku wchodzi głębiej, kółko myszy przewija. Wbudowane pole z **maską daty** (`DateFormat`, `EditMask`); nazwy miesięcy i dni tygodnia pobierane z bieżącej lokalizacji systemu. Kształt komórki dnia (`DayShape`: `dsRoundRect` / `dsCircle` / `dsRectangle`) i rozbudowana personalizacja kolorów **per stan**: wybrany dzień (`SelectedDayColor` / `SelectedDayBorderColor` / `SelectedDayTextColor`), hover (`HoverColor` / `HoverTextColor`), dzień dzisiejszy (`TodayBorderColor` — pierścień + kwadrat na pasku „Today", `TodayTextColor` / `TodayHoverTextColor`), dni sąsiednich miesięcy (`OtherMonthTextColor` / `OtherMonthHoverTextColor`) oraz linki nagłówka i strzałki nawigacji (`LinkTextColor` / `LinkHoverTextColor`). Konfigurowalny cień i zaokrąglenie dropdownu, pasek „Today", zdarzenia `OnChange` / `OnDropDown` / `OnCloseUp`. |

### Listy i siatki

| Komponent | Opis |
|-----------|------|
| **`TCWSListBox`** | Lista (ListBox) w stylu Fluent z dyskretnym, zanikającym paskiem przewijania (tak jak w `TCWSMemo`). |
| **`TCWSStringGrid`** | Płaska siatka tekstowa (StringGrid) z fluentowymi paskami przewijania (pionowy + poziomy). Konfigurowalne kolory (tło komórek, tło poza komórkami, linie siatki, komórki *fixed*, podświetlenie komórki, ramka), naprzemienne kolorowanie wierszy (`AlternatingRowColors` + `OddRowColor` / `EvenRowColor`), zaokrąglone narożniki z możliwością wyłączenia każdego z osobna oraz komórki bez efektu 3D. |
| **`TCWSDBGrid`** | Siatka **danych** (DBGrid) w stylu Fluent — opakowuje wewnętrzny `TDBGrid`, więc zachowuje jego pełny interfejs (`DataSource`, `Columns`, `Options`, zdarzenia `OnDrawColumnCell` / `OnCellClick` / `OnTitleClick` itd.). Fluentowe paski przewijania (pionowy + poziomy), konfigurowalne kolory (tło, komórki, tekst, linie siatki, komórki *fixed*, podświetlenie), **sortowanie kliknięciem w nagłówek** z obsługą wielu kolumn i wskaźnikami w tytule (`SortEnabled`, `MultiSortMode`, `MaxSortColumns`, `SortBy` / `ClearSort`, `OnSortApply`), naprzemienne kolorowanie wierszy liczone po rekordach (`AlternatingRowColors` + `OddRowColor` / `EvenRowColor`), zaokrąglone narożniki z możliwością wyłączenia każdego z osobna, automatyczne dopasowanie szerokości kolumn (`AutoFitColumns`), regulowana wysokość wiersza i nagłówka, pionowe wyśrodkowanie tekstu oraz zaznaczanie wielu rekordów (`dgMultiSelect`, Ctrl+klik, Shift+klik, Ctrl+A). |

### Wskaźniki postępu

| Komponent | Opis |
|-----------|------|
| **`TCWSProgressCircle`** | Kołowy wskaźnik postępu z animacją, konfigurowalnym kątem startowym, etykietą tekstową i zaokrąglonymi końcami linii (GDI+). |
| **`TCWSProgressBar`** | Poziomy pasek postępu w stylu Windows 11 / WinUI 3 — zaokrąglone (kapsułka) lub proste końce (`RoundCaps`), osobne kolory tła (`BackgroundColor`) i wypełnienia (`ProgressColor`), opcjonalny tekst procentów (`ShowText` / `TextColor`), wygładzanie GDI+ i płynna animacja wartości (`AnimateTo`). |
| **`TCWSIndicatorLoading`** | Płaski, animowany wskaźnik aktywności (loader) jako `TGraphicControl` — bez własnego okna, więc w pełni przezroczysty na tle rodzica. Cztery style (`cilLines`, `cilRing`, `cilSegmented`, `cilArrows`), rotacja zależna od czasu (niezależna od FPS); `Active` startuje/zatrzymuje animację. Te same style co loader wbudowany w `TCWSDimOverlay`. |

### Menu

| Komponent | Opis |
|-----------|------|
| **`TCWSPopupMenu`** | Menu kontekstowe w stylu Windows 11 / WinUI 3 dziedziczące po `TPopupMenu` — działa edytor menu IDE (Menu Designer), elementy `TMenuItem`, pełne podmenu, ikony, skróty, separatory. Zaokrąglone narożniki, miękki „fluentowy" cień (warstwowe okno z alfą per-piksel), renderowanie GDI+, DPI-aware, w pełni konfigurowalne kolory, przewijanie (strzałki + kółko) i kaskadowe podmenu. |
| **`TCWSFlayoutPopupMenu`** | `CommandBarFlyout` z WinUI 3 — menu o dwóch poziomach: poziomy pasek poleceń podstawowych (ikona + podpis pod nią) i pionowa lista poleceń dodatkowych rozwijana przyciskiem „…". Dziedziczy po `TCWSPopupMenu` (cała stylizacja, edytor menu IDE, `TMenuItem`), a poziomy rozdziela pierwszy separator na poziomie głównym albo wprost `PrimaryCount` — a przy jawnej liczbie separator postawiony wewnątrz paska staje się pionową kreską między grupami poleceń (`AppBarSeparator`). `LabelPosition` przełącza pasek w tryb samych ikon, `PopupForControl` / `PopupForRect` ustawiają flyout nad wskazaną kontrolką jak `FlyoutBase.AttachedFlyout`. Przy dolnej krawędzi ekranu lista rozwija się w górę, a pasek zostaje na miejscu. Polecenie paska z podpozycjami otwiera własne podmenu, polecenia dodatkowe zachowują skróty, znaczniki wyboru, podmenu i przewijanie. |
| **`TCWSSystemMenu`** | Systemowe menu okna (Alt+Space, ikona na pasku tytułu, prawy przycisk na belce) narysowane jako `TCWSPopupMenu`. Podpisy, kolejność i pozycje dodane przez `AppendMenu` czytane są z prawdziwego menu systemowego, więc menu pozostaje zlokalizowane i kompletne; wybór pozycji wysyła `WM_SYSCOMMAND` dokładnie tak jak menu natywne. Wybór wyzwalaczy (`Triggers`), własne podpisy i ikony pozycji, dodatkowe pozycje z `ExtraMenu`, zdarzenia `OnPopup` / `OnClose` / `OnCommand`. |

### Etykiety

| Komponent | Opis |
|-----------|------|
| **`TCWSLabelColumn`** | Dwukolumnowa etykieta — dwa niezależne teksty obok siebie (lewa / prawa kolumna), każdy z własną czcionką (`LeftFont` / `RightFont`), wyrównaniem i szerokością. Automatyczny *marquee*, gdy tekst nie mieści się w kolumnie (`ScrollColumns`, osobne prędkości `LeftScrollStep` / `RightScrollStep`, miękkie wygaszanie krawędzi `EdgeFade`) — bez migotania (rysuje się bezpośrednio, bez `Invalidate`). |
| **`TCWSLabelTrend`** | Etykieta w stylu „pigułki" / badge (kolorowe tagi statusu, np. Lead / POC / Closed) — kapsułka GDI+ z wypełnieniem (`Color`) i opcjonalną ramką, auto-rozmiar do treści. Ikona po lewej i/lub prawej stronie tekstu (glyph z fontu ikon lub obraz z `ImageList` — jak w `TCWSMenuButton`). Pełen zestaw zdarzeń etykiety (`OnClick`, mysz, `OnMouseEnter` / `OnMouseLeave`, `OnContextPopup`). |

### Kształty

| Komponent | Opis |
|-----------|------|
| **`TCWSShape`** | Lekka, bezzależnościowa kontrolka graficzna (`TGraphicControl`, GDI+) rysująca prostokąt, zaokrąglony prostokąt lub koło (`Shape`: `Rectangle` / `RoundRectangle` / `Circle`) z wypełnieniem (`Brush`) i opcjonalną ramką (`Pen`). Element bazowy, na którym opierają się inne komponenty CWStudio — m.in. `TCWSButton`, `TCWSStoreButton` i `TCWSMenuButton` używają jej (przez kompozycję) do rysowania zaokrąglonego tła — ale można ją też swobodnie kłaść na formularz. |
| **`TCWSAvatar`** | Awatar w kształcie koła, prostokąta lub zaokrąglonego prostokąta (`Shape`, `CornerRadius`, oparte na `TCWSShape`). Pokazuje zdjęcie (`Picture`), skalowane do jego obszaru według `ImageFit` (`ifCover` — przycięcie przez środek do proporcji, domyślne; `ifContain` — całe zdjęcie widoczne z zachowaniem proporcji, tło jako „listwy"; `ifStretch` — rozciągnięcie na cały obszar, może zniekształcić; `ifCenter` — naturalny rozmiar, wyśrodkowane). Zdjęcie nigdy nie wychodzi poza kontur kształtu — jego krawędź wtapia się w tło (`Brush`) przez płynny gradient przezroczystości o szerokości `ImageMargin` pikseli (a nie twardą, zero-jedynkową granicę) — a przy braku zdjęcia wycentrowany tekst, np. inicjały, we wskazanej czcionce i kolorze (`Caption`, `Font`). |

### Komponenty pomocnicze

| Komponent | Opis |
|-----------|------|
| **`TCWSDimOverlay`** | Warstwa przyciemniająca formularz (layered window) — idealna pod modalne dialogi. Wsparcie zaokrąglonych narożników Win11, animacja fade-in/out, blokowanie kliknięć. Wbudowany wskaźnik aktywności (loader) w 4 stylach (`cisLines`, `cisRing`, `cisSegmented`, `cisArrows`) z płynną, niezależną od FPS animacją — prędkość konfigurowalna przez `IndicatorSpeed` (stopnie/s, domyślnie 300). Animacja działa we własnym wątku, więc kręci się nawet gdy główny wątek jest zajęty. Opcjonalny tekst pod wskaźnikiem. |
| **`TCWSAfterFormShow`** | Komponent emitujący zdarzenie `OnAfterShow` po pełnym wyrenderowaniu formularza (po `Show` / `ShowModal`, także zmaksymalizowanego, ale **nie** po przywróceniu z minimalizacji). |
| **`TCWSHint`** | Zastępuje standardowy hint **całej aplikacji** dymkiem w stylu Windows 11 — wystarczy upuścić jeden na formę główną (`Active`). Zaokrąglone rogi (`CornerRadius`), kolory tła i ramki (`Color`, `BorderColor`, `BorderThickness`), czcionka (`Font`), marginesy i maksymalna szerokość, miękki cień (`Shadow`, `ShadowSize`), czasy opóźnienia i wyświetlania (`HintPause`, `HintHidePause`, `HintShortPause`), skróty klawiszowe w treści (`HintShortCuts`) oraz zdarzenie `OnShowHint` (zmiana tekstu, pozycji, czasu lub koloru pojedynczego hintu). Rysowany jak `TCWSPopupMenu` — okno warstwowe z gotową bitmapą, bez migania tła przy pokazywaniu. |
| **`TCWSShadow`** | Miękki, półprzezroczysty cień (AlphaBlend) dla **dowolnej** kontrolki — wystarczy upuścić na formę i wskazać ją we właściwości `Control`; cień sam ustawia się pod nią na tym samym rodzicu i podąża za jej pozycją, rozmiarem i widocznością (także w IDE). Kierunek (`Direction`, stopnie), odległość (`Distance`), wielkość (`Size`, jak *spread* w CSS), miękkość (`Softness`), krycie (`Opacity`) i kolor (`Color`). Dwa tryby: `smShape` (domyślny) — cień faktycznego kształtu narysowanej kontrolki (tekst, także wielowierszowy `TLabel`, kształty, przezroczysty obraz), jak CSS `drop-shadow()` czy FMX `TShadowEffect`, z rozmyciem Gaussa; `smBox` — cień zaokrąglonego prostokąta (`CornerRadius`), jak CSS `box-shadow`; `IgnoreChildLabels` pomija przy tym podpisy (np. przełącznik rzuca cień samym wskaźnikiem). `TGraphicControl` — rysowany na płótnie rodzica, więc prześwituje przez niego tło i kontrolki graficzne; kliknięcia przechodzą przez cień. |

### Moduły kolorów Fluent

| Unit | Opis |
|------|------|
| **`CWSFluentColors`** | Pełen zestaw tokenów kolorystycznych Fluent UI v9 (Light + Dark). Pojedynczy callback przy zmianie motywu (`FluentOnThemeChange`). |
| **`CWSFluentColorsMulti`** | Ta sama paleta tokenów, ale z obsługą **wielu** subskrybentów: `RegisterThemeChange` / `UnregisterThemeChange`. Każda forma lub kontrolka rejestruje własny handler. |
| **`CWSInteractiveUserTheme`** | Wykrywa motyw (jasny / ciemny) **zalogowanego użytkownika** także wtedy, gdy proces działa na koncie `NT AUTHORITY\SYSTEM` (np. uruchomiony przez `ServiceUI.exe` z Intune / MDT), gdzie `HKCU` należy do konta usługi, a nie do użytkownika. `StartFollowingUserTheme` ustawia motyw i uruchamia obserwację zmian, `StopFollowingUserTheme` ją zatrzymuje. |

> 🌗 **Motyw podąża za systemem** — kolory motywu (jasny / ciemny) zmieniają się automatycznie w zależności od ustawień systemu Windows. Komponenty nasłuchują zmiany motywu Windows (np. przełączenie *Ustawienia → Personalizacja → Kolory → Tryb*) i przemalowują się w locie, a każdy zarejestrowany handler dostaje powiadomienie, dzięki czemu cała aplikacja pozostaje spójna bez restartu.

#### Przykład — moduł kolorów (`CWSFluentColorsMulti`)

```pascal
uses
  CWSFluentColorsMulti;

procedure TForm1.FormCreate(Sender: TObject);
begin
  RegisterThemeChange(HandleThemeChange);
  FluentApplySystemTheme;            // automatycznie z rejestru Windows
  HandleThemeChange;                 // pierwsze pomalowanie
end;

procedure TForm1.HandleThemeChange;
begin
  Color           := flNeutralBackground1;
  Label1.Font.Color := flNeutralForeground1;
  Invalidate;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  UnregisterThemeChange(HandleThemeChange);
end;
```

#### Przykład — motyw zalogowanego użytkownika (`CWSInteractiveUserTheme`)

Standardowe wykrywanie motywu czyta `HKCU`, więc aplikacja uruchomiona na koncie `NT AUTHORITY\SYSTEM` (np. przez `ServiceUI.exe` z Intune / MDT) dostaje ustawienia konta usługi, a nie zalogowanego użytkownika — i zawsze pokazuje motyw jasny. Ten unit ustala sesję interaktywną, jej SID, i czyta `AppsUseLightTheme` wprost z `HKEY_USERS\<SID>`.

```pascal
uses
  CWSFluentColorsMulti, CWSInteractiveUserTheme;

procedure TForm1.FormCreate(Sender: TObject);
begin
  RegisterThemeChange(ApplyTheme);   // tylko rejestracja — okno nie ma jeszcze uchwytu
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  StartFollowingUserTheme;           // ustawia motyw i startuje obserwację zmian
  ApplyTheme;                        // pierwsze pomalowanie — jawnie, nie licz na callback
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  StopFollowingUserTheme;
  UnregisterThemeChange(ApplyTheme);
end;
```

> ⚠️ **Wołaj `StartFollowingUserTheme` w `FormShow`, nie w `FormCreate`** — w `FormCreate` zmienna globalna formularza jest jeszcze `nil`, a okno nie ma uchwytu.

Diagnostyka: ustaw `ThemeLogEnabled := True` (albo uruchom aplikację z przełącznikiem `/themelog`), aby zapisać przebieg wykrywania do `%TEMP%\CWSTheme.log` (pod kontem SYSTEM: `C:\Windows\Temp`). `ThemeDiagnostics` zwraca ten sam stan jako gotowy tekst — SID procesu, numery sesji, SID użytkownika i wykryty motyw.

#### 🎨 Wzornik kolorów — `CWSFluentColors_palette.html`

W repozytorium znajduje się interaktywny **wzornik kolorów** [`CWSFluentColors_palette.html`](CWSFluentColors_palette.html) — otwórz go w przeglądarce, aby przejrzeć wszystkie tokeny Fluent UI v9 z `CWSFluentColors.pas` (warianty Light i Dark). Pozwala on:

- filtrować tokeny po nazwie (np. `Brand`, `Background`, `Hover`),
- podejrzeć paletę na jasnym i ciemnym tle (przełącznik **Light / Dark**),
- kliknięciem **próbki** skopiować kolor jako HEX (`#0f6cbd`) lub Delphi `TColor` (`$00BD6C0F`) — format wybiera przełącznik **Copy as**, który zmienia też wartości wyświetlane na próbkach; prawy klik zawsze kopiuje wartość Delphi,
- kliknięciem **nazwy** skopiować nazwę tokena do schowka.

Dzięki temu łatwo dobrać i dopasować kolory ustawiane we właściwościach komponentów (np. `BorderColor`, `CellHighlightColor`, `BckHoverColor`, `FillColor`).

---

## 🔧 Wymagania systemowe

- **Embarcadero Delphi / RAD Studio z frameworkiem VCL.** Biblioteka powstała i jest rozwijana w **RAD Studio 13.1 Florence** (kompilator 37.0); zalecane RAD Studio 11 Alexandria lub nowsze.
- **Platformy docelowe:** Win32 oraz Win64.
- **System operacyjny:**
  - **Windows 10** lub nowszy do uruchomienia aplikacji (`TCWSDimOverlay` korzysta z okien warstwowych `WS_EX_LAYERED` oraz API DWM).
  - **Windows 11 (build 22000) lub nowszy** dla pełnego wyglądu Windows 11 — komponent `TCWSDimOverlay` (i inne warstwowe okna, np. cienie `TCWSPopupMenu`) używa `DWMWA_WINDOW_CORNER_PREFERENCE` do rysowania zaokrąglonych narożników. Na starszych systemach komponenty działają poprawnie, lecz narożniki pozostają proste (płynna degradacja).
- **Brak wymaganych zależności firm trzecich** — pakiety linkują się wyłącznie ze standardowymi `rtl` i `vcl`.
- **Ikony** — komponenty z ikonami (np. `TCWSButton`, `TCWSMenuButton`, `TCWSLabelTrend`) przyjmują dowolny standardowy `TCustomImageList` (właściwości `Images` / `ImageIndex`) lub glif z fontu ikon. Nie są potrzebne żadne dodatkowe biblioteki.

---

## 🚀 Instalacja

Biblioteka jest podzielona na dwa pakiety. Zbudowano w **RAD Studio 13.1 Florence** (kompilator 37.0).

| Pakiet | Plik | Platformy | Rola |
|--------|------|-----------|------|
| **Runtime** | `CWStudio_ComponentsRT.dpk` | Win32 + Win64 | Kod komponentów. Dołączany do aplikacji, możliwy do redystrybucji. **Nie** instaluje się w IDE. |
| **Design-time** | `CWStudio_ComponentsDT.dpk` | Win32 + Win64 | Rejestracja na palecie, ikona + nazwa „CWStudio Component" na splash screenie i w About Box IDE. Wymaga pakietu runtime. |

#### 1. Zbuduj pakiety (runtime przed design-time, dla obu platform)

1. Otwórz grupę projektów **`CWStudio_Components.groupproj`** w RAD Studio.
2. Wybierz platformę **Win32**, następnie:
   - prawy klik **`CWStudio_ComponentsRT`** → **Build**,
   - prawy klik **`CWStudio_ComponentsDT`** → **Build**.
3. Przełącz platformę na **Win64** i powtórz oba `Build` (runtime będzie redystrybuowany także dla aplikacji 64-bit).

   Alternatywnie z linii poleceń (po `rsvars.bat`):
   ```bat
   msbuild CWStudio_Components.groupproj /t:Build /p:Config=Release /p:Platform=Win32
   msbuild CWStudio_Components.groupproj /t:Build /p:Config=Release /p:Platform=Win64
   ```

#### 2. Zainstaluj pakiet projektowy

Prawy klik **`CWStudio_ComponentsDT`** → **Install**. Wtedy:

- komponenty pojawią się na palecie w zakładkach **CWStudio_Panels / _Buttons / _Edits / _ProgressBars / _Menus / _ScrollBoxes / _Forms / _ListBoxes / _Grids / _Labels**.

#### 3. Dodaj ścieżki do biblioteki

Aby Twoje aplikacje kompilowały się z komponentami, w **Tools → Options → Language → Delphi → Library** (dla **każdej** platformy: Win32 i Win64) dodaj do **Library path** katalog z plikami `.dcu` (folder ze źródłami lub `.\Win32\Release` / `.\Win64\Release`). Folder źródeł warto dodać też do **Browsing path** (debugowanie do kodu komponentów).

### 🧩 Użycie w aplikacji i redystrybucja

- **Bez pakietów runtime** (domyślnie — *Link with runtime packages = false*): komponenty są wkompilowane statycznie w `.exe`. Nie trzeba nic dołączać.
- **Z pakietami runtime**: dodaj `CWStudio_ComponentsRT` do *Runtime Packages* projektu i wraz z aplikacją dystrybuuj `CWStudio_ComponentsRT.bpl` (Win32 lub Win64) oraz `.bpl` zależności. Pakiet **design-time nie jest** potrzebny użytkownikowi końcowemu.

### 🛠️ Rozwiązywanie problemów

- **`F2039: Could not create output file ...bpl`** — pakiet jest aktualnie załadowany w IDE. Odinstaluj go (**Component → Install Packages**) lub zamknij RAD Studio przed budowaniem z linii poleceń.
- **`E2466: Never-build package requires always-build package`** — pakiety CWStudio używają `{$IMPLICITBUILD ON}`. **Nie** ustawiaj pakietu design-time na `{$IMPLICITBUILD OFF}`.

---

## 🖥️ Aplikacja demo

W folderze [`CWStudio_demo`](CWStudio_demo) znajduje się przykładowa aplikacja VCL (`demo.dproj`) pokazująca komponenty w działaniu — przyciski, pola edycji, panele, siatki i listy, wskaźniki postępu, scrollboxy, menu systemowe, warstwę przyciemniającą z dialogiem oraz przełączanie motywu jasny / ciemny przez `CWSFluentColorsMulti`. Menu boczne zbudowane jest z `TCWSStoreButton`, a każda strona to osobna forma osadzana w obszarze treści.

**Wymagania demo:**

- zainstalowane pakiety CWStudio (patrz [🚀 Instalacja](#-instalacja)),
- [**SVGIconImageList**](https://github.com/EtheaDev/SVGIconImageList) — ikony w formularzach demo (`TSVGIconImageList`). Same komponenty CWStudio tej biblioteki **nie** wymagają.

Od wersji 1.9.25 demo **nie zależy od komponentów ErrorSoft** (EsVclComponents) — `TEsShape` w oknie głównym zastąpił `TCWSSettingsPanel`, a nieużywane moduły `ES.*` zostały usunięte z `uses`.

Otwórz `CWStudio_demo\demo.dproj`, wybierz platformę Win32 lub Win64 i uruchom (**F9**).

---

## ⚖️ Wymagane przypisanie autorstwa

Używając tych komponentów, proszę o umieszczenie odpowiedniej informacji w swojej aplikacji (np. w oknie „O programie"):

> *„Ta aplikacja wykorzystuje komponenty CWStudio autorstwa Czesława Włudarczyka"*

---

## 🗓️ Co nowego

**Najnowsza wersja — 1.9.33:**

- **Poprawka** `TCWSAfterFormShow`: **wykrywanie pokazania formularza oparte na `CM_SHOWINGCHANGED`** zamiast `WM_SHOWWINDOW` / `WM_SIZE` / `WM_PAINT`. `OnAfterShow` jest teraz wywoływane również dla formularza pokazywanego jako zmaksymalizowany, nadal nie po przywróceniu z minimalizacji. Wątek pomocniczy sprawdza `IsWindow` przed wysłaniem komunikatu, więc formularz zamknięty przed bezczynnością aplikacji nie dostaje komunikatu do nieistniejącego okna.

Pełna historia zmian znajduje się w pliku [`CHANGELOG.md`](CHANGELOG.md).

---

## ❤️ Wsparcie autora

Jeśli komponenty CWStudio okazały się przydatne i chcesz wesprzeć dalszy rozwój biblioteki — postaw mi wirtualną kawę lub przekaż darowiznę. Każde wsparcie pomaga utrzymać i rozbudowywać projekt:

<div align="center">

<a href="https://paypal.me/czeslaw80">
  <img src="https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif" alt="Wesprzyj autora przez PayPal" />
</a>

**[💛 paypal.me/czeslaw80](https://paypal.me/czeslaw80)**

</div>

---

## 📄 Licencja

Biblioteka jest udostępniona na licencji **MIT** — możesz jej używać, modyfikować i rozpowszechniać w dowolnych projektach komercyjnych lub niekomercyjnych. Warunkiem jest zachowanie informacji o autorstwie i treści licencji (zobacz sekcję [⚖️ Wymagane przypisanie autorstwa](#️-wymagane-przypisanie-autorstwa) oraz plik [`LICENSE`](LICENSE)).

<br>

---

<br>

## 🇬🇧 English version

CWStudio is a library of modern, high-quality VCL components for Delphi, designed to give your desktop applications the look and feel of Windows 11 / WinUI 3. Every component is based on the official Fluent UI v9 color tokens and supports both light and dark themes — with automatic detection of the current Windows setting.

### ✨ Key features

- **Windows 11 / WinUI 3 look & feel** — every control styled consistently with the latest Microsoft guidelines.
- **Light & Dark theme** support with automatic system theme synchronization.
- **GDI+ rendering** — smooth edges, antialiasing, rounded corners.
- **Performance-first** — double buffering, no flicker, smooth animations.
- **DPI-aware** — controls scale correctly on HiDPI monitors.
- **Open Source** — completely free for commercial and non-commercial projects.

---

## 📦 Components

### Containers & panels

| Component | Description |
|-----------|-------------|
| **`TCWSCornerPanel`** | Panel with configurable rounded corners and colored border. |
| **`TCWSSettingsPanel`** | Clickable "card"-style container panel with a GDI+ rounded background (`FillColor`, `BorderColor`, `CornerRadius`) and hover / click events. |
| **`TCWSScrollBox`** | Scrollable container with floating Fluent-style **overlay** scrollbars — vertical and horizontal — that sit on top of the content (reserve no space), thicken on hover, and never flicker (content moved atomically with a single `SetWindowPos`). Scroll directions are chosen via `ScrollStyle` (`none` / `horizontal` / `vertical` / `both`). Configurable thumb colors, widths and opacity, wheel step, and border; controls added at runtime go onto `ContentPanel`. The thumb is centred in its lane, thickens while the cursor is anywhere in that lane, and the whole lane is then clickable — beside the thumb to drag it, above or below to jump. `ScrollbarRenderMode` picks how the bar is composed: `srmShaped` (default — the bar's window is the thumb itself, so the track never covers content, and the antialiased ends are blended into the pixels that really lie under the bar) or `srmBlended` (an opaque track in the background colour). |
| **`TCWSOptionsPanel`** | Collapsible Windows 11 / WinUI 3 settings "card" (*Expander*) with a header (icon + title + subtitle + chevron). Collapsed it is a single rounded rectangle; expanded, the header keeps its rounded top corners while one or more `TCWSOptionsSection` sub-panels — plain panels that host arbitrary child controls (checkboxes, buttons, …) — stack underneath. Sections are added at runtime (`AddSection`) or in the IDE via the component editor's "Add section" verb. Two glyph styles (`ChevronStyle`: `csVertical` — expander chevron; `csRight` — Settings-row navigation arrow), a non-collapsible mode (`Expandable = False`), independent title and subtitle fonts (`TitleFont` / `SubtitleFont`) with a configurable gap between them (`TitleSpacing`), header hover highlight (`HoverColor`), per-corner rounding plus optional rounding of the last section's bottom corners when expanded (`RoundLastSection`), individually switchable border edges, a header icon from a `TCustomImageList` **or an icon-font glyph** (`IconMode` = `icmImageList` / `icmGlyph`, `IconGlyph` / `IconFontName` / `IconFontSize` / `IconColor` — just like `TCWSButton`), and an `OnExpandedChanged` event. GDI+ rendering, DPI-aware. |

### Buttons

| Component | Description |
|-----------|-------------|
| **`TCWSButton`** | Multi-purpose Fluent button (Primary / Neutral / Custom) with icon support — an icon-font glyph or an image from a `TCustomImageList` (`Images` / `ImageIndex`, separate `ImageIndexPressed`) — and a configurable icon position (left / right / top / bottom). |
| **`TCWSStoreButton`** | Microsoft Store style button — with description text and an animated activity cursor. |
| **`TCWSMenuButton`** | Sidebar / hamburger menu button with grouping support. |
| **`TCWSRadioButton`** | Windows 11 style radio button — circular indicator (ring + dot) drawn with `TCWSShape`, anti-aliased at any DPI. Indicator and caption colors per state (Normal / Checked / Disabled), `RadioSize`, `TextSpacing`, `AutoSize`. |
| **`TCWSCheckBox`** | Windows 11 style check box — rounded square indicator (`TCWSShape`) with an anti-aliased GDI+ check mark. Independent of one another (no `GroupIndex`). `BoxSize`, `CornerRadius`, per-state colors, `TextSpacing`, `AutoSize`. |
| **`TCWSSwitch`** | Windows 11 style toggle switch — pill-shaped track and round knob (`TCWSShape`) with the recognisable sliding animation (the knob stretches into a pill mid-travel). A click or Space toggles `Checked`; same event surface as `TCWSCheckBox` / `TCWSRadioButton`. |

> 🎯 **Action support (`Action`)** — `TCWSButton`, `TCWSCheckBox`, `TCWSRadioButton` and `TCWSSwitch` expose an `Action` property that links them to a `TAction` in a `TActionList`, exactly like the stock VCL controls. The action drives `Caption`, `Enabled`, `Visible`, `Hint` (and `Checked` on the toggle controls), and a click executes `OnExecute`. Setting a property by hand unlinks it from the action (value-linking semantics, as in the VCL).

### Input controls

| Component | Description |
|-----------|-------------|
| **`TCWSEdit`** | Fluent-style edit box with built-in action buttons (clear, search, password reveal, custom). |
| **`TCWSEditMask`** | Edit box with an **input mask** (like `Vcl.TMaskEdit`) — every property and event of `TCWSEdit` plus `EditMask`, `EditText` and mask validation (`IsValid`, `ValidateEdit`, the `OnValidationError` event, `ValidateOnExit`). The `…` button in the Object Inspector opens the same "Input Mask Editor" dialog as the VCL. No native error message box — mask mismatches are surfaced through the event instead. |
| **`TCWSComboBox`** | ComboBox with a GDI+-rendered dropdown, its own scrollbar, full keyboard navigation. Modes: `csDropDown` / `csDropDownList`. |
| **`TCWSMemo`** | Multi-line text area with subtle auto-hiding Fluent-style scrollbars (vertical **and** horizontal) and a `ScrollBars` property (`both` / `vertical` / `horizontal` / `none`) like `Vcl.Memo`. |
| **`TCWSDatePicker`** | Date picker with a drop-down Windows 11 / WinUI 3 calendar — a layered window with a soft "fluent" shadow (per-pixel alpha), GDI+ rendering, DPI-aware. Three navigation views: **days → months → years (decade)** — clicking the month/year header drills in, the mouse wheel scrolls. A built-in edit with a **date mask** (`DateFormat`, `EditMask`); month and weekday names taken dynamically from the system locale. Day-cell shape (`DayShape`: `dsRoundRect` / `dsCircle` / `dsRectangle`) and extensive **per-state** color customization: selected day (`SelectedDayColor` / `SelectedDayBorderColor` / `SelectedDayTextColor`), hover (`HoverColor` / `HoverTextColor`), today (`TodayBorderColor` — the ring + the "Today" bar square, `TodayTextColor` / `TodayHoverTextColor`), adjacent-month days (`OtherMonthTextColor` / `OtherMonthHoverTextColor`), plus the header links and navigation arrows (`LinkTextColor` / `LinkHoverTextColor`). Configurable dropdown shadow and corner radius, a "Today" bar, and `OnChange` / `OnDropDown` / `OnCloseUp` events. |

### Lists & grids

| Component | Description |
|-----------|-------------|
| **`TCWSListBox`** | Fluent-style list box with a subtle auto-hiding scrollbar (same as `TCWSMemo`). |
| **`TCWSStringGrid`** | Flat text grid (StringGrid) with Fluent scrollbars (vertical + horizontal). Configurable colors (cell background, area-beyond-cells background, grid lines, fixed cells, cell highlight, border), alternating row colors (`AlternatingRowColors` + `OddRowColor` / `EvenRowColor`), rounded corners with each corner independently switchable, and flat (no 3D) cells. |
| **`TCWSDBGrid`** | Fluent-style **data-aware** grid (DBGrid) — wraps an internal `TDBGrid`, so it keeps the full DBGrid surface (`DataSource`, `Columns`, `Options`, events `OnDrawColumnCell` / `OnCellClick` / `OnTitleClick`, etc.). Fluent scrollbars (vertical + horizontal), configurable colors (background, cells, text, grid lines, fixed cells, highlight), **sorting by clicking a title** with multi-column support and in-title indicators (`SortEnabled`, `MultiSortMode`, `MaxSortColumns`, `SortBy` / `ClearSort`, `OnSortApply`), alternating row colors banded by record (`AlternatingRowColors` + `OddRowColor` / `EvenRowColor`), rounded corners with each corner independently switchable, automatic column-width fitting (`AutoFitColumns`), adjustable row and title height, vertical text centering, and multi-record selection (`dgMultiSelect`, Ctrl+click, Shift+click, Ctrl+A). |

### Progress indicators

| Component | Description |
|-----------|-------------|
| **`TCWSProgressCircle`** | Animated circular progress indicator with a configurable starting angle, text label, and round line caps (GDI+). |
| **`TCWSProgressBar`** | Horizontal Windows 11 / WinUI 3 progress bar — rounded (capsule) or square ends (`RoundCaps`), separate background (`BackgroundColor`) and fill (`ProgressColor`) colors, optional percentage text (`ShowText` / `TextColor`), GDI+ smoothing and smooth value animation (`AnimateTo`). |
| **`TCWSIndicatorLoading`** | Flat animated activity indicator (loader) implemented as a `TGraphicControl` — no window handle of its own, so it is genuinely transparent over its parent. Four styles (`cilLines`, `cilRing`, `cilSegmented`, `cilArrows`), time-based (frame-rate-independent) rotation; `Active` starts/stops it. Same styles as the loader built into `TCWSDimOverlay`. |

### Menus

| Component | Description |
|-----------|-------------|
| **`TCWSPopupMenu`** | Windows 11 / WinUI 3 context (popup) menu descending from `TPopupMenu` — the IDE Menu Designer works, items are `TMenuItem`, with full submenus, icons, shortcuts and separators. Rounded corners, soft "fluent" shadow (layered window with per-pixel alpha), GDI+ rendering, DPI-aware, fully configurable colors, scrolling (arrows + wheel) and cascading submenus. |
| **`TCWSFlayoutPopupMenu`** | The WinUI 3 `CommandBarFlyout` — a two-level menu: a horizontal bar of primary commands (icon with its caption underneath) and a vertical list of secondary commands folded out by the "…" button. It descends from `TCWSPopupMenu` (all of its styling, the IDE Menu Designer, `TMenuItem`), and the two levels are split by the first top-level separator, or explicitly by `PrimaryCount` — with an explicit count a separator placed inside the bar becomes a vertical rule between groups of commands (`AppBarSeparator`). `LabelPosition` switches the bar to icons only; `PopupForControl` / `PopupForRect` place the flyout over a target control the way `FlyoutBase.AttachedFlyout` does. Near the bottom edge of the screen the list opens upwards and the bar keeps its place. A bar command with children opens its own submenu, and secondary commands keep shortcuts, check marks, submenus and scrolling. |
| **`TCWSSystemMenu`** | The window's system menu (Alt+Space, the title-bar icon, a right-click on the caption) drawn as a `TCWSPopupMenu`. Captions, order and any entries added with `AppendMenu` are read from the real system menu, so it stays localised and complete; choosing an item posts `WM_SYSCOMMAND` exactly like the native menu. Selectable triggers, custom captions and item icons, extra items from `ExtraMenu`, `OnPopup` / `OnClose` / `OnCommand`. |

### Labels

| Component | Description |
|-----------|-------------|
| **`TCWSLabelColumn`** | Two-column label — two independent texts side by side (left / right column), each with its own font (`LeftFont` / `RightFont`), alignment and width. Automatic *marquee* when a column's text is too wide (`ScrollColumns`, independent speeds `LeftScrollStep` / `RightScrollStep`, soft edge `EdgeFade`) — flicker-free (draws itself directly, no `Invalidate`). |
| **`TCWSLabelTrend`** | "Pill" / badge label (colored status tags, e.g. Lead / POC / Closed) — capsule-shaped GDI+ fill (`Color`) with an optional border, auto-sized to its content. An icon on the left and/or right of the text (an icon-font glyph or an `ImageList` image — same idea as `TCWSMenuButton`). Full label event surface (`OnClick`, mouse, `OnMouseEnter` / `OnMouseLeave`, `OnContextPopup`). |

### Shapes

| Component | Description |
|-----------|-------------|
| **`TCWSShape`** | A lightweight, dependency-free graphic control (`TGraphicControl`, GDI+) that draws a rectangle, rounded rectangle or circle (`Shape`: `Rectangle` / `RoundRectangle` / `Circle`) with a fill (`Brush`) and an optional border (`Pen`). It is a building block the other CWStudio components are built on — e.g. `TCWSButton`, `TCWSStoreButton` and `TCWSMenuButton` use it (by composition) to render their rounded background — but it can just as freely be dropped straight onto a form. |
| **`TCWSAvatar`** | A circular, rectangular or rounded-rectangle avatar (`Shape`, `CornerRadius`, built on `TCWSShape`). Shows a picture (`Picture`), scaled into its area per `ImageFit` (`ifCover` — center-cropped to the area's aspect ratio, default; `ifContain` — whole picture visible, aspect preserved, background as letterboxing; `ifStretch` — stretched to fill the area, may distort; `ifCenter` — natural size, centered). The picture never spills past the shape's outline — its edge fades into the `Brush` background through a soft transparency gradient `ImageMargin` pixels wide (not a hard, all-or-nothing cut) — or, with no picture set, centered text such as initials in the given font and colour (`Caption`, `Font`). |

### Helper components

| Component | Description |
|-----------|-------------|
| **`TCWSDimOverlay`** | Dim-the-form layered overlay — perfect under modal dialogs. Supports Win11 rounded corners, fade-in/out animation, click blocking. Built-in activity indicator (loader) in 4 styles (`cisLines`, `cisRing`, `cisSegmented`, `cisArrows`) with smooth, frame-rate-independent animation — speed configurable via `IndicatorSpeed` (degrees/s, default 300). The animation runs on its own thread, so it keeps spinning even while the main thread is busy. Optional caption below the indicator. |
| **`TCWSAfterFormShow`** | Component that fires an `OnAfterShow` event once the form is fully painted after `Show` / `ShowModal`, also when maximized (but **not** on un-minimize). |
| **`TCWSHint`** | Replaces the standard hint of the **whole application** with a Windows 11 style bubble — drop one on the main form (`Active`). Rounded corners (`CornerRadius`), background and border colours (`Color`, `BorderColor`, `BorderThickness`), font (`Font`), padding and maximum width, soft shadow (`Shadow`, `ShadowSize`), show delay and display time (`HintPause`, `HintHidePause`, `HintShortPause`), action shortcuts in the text (`HintShortCuts`) and an `OnShowHint` event (change the text, position, timeout or colour of a single hint). Drawn like `TCWSPopupMenu` — a layered window that receives its finished bitmap before it is shown, so no background flash on show. |
| **`TCWSShadow`** | A soft, alpha-blended shadow for **any** control — drop it on the form and point `Control` at the control; the shadow puts itself under it on the same parent and follows its position, size and visibility (at design time too). Direction (`Direction`, degrees), offset (`Distance`), spread (`Size`, as in CSS), blur (`Softness`), opacity (`Opacity`) and colour (`Color`). Two modes: `smShape` (default) — shadow of the control's actual painted shape (text, a multi-line `TLabel` included, shapes, a transparent image), like CSS `drop-shadow()` or the FMX `TShadowEffect`, with a Gaussian blur; `smBox` — shadow of a rounded rectangle (`CornerRadius`), like CSS `box-shadow`; `IgnoreChildLabels` leaves captions out of it (e.g. a switch casts the shadow of its indicator only). A `TGraphicControl` painted on the parent's canvas, so the background and graphic controls show through it; clicks pass through the shadow. |

### Fluent color modules

| Unit | Description |
|------|-------------|
| **`CWSFluentColors`** | Full set of Fluent UI v9 color tokens (Light + Dark). Single callback on theme change (`FluentOnThemeChange`). |
| **`CWSFluentColorsMulti`** | Same token palette but supports **multiple** subscribers: `RegisterThemeChange` / `UnregisterThemeChange`. Each form or control can register its own handler. |
| **`CWSInteractiveUserTheme`** | Detects the theme (light / dark) of the **logged-on user** even when the process runs under the `NT AUTHORITY\SYSTEM` account (e.g. started by `ServiceUI.exe` from Intune / MDT), where `HKCU` belongs to the service account rather than to the user. `StartFollowingUserTheme` applies the theme and starts watching for changes, `StopFollowingUserTheme` stops it. |

> 🌗 **The theme follows the system** — the theme colors (light / dark) change automatically according to the Windows setting. The components listen for Windows theme changes (e.g. toggling *Settings → Personalization → Colors → Mode*) and repaint on the fly, and every registered handler is notified, so the whole app stays consistent with no restart.

#### Example — color module (`CWSFluentColorsMulti`)

```pascal
uses
  CWSFluentColorsMulti;

procedure TForm1.FormCreate(Sender: TObject);
begin
  RegisterThemeChange(HandleThemeChange);
  FluentApplySystemTheme;            // auto-detect from Windows registry
  HandleThemeChange;                 // first paint
end;

procedure TForm1.HandleThemeChange;
begin
  Color           := flNeutralBackground1;
  Label1.Font.Color := flNeutralForeground1;
  Invalidate;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  UnregisterThemeChange(HandleThemeChange);
end;
```

#### Example — logged-on user's theme (`CWSInteractiveUserTheme`)

The standard theme detection reads `HKCU`, so an application running under `NT AUTHORITY\SYSTEM` (e.g. started by `ServiceUI.exe` from Intune / MDT) gets the service account's settings rather than the logged-on user's — and always comes up light. This unit determines the interactive session and its SID, and reads `AppsUseLightTheme` straight from `HKEY_USERS\<SID>`.

```pascal
uses
  CWSFluentColorsMulti, CWSInteractiveUserTheme;

procedure TForm1.FormCreate(Sender: TObject);
begin
  RegisterThemeChange(ApplyTheme);   // registration only — the window has no handle yet
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  StartFollowingUserTheme;           // applies the theme and starts watching for changes
  ApplyTheme;                        // first paint — explicitly, do not rely on the callback
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  StopFollowingUserTheme;
  UnregisterThemeChange(ApplyTheme);
end;
```

> ⚠️ **Call `StartFollowingUserTheme` from `FormShow`, not from `FormCreate`** — in `FormCreate` the form's global variable is still `nil` and the window has no handle.

Diagnostics: set `ThemeLogEnabled := True` (or start the application with the `/themelog` switch) to write the detection trace to `%TEMP%\CWSTheme.log` (under SYSTEM: `C:\Windows\Temp`). `ThemeDiagnostics` returns the same state as ready-made text — process SID, session ids, user SID and the detected theme.

#### 🎨 Color swatch — `CWSFluentColors_palette.html`

The repository ships an interactive **color swatch** [`CWSFluentColors_palette.html`](CWSFluentColors_palette.html) — open it in a browser to browse every Fluent UI v9 token from `CWSFluentColors.pas` (Light and Dark variants). It lets you:

- filter tokens by name (e.g. `Brand`, `Background`, `Hover`),
- preview the palette on a light or dark page background (**Light / Dark** toggle),
- click a **swatch** to copy its color as HEX (`#0f6cbd`) or Delphi `TColor` (`$00BD6C0F`) — the **Copy as** toggle picks the format and also switches the values shown on the swatches; a right-click always copies the Delphi value,
- click a **token name** to copy the token name to the clipboard.

This makes it easy to pick and match the colors you set on component properties (e.g. `BorderColor`, `CellHighlightColor`, `BckHoverColor`, `FillColor`).

---

## 🔧 System requirements

- **Embarcadero Delphi / RAD Studio with the VCL framework.** The library was created and is developed in **RAD Studio 13.1 Florence** (compiler 37.0); RAD Studio 11 Alexandria or newer recommended.
- **Target platforms:** Win32 and Win64.
- **Operating system:**
  - **Windows 10** or newer to run your application (`TCWSDimOverlay` uses `WS_EX_LAYERED` layered windows and the DWM API).
  - **Windows 11 (build 22000) or newer** for the full Windows 11 look — `TCWSDimOverlay` (and other layered windows such as the `TCWSPopupMenu` shadow) uses `DWMWA_WINDOW_CORNER_PREFERENCE` to draw rounded corners. On older systems the components still work correctly, but corners stay square (graceful degradation).
- **No required third-party dependencies** — the packages link only against the standard `rtl` and `vcl`.
- **Icons** — the icon-bearing components (e.g. `TCWSButton`, `TCWSMenuButton`, `TCWSLabelTrend`) accept any standard `TCustomImageList` (the `Images` / `ImageIndex` properties) or an icon-font glyph. No extra libraries are needed.

---

## 🚀 Installation

The library is split into two packages (following the standard Delphi architecture). Built with **RAD Studio 13.1 Florence** (compiler 37.0).

| Package | File | Platforms | Role |
|---------|------|-----------|------|
| **Runtime** | `CWStudio_ComponentsRT.dpk` | Win32 + Win64 | Component code. Linked into applications, redistributable. **Not** installed into the IDE. |
| **Design-time** | `CWStudio_ComponentsDT.dpk` | Win32 + Win64 | Palette registration, the icon + name "CWStudio Component" on the IDE splash screen and About Box. Requires the runtime package. |

#### 1. Build the packages (runtime before design-time, for both platforms)

1. Open the **`CWStudio_Components.groupproj`** project group in RAD Studio.
2. Select the **Win32** platform, then:
   - right-click **`CWStudio_ComponentsRT`** → **Build**,
   - right-click **`CWStudio_ComponentsDT`** → **Build**.
3. Switch the platform to **Win64** and repeat both builds (the runtime is redistributed for 64-bit apps too).

   Or from the command line (after `rsvars.bat`):
   ```bat
   msbuild CWStudio_Components.groupproj /t:Build /p:Config=Release /p:Platform=Win32
   msbuild CWStudio_Components.groupproj /t:Build /p:Config=Release /p:Platform=Win64
   ```

#### 2. Install the design-time package

Right-click **`CWStudio_ComponentsDT`** → **Install**. Then:

- the components appear on the palette under **CWStudio_Panels / _Buttons / _Edits / _ProgressBars / _Menus / _ScrollBoxes / _Forms / _ListBoxes / _Grids / _Labels**.

#### 3. Add the library paths

So your applications compile against the components, in **Tools → Options → Language → Delphi → Library** (for **each** platform: Win32 and Win64) add the folder containing the `.dcu` files (the source folder, or `.\Win32\Release` / `.\Win64\Release`) to the **Library path**. Adding the source folder to the **Browsing path** lets you step into the component code while debugging.

### 🧩 Using it in an application & redistribution

- **Without runtime packages** (default — *Link with runtime packages = false*): the components are statically linked into the `.exe`. Nothing extra to ship.
- **With runtime packages**: add `CWStudio_ComponentsRT` to the project's *Runtime Packages* and ship `CWStudio_ComponentsRT.bpl` (Win32 or Win64) plus the dependency `.bpl`s alongside your app. The **design-time package is not** needed by end users.

### 🛠️ Troubleshooting

- **`F2039: Could not create output file ...bpl`** — the package is currently loaded in the IDE. Uninstall it (**Component → Install Packages**) or close RAD Studio before building from the command line.
- **`E2466: Never-build package requires always-build package`** — CWStudio packages use `{$IMPLICITBUILD ON}`. Do **not** set the design-time package to `{$IMPLICITBUILD OFF}`.
- **`unit ... already in package ...`** — an older, combined CWStudio package is still installed. Uninstall it (**Component → Install Packages**) before installing the RT/DT pair.

---

## 🖥️ Demo application

The [`CWStudio_demo`](CWStudio_demo) folder contains a sample VCL application (`demo.dproj`) that shows the components in action — buttons, edits, panels, grids and lists, progress indicators, scroll boxes, the system menu, the dim overlay with a dialog, and light / dark theme switching through `CWSFluentColorsMulti`. The sidebar is built from `TCWSStoreButton`s, and each page is a separate form embedded in the content area.

**Demo requirements:**

- the CWStudio packages installed (see [🚀 Installation](#-installation)),
- [**SVGIconImageList**](https://github.com/EtheaDev/SVGIconImageList) — the icons on the demo forms (`TSVGIconImageList`). The CWStudio components themselves do **not** need this library.

Since version 1.9.25 the demo **no longer depends on ErrorSoft components** (EsVclComponents) — `TEsShape` on the main form was replaced by a `TCWSSettingsPanel`, and the unused `ES.*` units were removed from the uses clauses.

Open `CWStudio_demo\demo.dproj`, pick the Win32 or Win64 platform and run it (**F9**).

---

## ⚖️ Attribution

When using these components, please include appropriate attribution in your application (e.g., in the About box):

> *"This application uses CWStudio components by Czesław Włudarczyk"*

---

## 🗓️ What's new

**Latest release — 1.9.33:**

- **Fixed** `TCWSAfterFormShow`: **form show detection now uses `CM_SHOWINGCHANGED`** instead of `WM_SHOWWINDOW` / `WM_SIZE` / `WM_PAINT`. `OnAfterShow` now also fires for a form shown maximized, and still not on un-minimize. The helper thread checks `IsWindow` before posting, so a form closed before the application goes idle is no longer sent a message to a destroyed window.

The full change history is kept in [`CHANGELOG.md`](CHANGELOG.md).

---

## ❤️ Support the author

If you find CWStudio useful and would like to support the ongoing development of the library, you can buy me a coffee or make a donation. Every contribution helps keep the project alive and growing:

<div align="center">

<a href="https://paypal.me/czeslaw80">
  <img src="https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif" alt="Donate via PayPal" />
</a>

**[💛 paypal.me/czeslaw80](https://paypal.me/czeslaw80)**

</div>

---

## 📄 License

The library is released under the **MIT** license — you may use, modify, and redistribute it in any project, commercial or non-commercial, provided that the copyright notice and attribution are preserved (see the [⚖️ Attribution](#️-attribution) section and the [`LICENSE`](LICENSE) file).

<br>

<div align="center">

<img src="Gfx/CWStudioLogo.png" alt="CWStudio" width="72" height="72" />

**Zrobione z ❤️ do Delphi · Made with ❤️ for Delphi**

*by [Czesław Włudarczyk](https://paypal.me/czeslaw80)*

</div>

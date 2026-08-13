<div align="center">

# CWStudio Components Library

**Nowoczesne komponenty VCL w stylu Windows 11 / WinUI 3 dla Delphi**

*Modern Windows 11 / WinUI 3 styled VCL components for Delphi*

[![Version: 1.7.5](https://img.shields.io/badge/version-1.7.5-blue.svg)](CHANGELOG.md)
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
| **`TCWSDBGrid`** | Siatka **danych** (DBGrid) w stylu Fluent — opakowuje wewnętrzny `TDBGrid`, więc zachowuje jego pełny interfejs (`DataSource`, `Columns`, `Options`, zdarzenia `OnDrawColumnCell` / `OnCellClick` / `OnTitleClick` itd.). Fluentowe paski przewijania (pionowy + poziomy), konfigurowalne kolory (tło, komórki, tekst, linie siatki, komórki *fixed*, podświetlenie), **sortowanie kliknięciem w nagłówek** z obsługą wielu kolumn i wskaźnikami w tytule (`SortEnabled`, `MultiSortMode`, `MaxSortColumns`, `SortBy` / `ClearSort`, `OnSortApply`), naprzemienne kolorowanie wierszy liczone po rekordach (`AlternatingRowColors` + `OddRowColor` / `EvenRowColor`), zaokrąglone narożniki z możliwością wyłączenia każdego z osobna, automatyczne dopasowanie szerokości kolumn (`AutoFitColumns`), regulowana wysokość wiersza i nagłówka oraz pionowe wyśrodkowanie tekstu. |

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

### Etykiety

| Komponent | Opis |
|-----------|------|
| **`TCWSLabelColumn`** | Dwukolumnowa etykieta — dwa niezależne teksty obok siebie (lewa / prawa kolumna), każdy z własną czcionką (`LeftFont` / `RightFont`), wyrównaniem i szerokością. Automatyczny *marquee*, gdy tekst nie mieści się w kolumnie (`ScrollColumns`, osobne prędkości `LeftScrollStep` / `RightScrollStep`, miękkie wygaszanie krawędzi `EdgeFade`) — bez migotania (rysuje się bezpośrednio, bez `Invalidate`). |
| **`TCWSLabelTrend`** | Etykieta w stylu „pigułki" / badge (kolorowe tagi statusu, np. Lead / POC / Closed) — kapsułka GDI+ z wypełnieniem (`Color`) i opcjonalną ramką, auto-rozmiar do treści. Ikona po lewej i/lub prawej stronie tekstu (glyph z fontu ikon lub obraz z `ImageList` — jak w `TCWSMenuButton`). Pełen zestaw zdarzeń etykiety (`OnClick`, mysz, `OnMouseEnter` / `OnMouseLeave`, `OnContextPopup`). |

### Komponenty pomocnicze

| Komponent | Opis |
|-----------|------|
| **`TCWSDimOverlay`** | Warstwa przyciemniająca formularz (layered window) — idealna pod modalne dialogi. Wsparcie zaokrąglonych narożników Win11, animacja fade-in/out, blokowanie kliknięć. Wbudowany wskaźnik aktywności (loader) w 4 stylach (`cisLines`, `cisRing`, `cisSegmented`, `cisArrows`) z płynną, niezależną od FPS animacją — prędkość konfigurowalna przez `IndicatorSpeed` (stopnie/s, domyślnie 300). Animacja działa we własnym wątku, więc kręci się nawet gdy główny wątek jest zajęty. Opcjonalny tekst pod wskaźnikiem. |
| **`TCWSAfterFormShow`** | Komponent emitujący zdarzenie `OnAfterShow` po pełnym wyrenderowaniu formularza (po `Show` / `ShowModal`, ale **nie** po przywróceniu z minimalizacji). |

> ℹ️ **`TCWSShape`** *(`CWSShape.pas`)* — lekka, bezzależnościowa kontrolka graficzna (GDI+) rysująca prostokąt lub zaokrąglony prostokąt z wypełnieniem (`Brush`) i opcjonalną ramką (`Pen`). Stanowi wewnętrzny **element bazowy**, na którym opierają się inne komponenty CWStudio — m.in. `TCWSButton`, `TCWSStoreButton` i `TCWSMenuButton` używają jej (przez kompozycję) do rysowania zaokrąglonego tła. **Nie jest rejestrowana na palecie** — to budulec dla innych komponentów, a nie kontrolka do samodzielnego upuszczania na formularz.

### Moduły kolorów Fluent

| Unit | Opis |
|------|------|
| **`CWSFluentColors`** | Pełen zestaw tokenów kolorystycznych Fluent UI v9 (Light + Dark). Pojedynczy callback przy zmianie motywu (`FluentOnThemeChange`). |
| **`CWSFluentColorsMulti`** | Ta sama paleta tokenów, ale z obsługą **wielu** subskrybentów: `RegisterThemeChange` / `UnregisterThemeChange`. Każda forma lub kontrolka rejestruje własny handler. |

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

#### 🎨 Wzornik kolorów — `CWSFluentColors_palette.html`

W repozytorium znajduje się interaktywny **wzornik kolorów** [`CWSFluentColors_palette.html`](CWSFluentColors_palette.html) — otwórz go w przeglądarce, aby przejrzeć wszystkie tokeny Fluent UI v9 z `CWSFluentColors.pas` (warianty Light i Dark). Pozwala on:

- filtrować tokeny po nazwie (np. `Brand`, `Background`, `Hover`),
- podejrzeć paletę na jasnym i ciemnym tle (przełącznik **Light / Dark**),
- kliknięciem **próbki** skopiować kod HEX, a kliknięciem **nazwy** — nazwę tokena do schowka.

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

## ⚖️ Wymagane przypisanie autorstwa

Używając tych komponentów, proszę o umieszczenie odpowiedniej informacji w swojej aplikacji (np. w oknie „O programie"):

> *„Ta aplikacja wykorzystuje komponenty CWStudio autorstwa Czesława Włudarczyka"*

---

## 🗓️ Historia wersji

**Najnowsza wersja — 1.7.5:**

- **Zmiana** `TCWSStoreButton` — **przycisk nie wymaga już Skii.** W 1.7.4 został przepisany na `TSkCustomControl`, a ten jeden komponent wciągał `Skia.Package.RTL` / `Skia.Package.VCL` do `requires` pakietu runtime — więc Skia4Delphi musiała być obecna w każdej aplikacji linkującej bibliotekę i w każdym IDE, które ją instaluje, niezależnie od tego, czy przycisk był w ogóle używany. Komponent wraca na renderowanie GDI+, z którego korzysta reszta biblioteki (`TCWSShape` na tło i wskaźnik aktywności, `TPaintBox` na ikonę, `TLabel` na opis), a oba pakiety Skii znikają z `requires`. **Biblioteka znów nie ma żadnej zależności poza standardowym VCL.**
- **Bez zmian** — to zmiana wyłącznie w warstwie rysowania: opublikowane właściwości są identyczne jak w 1.7.4 (te same nazwy, te same wartości domyślne), tak samo animacja wskaźnika aktywności wraz z kierunkiem, z którego rośnie w obrębie `GroupIndex`, i jej czasem. `OnClick` / `OnMouseEnter` / `OnMouseLeave` / `OnMouseDown` / `OnMouseUp` działają jak dotąd. Istniejące pliki `.dfm` wczytują się bez żadnej zmiany.
- **Uwaga** — podniesiona jest wersja biblioteki, nie przycisku: praca nad sortowaniem i listą wydana w 1.7.4 (`TCWSDBGrid`, `TCWSListBox`) pozostaje nietknięta.

**Wersja 1.7.4:**

- **Nowość** `TCWSDBGrid` — **sortowanie kliknięciem w nagłówek kolumny**: `SortEnabled`, domyślnie wyłączone, więc istniejąca siatka zachowuje się dokładnie jak dotąd. Kliknięcie przechodzi cykl rosnąco → malejąco → bez sortowania, a posortowany nagłówek pokazuje trójkąt (`SortArrowColor`, `SortIndicatorSize` w pikselach logicznych 96 DPI) oraz — przy sortowaniu po kilku kolumnach — numer poziomu sortowania liczony od 1 (`SortNumberColor`, `ShowSortNumber` = `snmMultiColumn` / `snmAlways` / `snmNever`). Miejsce na wskaźnik jest rezerwowane przed narysowaniem tytułu, więc długi tytuł jest przycinany wielokropkiem przed trójkątem, a nie wchodzi pod niego. **`dgTitleClick` nie jest potrzebne**: `TCustomDBGrid` woła `TitleClick` przy każdym kliknięciu w komórkę nagłówka, a ta opcja bramkuje jedynie zdarzenie `OnTitleClick`. Sortowanie idzie pierwsze, więc handler `OnTitleClick` widzi już nowy stan sortowania.
- **Nowość** `TCWSDBGrid` — **sortowanie po wielu kolumnach**: `MaxSortColumns` (domyślnie 3) i `MultiSortMode`: `msmCtrlClick` (zwykłe kliknięcie zaczyna nowe sortowanie po jednej kolumnie, Ctrl+klik dokłada kolejny poziom — tak jak w Eksploratorze Windows) albo `msmAlways` (każde kliknięcie w nieposortowaną kolumnę dokłada poziom). Po osiągnięciu limitu ustępuje poziom najmniej znaczący, więc kliknięcie nigdy nie zostaje po cichu zignorowane.
- **Nowość** `TCWSDBGrid` — interfejs sortowania w czasie działania: `SortBy`, `ToggleSortColumn`, `ClearSort`, `ApplySort` (ponowne nałożenie sortowania po otwarciu zbioru danych), `SortOrderBy` (bieżące sortowanie jako treść ORDER BY: `'PRICE ASC, NAME DESC'`), `SortLevelOf`, `SortDirectionOf`, `SortColumnCount` i `SortColumns[]`. Stan sortowania zależy od żywych danych i celowo nie trafia do `.dfm`.
- **Nowość** `TCWSDBGrid` — `OnSortApply` wywoływane **zanim** siatka dotknie zbioru danych, z gotową treścią ORDER BY. Ustaw `AHandled` po samodzielnym ponowieniu zapytania, a siatka zostawi zbiór danych w spokoju i tylko przemaluje wskaźniki. `SortAutoApply = False` prowadzi całe sortowanie wyłącznie tą drogą. `OnSortChanged` wywoływane po zmianie i nałożeniu sortowania.
- **Nowość** `TCWSDBGrid` — zostawiona sama sobie, siatka porządkuje dane **przez własny indeks zbioru danych**, i to bez żadnej zależności modułu poza `Data.DB` — rodzina zbioru danych jest rozpoznawana i sterowana przez RTTI. FireDAC (kolekcja `Indexes`, której elementy mają `Expression`) dostaje `IndexFieldNames` z przyrostkiem `:D` dla kierunku malejącego; rodzina `ClientDataSet`, w której `IndexFieldNames` sortuje wyłącznie rosnąco, dostaje `AddIndex` z jawną listą pól malejących. Własne uporządkowanie zbioru danych (`IndexFieldNames` / `IndexName`) jest zapamiętywane raz, tuż przed pierwszym nadpisaniem, i oddawane przy czyszczeniu sortowania — dzięki temu wyczyszczenie przywraca indeks ustawiony przez aplikację, zamiast go wyzerować, a cofane jest wyłącznie uporządkowanie nałożone przez samą siatkę.
- **Nowość** `TCWSDBGrid` — **kolumna tekstowa ze znacznikami daty i czasu** (`'05.12.2026 09:30'`) sortuje się **chronologicznie, a nie alfabetycznie**: zwykły indeks tekstowy stawia 01.02.2025 przed 20.07.2024. Układ jest wykrywany przez próbkowanie danych (`TCWSSortValueKind` = `svkDateTimeText`), klucz sortowania adresujący składowe na ich stałych pozycjach budowany jest jako wyrażenie indeksu, a wynikowa kolejność jest następnie weryfikowana na danych: jeśli układ odczytany z próbki nie trzyma się dla każdego wiersza — wartości bez wiodących zer, `'1.2.2026'` obok `'10.12.2026'` — klucz jest porzucany na rzecz zwykłego indeksu, zamiast zostawiać dane w kolejności, która tylko wygląda na posortowaną. Wymaga indeksów wyrażeniowych (FireDAC) i jednej sortowanej kolumny; przy sortowaniu wielokolumnowym taka kolumna wraca do zwykłego porządku tekstowego.
- **Nowość** `TCWSDBGrid` — `SortIsExact`: False, gdy automatyczne sortowanie zbioru danych nie mogło w pełni spełnić żądania — poziom malejący na zbiorze, którego indeks nie obsługuje kierunku malejącego, albo kolumna z datą w tekście, która musiała wrócić do porządku tekstowego. Strzałka nadal pokazuje intencję; na takie przypadki jest `OnSortApply`.
- **Poprawka** `TCWSDBGrid` — **poszerzenie siatki przewiniętej w prawo nie zostawia już ukrytych lewych kolumn** i pustego miejsca przy prawej krawędzi, podczas gdy pasek przewijania poprawnie melduje, że nie ma już czego przewijać. Zwykła siatka cofa `LeftCol` w `TCustomGrid.UpdateScrollRange`, które wychodzi natychmiast przy `ScrollBars = ssNone` — a wewnętrzna siatka ma dokładnie to ustawienie właśnie po to, żeby nigdy nie pojawił się natywny pasek, więc cofnięcie nigdy nie następowało. Komponent przycina teraz lewą kolumnę sam, do najbardziej lewej przewijalnej kolumny, której ogon nadal mieści się w widocznej szerokości (pozycja dosunięcia do prawej).
- **Poprawka** `TCWSListBox` (`MultiSelect`) — **przeciąganie wielu zaznaczonych pozycji nie redukuje już zaznaczenia do tej jednej, na której naciśnięto.** Wciśnięcie bez modyfikatora na pozycji, która *już* jest zaznaczona, jest niejednoznaczne: może zaczynać przeciąganie całego zaznaczenia albo być zwykłym kliknięciem redukującym je do jednej pozycji. Natywny listbox rozstrzyga to od razu, w chwili wciśnięcia — redukuje — więc rozpoczęte potem przeciąganie niosło jedną pozycję niezależnie od tego, ile było zaznaczonych. Ten `WM_LBUTTONDOWN` jest teraz przechwytywany, natywna obsługa wstrzymana, a gest rozstrzygany samodzielnie: ruch powyżej `Mouse.DragThreshold` zaczyna przeciąganie z **nietkniętym** zaznaczeniem, a zwolnienie w miejscu redukuje je do klikniętej pozycji, dokładnie jak Eksplorator Windows. Cały gest chodzi na własnym przechwyceniu myszy, więc nie zależy ani od tego, kiedy VCL wywoła `DoStartDrag` (to nie jest wiarygodny sygnał „zaczęto przeciąganie" — VCL woła je również po zwykłym kliknięciu), ani od tego, czy `MouseUp` w ogóle dotrze. Przechwytywany jest wyłącznie przypadek niejednoznaczny: kliknięcia z `Ctrl` / `Shift`, naciśnięcie na niezaznaczonej pozycji lub w pustym miejscu, lista bez `MultiSelect` i tryb projektowania idą natywną ścieżką bez zmian. Utrata przechwycenia (`WM_CAPTURECHANGED` — Alt+Tab, komunikat systemowy) przerywa gest.
- **Poprawka** `TCWSListBox` — lista **dostaje fokus, gdy naciśnięcie rozpoczyna przeciąganie.** Wchodząc w ścieżkę auto-draga VCL pomija nadanie fokusu towarzyszące zwykle kliknięciu, przez co lista zostawała nieaktywna: rysowanie uzależnione od `Focused` nie pokazywało zaznaczenia, a klawiatura trafiała gdzie indziej. Fokus nadawany jest *przed* przechwyceniem myszy, bo zmiana aktywnej kontrolki przechodzi przez `SendCancelMode`, które przechwycenie by zwolniło; domykany jest w `MouseUp`, a gdy po dropie `MouseUp` już nie dociera — w `DoEndDrag`, ale tylko wtedy, gdy przeciąganie nie skończyło się na innej kontrolce, której fokus oddano świadomie.
- **Poprawka** `TCWSListBox` — `DragMode` jest przywracany również w `DoEndDrag`. Komponent parkuje go na `dmManual` na czas naciśnięcia, które nie może zacząć przeciągania (reguła: przeciąganie tylko z zaznaczonej pozycji); jeśli `MouseUp` nie wrócił — a drop go pochłania — lista zostawała nieprzeciągalna na stałe.
- **Poprawka** `TCWSListBox` — redukcja zaznaczenia do jednej pozycji idzie przez `LB_SETSEL` i `LB_SETCARETINDEX`, a nie przez właściwość `ItemIndex`, której setter w trybie `MultiSelect` potrafi wyczyścić zaznaczenie, zanim ustawi karetkę — przy okazji jedno przemalowanie zamiast jednego na pozycję.
- **Zmiana** `TCWSListBox` — **sloty zdarzeń wewnętrznej listy są znowu wolne.** Komponent docierał dotąd do własnych handlerów, zajmując je (`FListBox.OnClick := ListBoxClick` i tak samo dla pozostałych dziewięciu) — a slot mieści dokładnie jeden handler, więc przypisanie czegokolwiek na `ListBox.OnClick` z zewnątrz po cichu wyrzucało handler komponentu razem z pracą, którą on tam wykonuje: odświeżeniem paska przewijania, tłem stanu, przemalowaniem. Te zdarzenia są teraz przekazywane przez **override'y** w `TCWSInternalListBox` (`Click`, `DblClick`, `KeyDown` / `KeyUp` / `KeyPress`, `DoEnter`, `DoExit`, `DoContextPopup`, `DrawItem`, `MeasureItem`), które nic nie zajmują: sloty zostają do dyspozycji użytkownika, a komponent i tak dostaje swoje wywołanie. Ciała handlerów nie zmieniły miejsca — zmieniło się tylko to, skąd są wołane. Dwa wyjątki świadomie zostają na slotach: `OnData` / `OnDataFind` / `OnDataObject`, dla których VCL nie daje wirtualnego haka (`TCustomListBox.DoGetData` i spółka nie są virtual), oraz ścieżka myszy (`OnMouseDown` / `OnMouseMove` / `OnMouseUp`), nietknięta, bo jest spleciona z auto-dragiem VCL. `DrawItem` jest jedynym override'em, który przy podpiętym komponencie nie woła `inherited` — owner-draw należy do komponentu w całości: maluje tło stanu, a potem oddaje rysowanie do `OnDrawItem` albo rysuje domyślnie, dokładnie tak jak dotąd ze slotu.

**Wersja 1.7.3:**

- **Zmiana** `TCWSScrollBox` (`srmShaped`) — wygładzone końce suwaka są teraz wtapiane w **piksele, które naprawdę leżą pod paskiem**, a nie w `BackgroundColor`. Pasek odtwarza je sam: host przewijanej treści i stojące na nim kontrolki rysują się do jego bufora składania (`WM_PRINTCLIENT` / `WM_PRINT`) — to samo, co kompozytor robi warstwie półprzezroczystej, tyle że pasek ani na chwilę nie staje się oknem warstwowym. Dzięki temu zaokrąglone narożniki pozostają gładkie tam, gdzie suwak przechodzi nad **obrazkiem albo osadzoną kontrolką**, zamiast ciągnąć za sobą półksiężyc w kolorze tła. Korpus paska jest przy tym **kryjący** — `ScrollThumbColor` zmieszany z `BackgroundColor` wg `ScrollThumbAlpha`, nic przez niego nie prześwituje — miękkie są wyłącznie **końce**. Nowa metoda `RefreshScrollbars` na rzadkie przemalowania, których komponent nie jest w stanie zauważyć.
- **Zmiana** `TCWSScrollBox` — suwak jest **wyśrodkowany w swoim pasie**, z jednakowym marginesem po obu stronach w obrębie `ScrollbarAreaWidth`, zamiast przylegać do prawej krawędzi boksa (pasek pionowy) lub dolnej (poziomy). Pogrubienie przy najechaniu (`ScrollbarThumbHoverWidth`) jest symetryczne: grubość jest dociągana do parzystości pasa, żeby linia środkowa suwaka nie przesunęła się o pół piksela w chwili wejścia kursora — bo to wyglądałoby, jakby suwak drgał na boki. Przy domyślnych 14 / 4 / 6 (i każdym całkowitym przeskalowaniu DPI) parzystości i tak się zgadzają i nic nie jest korygowane.
- **Nowość** `TCWSScrollBox` — pasek **pogrubia się, gdy kursor jest gdziekolwiek w jego pasie**, a nie tylko dokładnie na suwaku, więc wyśrodkowany suwak jest równie łatwy do trafienia, jak wcześniej przyklejony do krawędzi. Musi to być śledzenie kursora, a nie okno: w `srmShaped` okno paska *jest* suwakiem, a okno pokrywające resztę pasa musiałoby go zamalować. Nasłuchiwanie ruchów myszy też odpada, bo nad kontrolką potomną nigdy nie docierają one do boksa. Boks uzbraja więc śledzenie, gdy kursor wejdzie nad niego **lub cokolwiek w nim zagnieżdżonego** (`CM_MOUSEENTER` wędruje w górę łańcucha rodziców) i odpytuje pozycję kursora, dopóki nie wyjdzie.
- **Nowość** `TCWSScrollBox` (`srmShaped`) — **cały pas jest klikalny, gdy kursor na nim stoi**: naciśnięcie obok suwaka zaczyna jego przeciąganie, nad nim lub pod nim — przeskok. Wcześniej dało się nacisnąć wyłącznie sam suwak, więc odstęp między nim a krawędzią boksa był martwy: pasek grubiał pod kursorem, ale nie dawał się ruszyć. Region zwykłego okna wyznacza jednocześnie jego piksele i strefę trafienia myszy, dlatego naciśnięcie jest **przechwytywane w pętli komunikatów, zanim zostanie dostarczone**, i przekazywane paskowi — obok suwaka zaczyna przeciąganie i przejmuje mysz, więc reszta gestu dociera już zwykłą drogą. Nic nie jest zakrywane. Naciśnięcie pasa celowo **nie** przenosi fokusu.
- **Poprawka** `TCWSScrollBox` (`srmShaped`) — zaokrąglone końce suwaka nie zachowują już koloru kontrolki, która zdążyła się pod nim zmienić. Zaznaczenie i odznaczenie `TCWSStoreButton` za paskiem zostawiało kolor zaznaczenia w wygładzonych końcówkach. Nic nie mogło o tym powiadomić: zmierzone na tej kontrolce przemalowanie idzie przez `Repaint`/`UpdateWindow`, co wysyła `WM_PAINT` wprost do okna, z pominięciem kolejki komunikatów — żaden filtr tego nie zobaczy. Paski odczytują więc tło pod sobą kilka razy na sekundę, ale wyłącznie gdy kursor jest w boksie (tylko wtedy widać nieaktualność), tylko dla paska faktycznie nachodzącego na treść i dodatkowo raz w chwili wejścia kursora. Pasek nad zwykłym tłem nie robi nic.
- **Poprawka** `TCWSScrollBox` (`srmShaped`) — kontrolka pod pasem nie podświetla się już, gdy kursor stoi na scrollbarze. Ruchy myszy nad pasem są połykane, a to, co było pod kursorem, dostaje `WM_MOUSELEAVE`, żeby porzuciło wzięte podświetlenie. Ten komunikat, a nie `CM_MOUSELEAVE` bezpośrednio — VCL wysyła *enter* tylko przy zmianie śledzonej kontrolki, więc zgaszenie podświetlenia bez wyczyszczenia księgowości za nim zostawiłoby kontrolkę na zawsze niezdolną do zapalenia się. Nic nie jest połykane, gdy jakikolwiek gest trzyma przechwyconą mysz, więc przeciąganie splittera czy zaznaczanie tekstu przechodzące nad pasem zostaje nietknięte.
- **Poprawka** `TCWSScrollBox` (`srmShaped`) — koniec ze smugą na scrollbarze po najechaniu na sąsiadującą kontrolkę. Zjazd kursorem z kontrolki zmieniającej wygląd pod kursorem na scrollbar zostawiał pas jej *poprzedniego* wyglądu. Pasek rozszerzał wcześniej swoje okno na cały pas, żeby dało się w niego kliknąć, a piksele zakryte przez okno to zamrożony zrzut. Pasek nie zakrywa już pasa w żadnym stanie, a kliknięcia są przechwytywane przed dostarczeniem. Treść pod pasem pozostaje żywa.
- **Poprawka** `TCWSScrollBox` — maksymalizacja i przywrócenie okna nie odsyła już treści na sam początek. Najbardziej widoczne przy `Align = alClient`: gdy widok urośnie na tyle, że treść się mieści, nie ma czego przewijać, a offset był przycinany *w miejscu* — przywrócenie okna oddawało miejsce do przewijania, ale nie miało już skąd odtworzyć pozycji. Boks zapamiętuje teraz pozycję, do której **przewinięto**, i z niej wyprowadza efektywny offset przy każdym układaniu. Dotyczy obu osi.

**Wersja 1.7.2:**

- **Nowość** `TCWSScrollBox` — tryb renderowania **`srmShaped`**, od teraz domyślny dla `ScrollbarRenderMode`. To model WinUI 3 / Windows 11: pasek nie ma toru w ogóle — jego okno JEST zaokrąglonym suwakiem (przycięte przez `SetWindowRgn`), a na reszcie pasa nie ma żadnego okna, więc treść pod nim zostaje nietknięta, dokładnie tak, jakby tor był przezroczysty. Jako zwykłe okno potomne jest komponowany przez Windows razem z rodzicem, więc nie miga ani nie zostaje w tyle za krawędzią przy zmianie rozmiaru formatki. Zaokrąglone końce nadal są wygładzane per piksel: region przycina tylko narożniki, a obwódka kapsuły jest wtapiana w `BackgroundColor`.
- **Usunięcie** `TCWSScrollBox` — tryb **`srmLayered`**. Okno potomne `WS_EX_LAYERED` DWM komponuje we własnym rytmie, co powodowało miganie i „pływanie" paska przy zmianie rozmiaru — obchodzone dotąd „parkowaniem" warstwy na czas przeciągania ramki. Kosztował też na krok przewijania znacznie więcej, niż był wart: jego przesunięcie wymuszało przemalowanie przewijanej treści pod spodem. `srmShaped` daje ten sam efekt „tor nie zasłania treści" bez warstwy, więc tryb, cała maszyneria parkowania i podklasowanie formatki, które ją napędzało, odchodzą razem z nim. **Zmiana łamiąca:** `.dfm` z zapisanym `ScrollbarRenderMode = srmLayered` się nie wczyta — wpisz `srmShaped` (najbliższy odpowiednik) lub `srmBlended`, albo usuń linię, żeby wziąć domyślny.
- **Zmiana** `TCWSScrollBox` — **znacznie szybsze przewijanie przy dużych bitmapach i wielu kontrolkach.** Cztery rzeczy sprawiały, że pojedynczy klik kółka kosztował przemalowanie całej treści, i żadna już tego nie robi. Host treści nie jest już `DoubleBuffered` w rozumieniu VCL — to alokowało i blitowało bitmapę wielkości *treści*, nie widoku, przy każdym malowaniu, i przy okazji przerysowywało każdą kontrolkę graficzną; teraz buforuje do bitmapy wielkości prostokąta odświeżenia, z ustawionym klipem, dzięki czemu VCL pomija wszystko poza pasmem. Region przycinający treść przy ramce jest zakładany przed przesunięciem i bez wymuszonego odrysowania, bo widoczny prostokąt i tak się nie zmienia. Suwak odświeża się raz na krok zamiast dwa razy. A suwak `srmShaped`, który tylko się PRZESUNĄŁ, nie jest przemalowywany wcale — piksele jadą razem z oknem — natomiast `srmBlended` przemalowuje jedynie stary i nowy prostokąt suwaka zamiast całego pasa. Pasek komponuje się w jednym, wielokrotnie używanym DIB-ie zamiast alokować nowy na każde malowanie.
- **Zmiana** `TCWSScrollBox` — suwak **przylega do krawędzi swojego paska**: 1 px od prawej krawędzi boksa dla paska pionowego i 1 px od dolnej dla poziomego, zamiast wisieć na środku pasa o szerokości `ScrollbarAreaWidth`. Ten 1 px należy do paska, nie do treści — w obu trybach renderowania leży wewnątrz okna paska, więc dojechanie kursorem do samej krawędzi boksa już liczy się jako najechanie na scrollbar. Pogrubienie przy hoverze (`ScrollbarThumbHoverWidth`) rozszerza dzięki temu suwak wyłącznie do środka i krawędź, za którą wodzi oko, stoi w miejscu — co przy okazji likwiduje dopasowywanie parzystości, które pilnowało, żeby wyśrodkowany suwak nie rósł krzywo.

**Wersja 1.7.1:**

- **Nowość** `TCWSScrollBox` — właściwość **`ScrollbarRenderMode`** decydująca o sposobie osadzenia pływającego paska. `srmLayered` (domyślnie, zachowanie jak dotąd) trzyma pasek jako okno warstwowe `WS_EX_LAYERED`, więc przewijana treść **prześwituje** przez przezroczysty tor. `srmBlended` rezygnuje z warstwy: pasek jest zwykłym oknem potomnym, tor wypełnia `BackgroundColor`, a suwak rysowany jest kolorem `ScrollThumbColor` zmieszanym z tym tłem wg `ScrollThumbAlpha`. `srmBlended` warto włączyć na formatkach zmieniających rozmiar — najbardziej widać to przy `Align = alClient`, gdzie warstwowy pasek miga i zostaje w tyle za krawędzią okna podczas przeciągania ramki; tak DWM komponuje warstwowe okno potomne i z poziomu komponentu nie da się tego naprawić. Kompromis: treść leżąca pod paskiem jest przez niego zasłonięta zamiast prześwitywać — przy typowym ustawieniu (tło scrollboksa = tło treści) różnicy nie widać.
- **Poprawka** `TCWSScrollBox` (`srmBlended`) — kwadrat w prawym dolnym rogu, w miejscu spotkania obu pasków, nie jest już dziurą wyciętą z pasa. Oba paski były skracane o szerokość paska, więc ten kwadrat nie należał do żadnego z nich — niewidoczne przy przezroczystym torze `srmLayered`, ale rzucające się w oczy, gdy tor jest kryjący. Róg przejmuje teraz pasek pionowy, a jego suwak nadal zatrzymuje się dokładnie tam, gdzie zaczyna się pasek poziomy.
- **Zmiana** `TCWSScrollBox` — podgląd w projektancie podąża za trybem renderowania, więc przełączenie `ScrollbarRenderMode` widać od razu w IDE: `srmLayered` przycina okno paska do zaokrąglonego suwaka (treść prześwituje przez tor), `srmBlended` pokazuje kryjący pas razem z rogiem. Suwak jest też podglądany w kolorze, jaki naprawdę wychodzi na ekranie (`ScrollThumbColor` zmieszany z tłem wg `ScrollThumbAlpha`), zamiast w pełni kryjącym.
- **Zmiana** `TCWSScrollBox` — w `srmLayered` piksele paska trafiają do warstwy przez `UpdateLayeredWindow` (pozycja, rozmiar i zawartość w jednym wywołaniu) zamiast przez `WM_PAINT` z kluczem koloru. Suwak ma dzięki temu prawdziwą alfę per-piksel, więc jego zaokrąglone końce są wygładzone.

**Wersja 1.7.0:**

- **Zmiana** — przycisk hasła w `TCWSEdit` i `TCWSEditMask` (`ebsPassword` / `embsPassword`) działa teraz jak w WinUI 3: hasło jest widoczne **tylko podczas trzymania** przycisku, a po puszczeniu wraca maskowanie (wcześniej klik przełączał i hasło zostawało na ekranie). Maskowanie wraca też, gdy puścisz przycisk poza nim oraz przy utracie capture bez puszczenia (okno modalne, Alt+Tab, Esc). Odsłanianie zachowuje czcionkę, karetkę i zaznaczenie pola. `OnButtonClick` odpala się jak dotąd, pozostałe style przycisku bez zmian.
- **Poprawka** — zaokrąglone narożniki nie pokazują już trójkąta w złym kolorze, gdy rodzic nie maluje się jednolitym wypełnieniem własnego `Color` (kontener rysujący kartę / gradient, formatka ze stylem VCL, rodzic z `Color` rozjechanym z tym, co faktycznie maluje). Obszar poza zaokrągleniem jest teraz malowany prawdziwym tłem rodzica zamiast zgadywany z `Parent.Color` (który zostaje jako fallback). Dotyczy `TCWSEdit`, `TCWSEditMask`, `TCWSMemo`, `TCWSComboBox`, `TCWSDatePicker`, `TCWSListBox`, `TCWSStringGrid`, `TCWSDBGrid`, `TCWSSettingsPanel` i `TCWSOptionsPanel`. W `TCWSListBox` tylko wtedy, gdy narożniki mają zlewać się z rodzicem — jawny `CornerColor` lub `Color` nadal wygrywa.
- **Poprawka** `TCWSOptionsPanel` — najechanie na nagłówek nie przebarwia już ramki karty (podświetlenie hover malowane jest przed obrysem).
- **Poprawka** `TCWSOptionsPanel` — przy wyłączonej krawędzi ramki (`BorderTop` / `BorderRight` / `BorderBottom` / `BorderLeft`) narożniki nie pokazują już trzeciego koloru: rysowany jest tylko obrys widocznych krawędzi, zamiast całego i zamalowywania ukrytych.

**Wersja 1.6.9:**

- `TCWSStringGrid` i `TCWSDBGrid` — nowe **naprzemienne kolorowanie wierszy**: `AlternatingRowColors` (domyślnie wyłączone) oraz `OddRowColor` / `EvenRowColor`. Wiersze liczone są od 1, więc pierwszy wiersz danych jest nieparzysty; wiersze / kolumny *fixed* i wiersz podświetlony zachowują własne kolory.
- Oba kolory pasów mają domyślnie `clNone` = *wylicz z `CellColor`*: wiersz nieparzysty bierze `CellColor`, parzysty jego lekko przycieniowany wariant (ciemniejszy na jasnym motywie, jaśniejszy na ciemnym). Dzięki temu pasy same podążają za zmianą motywu `CWSFluentColors` — aplikacja przestawia tylko `CellColor`, tak jak dotąd. Jawnie przypisany kolor przypina pas na sztywno.
- `TCWSDBGrid` liczy pasy **po rekordach** (`DataSet.RecNo`), a nie po pozycji na ekranie, więc nie przeskakują przy przewijaniu o jeden rekord (dla zbiorów bez `IsSequenced` jest fallback na numer wiersza).

**Wersja 1.6.8:**

- `TCWSListBox` — scrollbar poprawnie znika / pojawia się po maksymalizacji lub przywróceniu okna dwuklikiem na belce tytułowej (bez potrzeby najechania myszą).
- `TCWSListBox` — kolor focusa / hover / normalny (oraz podświetlenie zaznaczenia) wypełnia teraz całe tło itema w trybie owner-draw (`lbOwnerDrawFixed` i `lbOwnerDrawVariable`), również pod własnym `OnDrawItem` rysującym na przezroczystym tle.
- `TCWSSettingsPanel` — nowa właściwość `Constraints` (minimalny / maksymalny rozmiar, jak w standardowych komponentach VCL).

Pełna historia zmian znajduje się w osobnym pliku [`CHANGELOG.md`](CHANGELOG.md).

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
| **`TCWSDBGrid`** | Fluent-style **data-aware** grid (DBGrid) — wraps an internal `TDBGrid`, so it keeps the full DBGrid surface (`DataSource`, `Columns`, `Options`, events `OnDrawColumnCell` / `OnCellClick` / `OnTitleClick`, etc.). Fluent scrollbars (vertical + horizontal), configurable colors (background, cells, text, grid lines, fixed cells, highlight), **sorting by clicking a title** with multi-column support and in-title indicators (`SortEnabled`, `MultiSortMode`, `MaxSortColumns`, `SortBy` / `ClearSort`, `OnSortApply`), alternating row colors banded by record (`AlternatingRowColors` + `OddRowColor` / `EvenRowColor`), rounded corners with each corner independently switchable, automatic column-width fitting (`AutoFitColumns`), adjustable row and title height, and vertical text centering. |

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

### Labels

| Component | Description |
|-----------|-------------|
| **`TCWSLabelColumn`** | Two-column label — two independent texts side by side (left / right column), each with its own font (`LeftFont` / `RightFont`), alignment and width. Automatic *marquee* when a column's text is too wide (`ScrollColumns`, independent speeds `LeftScrollStep` / `RightScrollStep`, soft edge `EdgeFade`) — flicker-free (draws itself directly, no `Invalidate`). |
| **`TCWSLabelTrend`** | "Pill" / badge label (colored status tags, e.g. Lead / POC / Closed) — capsule-shaped GDI+ fill (`Color`) with an optional border, auto-sized to its content. An icon on the left and/or right of the text (an icon-font glyph or an `ImageList` image — same idea as `TCWSMenuButton`). Full label event surface (`OnClick`, mouse, `OnMouseEnter` / `OnMouseLeave`, `OnContextPopup`). |

### Helper components

| Component | Description |
|-----------|-------------|
| **`TCWSDimOverlay`** | Dim-the-form layered overlay — perfect under modal dialogs. Supports Win11 rounded corners, fade-in/out animation, click blocking. Built-in activity indicator (loader) in 4 styles (`cisLines`, `cisRing`, `cisSegmented`, `cisArrows`) with smooth, frame-rate-independent animation — speed configurable via `IndicatorSpeed` (degrees/s, default 300). The animation runs on its own thread, so it keeps spinning even while the main thread is busy. Optional caption below the indicator. |
| **`TCWSAfterFormShow`** | Component that fires an `OnAfterShow` event once the form is fully painted after `Show` / `ShowModal` (but **not** on un-minimize). |

> ℹ️ **`TCWSShape`** *(`CWSShape.pas`)* — a lightweight, dependency-free GDI+ graphic control that draws a rectangle or rounded rectangle with a fill (`Brush`) and an optional border (`Pen`). It is an internal **building block** the other CWStudio components are built on — e.g. `TCWSButton`, `TCWSStoreButton` and `TCWSMenuButton` use it (by composition) to render their rounded background. It is **not registered on the palette** — it's a foundation for other components, not a drop-on-form control.

### Fluent color modules

| Unit | Description |
|------|-------------|
| **`CWSFluentColors`** | Full set of Fluent UI v9 color tokens (Light + Dark). Single callback on theme change (`FluentOnThemeChange`). |
| **`CWSFluentColorsMulti`** | Same token palette but supports **multiple** subscribers: `RegisterThemeChange` / `UnregisterThemeChange`. Each form or control can register its own handler. |

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

#### 🎨 Color swatch — `CWSFluentColors_palette.html`

The repository ships an interactive **color swatch** [`CWSFluentColors_palette.html`](CWSFluentColors_palette.html) — open it in a browser to browse every Fluent UI v9 token from `CWSFluentColors.pas` (Light and Dark variants). It lets you:

- filter tokens by name (e.g. `Brand`, `Background`, `Hover`),
- preview the palette on a light or dark page background (**Light / Dark** toggle),
- click a **swatch** to copy its HEX, or click a **token name** to copy the token name to the clipboard.

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

## ⚖️ Attribution

When using these components, please include appropriate attribution in your application (e.g., in the About box):

> *"This application uses CWStudio components by Czesław Włudarczyk"*

---

## 🗓️ Version history

**Latest release — 1.7.5:**

- **Changed** `TCWSStoreButton` — **the button no longer needs Skia.** In 1.7.4 it had been rewritten onto `TSkCustomControl`, and that single component pulled `Skia.Package.RTL` / `Skia.Package.VCL` into the runtime package's `requires` — so every application linking the library, and every IDE installing it, needed Skia4Delphi present whether or not it used the button. The component is back on the GDI+ rendering the rest of the library uses (`TCWSShape` for the background and the activity cursor, a `TPaintBox` for the icon, a `TLabel` for the description), and the two Skia packages are gone from `requires`. **The library once again has no dependency outside the stock VCL.**
- **Unchanged by the above** — this is a rendering change and nothing else: the published properties are identical to 1.7.4 (same names, same defaults), and so is the activity cursor's animation, including the direction it grows from within a `GroupIndex` and its timing. `OnClick` / `OnMouseEnter` / `OnMouseLeave` / `OnMouseDown` / `OnMouseUp` fire as before. Existing `.dfm` files load without any change.
- **Note** — the version bump is the library's, not the button's: the sorting and list-box work released in 1.7.4 (`TCWSDBGrid`, `TCWSListBox`) is untouched.

**Version 1.7.4:**

- **New** `TCWSDBGrid` — **sorting by clicking a column title**: `SortEnabled`, off by default so an existing grid behaves exactly as before. A click cycles ascending → descending → unsorted, and the sorted title shows a triangle (`SortArrowColor`, `SortIndicatorSize` in logical 96-DPI pixels) plus, in a multi-column sort, the 1-based number of the sort level (`SortNumberColor`, `ShowSortNumber` = `snmMultiColumn` / `snmAlways` / `snmNever`). Room for the indicator is reserved before the caption is drawn, so a long title is ellipsised against the triangle instead of running under it. **`dgTitleClick` is not required**: `TCustomDBGrid` calls `TitleClick` for every click on a title cell and that option only gates the `OnTitleClick` event. Sorting runs first, so an `OnTitleClick` handler already sees the new sort state.
- **New** `TCWSDBGrid` — **multi-column sorting**: `MaxSortColumns` (3 by default) and `MultiSortMode`: `msmCtrlClick` (a plain click starts a new single-column sort, Ctrl+click appends the next level — the Windows Explorer feel) or `msmAlways` (every click on an unsorted column appends a level). At the limit the least significant level makes way, so a click is never silently ignored.
- **New** `TCWSDBGrid` — runtime sort API: `SortBy`, `ToggleSortColumn`, `ClearSort`, `ApplySort` (re-issue the current sort after re-opening the dataset), `SortOrderBy` (the sort as an ORDER BY body: `'PRICE ASC, NAME DESC'`), `SortLevelOf`, `SortDirectionOf`, `SortColumnCount` and `SortColumns[]`. The sort state depends on live data and is deliberately never streamed to the `.dfm`.
- **New** `TCWSDBGrid` — `OnSortApply` fires **before** the grid touches the dataset, handing over that ready-made ORDER BY body: set `AHandled` after re-running the query yourself and the grid leaves the dataset alone, only repainting the indicators. `SortAutoApply = False` drives the sorting that way exclusively. `OnSortChanged` fires after the state changed and was applied.
- **New** `TCWSDBGrid` — left to itself, the grid orders the data **through the dataset's own index**, and does so without the unit gaining a dependency beyond `Data.DB`: the dataset family is recognised and driven through RTTI. FireDAC (an `Indexes` collection whose items carry an `Expression`) takes `IndexFieldNames` with the `:D` descending suffix; the `ClientDataSet` family, whose `IndexFieldNames` sorts ascending only, is given `AddIndex` with explicit descending fields. The dataset's own ordering (`IndexFieldNames` / `IndexName`) is saved once, just before ours first overrides it, and handed back when the sort is cleared — so clearing puts the application's index back instead of blanking it, and only an ordering the grid imposed itself is ever undone.
- **New** `TCWSDBGrid` — a **text column holding date/time stamps** (`'05.12.2026 09:30'`) is sorted **chronologically, not alphabetically**: a plain text index puts 01.02.2025 before 20.07.2024. The layout is detected by probing the data (`TCWSSortValueKind` = `svkDateTimeText`), a sort key addressing the components at their fixed offsets is built as an index expression, and the resulting order is then verified against the data — if the layout read off the sample does not hold for every row (values written without leading zeros, `'1.2.2026'` next to `'10.12.2026'`), the key is dropped and the plain index used instead, rather than leaving the data in an order that only looks sorted. Requires expression indexes (FireDAC) and a single sorted column; in a multi-column sort such a column falls back to plain text ordering.
- **New** `TCWSDBGrid` — `SortIsExact`: False when the automatic dataset sort could not honour the request in full — a descending level on a dataset whose index has no descending support, or a date-in-text column that had to fall back to text ordering. The arrow still shows the intent; handle `OnSortApply` for those cases.
- **Fix** `TCWSDBGrid` — **widening a grid that is scrolled to the right no longer keeps the left columns hidden**, leaving blank space along the right edge while the scrollbar correctly reports that there is nothing left to scroll. A stock grid re-seats `LeftCol` from `TCustomGrid.UpdateScrollRange`, which returns immediately when `ScrollBars = ssNone` — and the inner grid has exactly that, precisely so no native bar can ever appear, so the pull-back never happened. The component now clamps the left column itself, to the leftmost scrollable column whose tail still fits in the visible width (the flush-right stop).
- **Fix** `TCWSListBox` (`MultiSelect`) — **dragging a multi-selection no longer collapses it to the one item that was pressed.** A press with no modifier on an item that is *already* selected is ambiguous: it can start dragging the whole selection, or be an ordinary click that reduces it to that single item. The native list box resolves it immediately, at press time, by reducing — so the drag that followed carried one item however many were selected. That `WM_LBUTTONDOWN` is now intercepted, the native handling withheld, and the gesture decided on its own: movement past `Mouse.DragThreshold` starts the drag with the selection **untouched**, a release in place reduces to the clicked item, exactly as Windows Explorer does. The whole gesture runs on the component's own mouse capture, so it depends neither on when the VCL calls `DoStartDrag` (not a reliable "a drag has begun" signal — the VCL also calls it after a plain click) nor on a `MouseUp` arriving at all. Only the ambiguous case is intercepted: `Ctrl` / `Shift` clicks, a press on an unselected item or on empty space, a single-selection list and design time all take the native path unchanged. Losing the capture (`WM_CAPTURECHANGED` — Alt+Tab, a system message) cancels the gesture.
- **Fix** `TCWSListBox` — the list now **takes focus when a press starts a drag.** Entering the auto-drag path, the VCL skips the focus change that normally accompanies a click, and the list was left inactive: drawing that keys off `Focused` did not show the selection, and the keyboard went elsewhere. Focus is taken *before* the mouse capture, since changing the active control goes through `SendCancelMode`, which would release the capture; it is closed out at `MouseUp` and, when a drop means `MouseUp` never arrives, at `DoEndDrag` — but not when the drag ended on another control, which was handed the focus deliberately.
- **Fix** `TCWSListBox` — `DragMode` is now also restored in `DoEndDrag`. The component parks it at `dmManual` for the length of a press that must not start a drag (the rule that a drag may only begin on a selected item); if `MouseUp` never came back — a drop consumes it — the list stayed non-draggable for good.
- **Fix** `TCWSListBox` — reducing a multi-selection to one item is done with `LB_SETSEL` plus `LB_SETCARETINDEX` rather than through the `ItemIndex` property, whose setter can clear the selection before it sets the caret in `MultiSelect` mode — and it costs one repaint instead of one per item.
- **Changed** `TCWSListBox` — **the inner list's event slots are free again.** The component used to reach its own handlers by occupying them (`FListBox.OnClick := ListBoxClick`, and the same for the other nine) — and a slot holds exactly one handler, so assigning anything to `ListBox.OnClick` from the outside silently threw the component's handler out, together with the work it does there: the scrollbar refresh, the state background, the repaint. Those events are now forwarded through **overrides** in `TCWSInternalListBox` (`Click`, `DblClick`, `KeyDown` / `KeyUp` / `KeyPress`, `DoEnter`, `DoExit`, `DoContextPopup`, `DrawItem`, `MeasureItem`), which occupy nothing: the slots stay available to the user and the component gets its call regardless. The handler bodies did not move — only where they are called from. Two deliberate exceptions stay on slots: `OnData` / `OnDataFind` / `OnDataObject`, for which the VCL offers no virtual hook (`TCustomListBox.DoGetData` and friends are not virtual), and the mouse path (`OnMouseDown` / `OnMouseMove` / `OnMouseUp`), left untouched because it is interwoven with the VCL auto-drag. `DrawItem` is the one override that does not call `inherited` while the component is attached — owner-draw belongs to the component whole: it paints the state background and then hands the drawing over to `OnDrawItem` or draws the default itself, exactly as it did from the slot.

**Version 1.7.3:**

- **Changed** `TCWSScrollBox` (`srmShaped`) — the antialiased ends are now blended into **the pixels that really lie under the bar**, not into `BackgroundColor`. The bar reproduces them itself: the scrolled content host and the controls on it draw into its composing buffer (`WM_PRINTCLIENT` / `WM_PRINT`), which is what a compositor would do for a translucent layer, without the bar ever becoming a layered window. So the rounded corners stay smooth where the thumb passes over an **image or a nested control**, instead of trailing a background-coloured crescent. The body of the bar is **opaque** — `ScrollThumbColor` pre-mixed with `BackgroundColor` per `ScrollThumbAlpha`, nothing shows through it — and only its **ends** are soft. New `RefreshScrollbars` method for the rare repaint the component cannot see.
- **Changed** `TCWSScrollBox` — the thumb is **centred across its lane**, the same margin on either side of it within `ScrollbarAreaWidth`, instead of being pinned against the right edge of the box (vertical bar) or the bottom edge (horizontal). Growing on hover (`ScrollbarThumbHoverWidth`) is symmetric: the thickness is snapped to the parity of the lane so the thumb's centre line cannot shift by half a pixel as the mouse enters, which is what would make it look like it twitches sideways. At the default 14 / 4 / 6 — and every whole DPI scale of it — the parities already agree and nothing is snapped.
- **New** `TCWSScrollBox` — the scrollbar **thickens while the cursor is anywhere in its lane**, not only when it is exactly on the thumb, so a centred thumb is as easy to reach as an edge-hugging one was. It has to be done by watching the cursor rather than with a window: in `srmShaped` the bar's window *is* the thumb, and a window covering the rest of the lane would have to paint it. Mouse moves cannot simply be listened for either, since over a child control they never reach the box. So the box arms a tracker when the cursor enters it **or anything nested in it** (`CM_MOUSEENTER` travels up the parent chain) and polls the cursor until it leaves.
- **New** `TCWSScrollBox` (`srmShaped`) — **the whole lane is clickable while the pointer is on the bar**: press beside the thumb to start dragging it, above or below it to jump. Previously only the thumb itself could be pressed, so the margin between the thumb and the edge of the box was dead — the bar thickened under the cursor but would not move. A plain window's region decides its pixels and its mouse hit area at once, so the press is **caught in the message loop before it is dispatched** and handed to the bar; beside the thumb it starts the drag and takes the mouse capture, so the rest of the gesture arrives the ordinary way. Nothing is covered. Pressing the lane deliberately does **not** move focus.
- **Fix** `TCWSScrollBox` (`srmShaped`) — the thumb's rounded ends no longer keep the colour of a control that has since changed underneath. Selecting and deselecting a `TCWSStoreButton` behind the bar left the selection colour sitting in the antialiased ends. Nothing could report it: measured on that control, its repaint goes through `Repaint`/`UpdateWindow`, which sends `WM_PAINT` straight to the window without it ever passing through the message queue, so no filter can observe it. The bars therefore re-read what lies under them a few times a second — only while the cursor is inside the box (the only time the staleness can be seen), only for a bar that actually overlaps content, and once more the moment the cursor arrives. A bar over plain background does no work at all.
- **Fix** `TCWSScrollBox` (`srmShaped`) — a control under the lane no longer lights up when the pointer is on the scrollbar. Mouse moves over the lane are swallowed, and whatever was under the pointer is handed a `WM_MOUSELEAVE` so it drops the highlight it had already taken. That message rather than a direct `CM_MOUSELEAVE` on purpose: the VCL only sends an *enter* when the tracked control changes, so clearing the highlight without clearing the bookkeeping behind it would leave the control unable to light up ever again. Nothing is swallowed while any gesture holds the mouse capture, so a splitter drag or a text selection sweeping across the lane is untouched.
- **Fix** `TCWSScrollBox` (`srmShaped`) — no more smear across the scrollbar after hovering a control next to it. Moving the pointer off a control that changes appearance under the cursor and onto the scrollbar left a strip of its *previous* look behind: the bar used to widen its window over the whole lane so the lane could be clicked, and pixels a window covers are a snapshot. The bar no longer covers the lane in any state, and lane clicks are caught before dispatch instead. Anything under the lane stays live.
- **Fix** `TCWSScrollBox` — maximizing and restoring the window no longer sends the content back to the top left. Most visible with `Align = alClient`: once the view is big enough to fit the content there is nothing left to scroll, and the offset was clamped to 0 *in place* — restoring the window brought back the room to scroll but no longer had anywhere to restore the position from. The box now remembers the position it was last **scrolled to** and re-derives the effective offset from that on every layout. Applies to both axes.

**Version 1.7.2:**

- **New** on `TCWSScrollBox` — the **`srmShaped`** render mode, now the default for `ScrollbarRenderMode`. It is the WinUI 3 / Windows 11 model: the bar owns no track at all — its window IS the rounded thumb (clipped with `SetWindowRgn`), and the rest of the lane has no window on it, so the content there is untouched exactly as if the track were transparent. Being a plain child window it is composed by Windows together with its parent, so it can neither flicker nor lag behind the edge while the form is resized. The rounded ends are still antialiased per pixel: the region only cuts the corners, while the capsule's fringe is blended into `BackgroundColor`.
- **Removed** on `TCWSScrollBox` — the **`srmLayered`** render mode. A `WS_EX_LAYERED` child is composed by the DWM on its own schedule, which is what made the bar flicker and float along the window edge during a resize — worked around until now by "parking" the layer for the duration of the drag. It also cost far more per scroll step than it was worth: moving it forced the scrolled content underneath to repaint. `srmShaped` delivers the same "the track does not cover the content" result without a layer, so the mode, the parking machinery and the form subclass that drove it are all gone. **Breaking:** a `.dfm` that stores `ScrollbarRenderMode = srmLayered` will not load — change it to `srmShaped` (closest match) or `srmBlended`, or delete the line to take the default.
- **Changed** `TCWSScrollBox` — **much faster scrolling with large bitmaps and many child controls.** Four things used to make a single wheel tick cost a repaint of the whole content, and none of them do any more. The content host is no longer `DoubleBuffered` in the VCL sense — that allocated and blitted a bitmap the size of the *content*, not of the view, on every paint, and left every graphic child to repaint with it; it now buffers into a bitmap the size of the update rectangle, with the clip set so the VCL skips each control outside the band. The clip region that keeps the content off the border is applied before the move and without a forced redraw, since the visible rectangle does not actually change. The thumb is refreshed once per step instead of twice. And a `srmShaped` thumb that only MOVED is not repainted at all — its pixels travel with the window — while `srmBlended` repaints just the old and the new thumb rectangle instead of the whole lane. The bar composes into one reused DIB rather than allocating a new one per paint.
- **Changed** `TCWSScrollBox` — the thumb now **hugs the edge its bar lives on**: 1 px from the right edge of the box for the vertical bar, 1 px from the bottom for the horizontal, instead of floating centred in the `ScrollbarAreaWidth` lane. That 1 px belongs to the bar, not to the content — it lies inside the bar's window in both render modes, so the cursor reaching the very edge of the box already counts as hovering the scrollbar. Growing on hover (`ScrollbarThumbHoverWidth`) therefore extends the thumb inward only and the edge the eye follows stays put, which also retires the parity snapping that kept a centred thumb from growing lopsidedly.

**Release 1.7.1:**

- **New** on `TCWSScrollBox` — **`ScrollbarRenderMode`**, choosing how the overlay scrollbar is put on screen. `srmLayered` (default, unchanged behaviour) keeps the bar as a `WS_EX_LAYERED` child window, so the scrolled content stays visible **through** the transparent track. `srmBlended` drops the layer: the bar becomes an ordinary child window, its track is filled with `BackgroundColor` and the thumb is drawn in `ScrollThumbColor` pre-mixed with that background per `ScrollThumbAlpha`. Prefer `srmBlended` on forms that get resized — most visibly with `Align = alClient`, where the layered bar flickers and lags behind the window edge while the frame is dragged; that is how the DWM composes a layered child window and it cannot be cured from inside the component. Trade-off: content lying under the bar is covered by the strip instead of showing through — with the usual setup (scrollbox background = content background) there is no visible difference.
- **Fix** `TCWSScrollBox` (`srmBlended`) — the square where the two bars meet in the bottom-right corner is no longer a hole punched out of the strip. Both bars used to be shortened by the scrollbar width, so that square belonged to neither: invisible with the transparent track of `srmLayered`, an empty notch once the track is opaque. The vertical bar now owns the corner, and its thumb still stops exactly where the horizontal bar begins.
- **Changed** `TCWSScrollBox` — the design-time preview follows the render mode, so switching `ScrollbarRenderMode` is visible in the form designer: `srmLayered` clips the bar window to the rounded thumb (content shows through the track), `srmBlended` previews the opaque strip including the corner. The thumb is previewed in the colour it really ends up with on screen (`ScrollThumbColor` mixed with the background per `ScrollThumbAlpha`) instead of fully opaque.
- **Changed** `TCWSScrollBox` — in `srmLayered` the bar's pixels are uploaded with `UpdateLayeredWindow` (position, size and content in one call) instead of being painted through `WM_PAINT` behind a colour key, so the thumb gains real per-pixel alpha and its rounded ends are antialiased.

**Release 1.7.0:**

- **Changed** — the password button on `TCWSEdit` and `TCWSEditMask` (`ebsPassword` / `embsPassword`) is now **hold-to-reveal**, like the WinUI 3 `PasswordBox`: the text shows only while the button is held down and is masked again on release (previously a click toggled it and the password stayed on screen). Masking is also restored when the release lands outside the button and when the mouse capture is cancelled without a release (modal dialog, Alt+Tab, Esc). Revealing keeps the edit's font, caret and selection. `OnButtonClick` fires as before; the other button styles are unchanged.
- **Fix** — rounded corners no longer show a wrong-colored triangle when the parent does not paint itself as a flat fill of its own `Color` (a container drawing a card / gradient background, a VCL-styled form, a parent whose `Color` is out of sync with what it paints). The area outside the rounding now renders the parent's real background instead of guessing from `Parent.Color`, which stays as the fallback. Applies to `TCWSEdit`, `TCWSEditMask`, `TCWSMemo`, `TCWSComboBox`, `TCWSDatePicker`, `TCWSListBox`, `TCWSStringGrid`, `TCWSDBGrid`, `TCWSSettingsPanel` and `TCWSOptionsPanel`. On `TCWSListBox` only when the corners are set to blend with the parent — an explicit `CornerColor` or `Color` still wins.
- **Fix** `TCWSOptionsPanel` — hovering the header no longer tints the card border (the hover wash is painted before the outline).
- **Fix** `TCWSOptionsPanel` — with a border edge switched off (`BorderTop` / `BorderRight` / `BorderBottom` / `BorderLeft`) the rounded corners no longer show a third color: only the visible edges are stroked, instead of stroking the whole outline and painting the hidden parts over.

**Release 1.6.9:**

- `TCWSStringGrid` and `TCWSDBGrid` — new **alternating (zebra) row colors**: `AlternatingRowColors` (off by default) plus `OddRowColor` / `EvenRowColor`. Rows are numbered from 1, so the first data row is the odd one; fixed rows / columns and the highlighted row keep their own colors.
- Both band colors default to `clNone` = *derive from `CellColor`*: odd rows take `CellColor` itself, even rows a slightly shaded variant (darker on a light theme, lighter on a dark one). Left that way the striping follows a `CWSFluentColors` theme switch on its own — the application only re-assigns `CellColor`, as it already does. An explicit color pins a band to a fixed value.
- `TCWSDBGrid` bands by **record** (`DataSet.RecNo`) rather than by screen position, so the stripes don't flip when the grid scrolls by one record (datasets without `IsSequenced` fall back to the on-screen row).

**Release 1.6.8:**

- `TCWSListBox` — the scrollbar now appears / disappears correctly after a title-bar maximize / restore (double-click), without needing the mouse to enter the list.
- `TCWSListBox` — the focus / hover / normal background (and the selection highlight) now fills the whole item row in owner-draw mode (`lbOwnerDrawFixed` and `lbOwnerDrawVariable`), including under a custom transparent `OnDrawItem`.
- `TCWSSettingsPanel` — new `Constraints` property (min / max size, like the stock VCL controls).

The full change history is kept in a separate [`CHANGELOG.md`](CHANGELOG.md) file.

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

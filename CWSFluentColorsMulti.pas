//////////////////////////////////////////////////////////////////////////
//
//   CWStudio Components Library
//   Created by Czesław Włudarczyk 2026 CWStudio
//
//   LICENSE: MIT
//   Free to use, modify and distribute in any project, commercial or
//   non-commercial, provided that the copyright notice and this license
//   text are preserved. See the LICENSE file for the full MIT terms.
//
//   ATTRIBUTION REQUIRED:
//   Any application built using CWStudio components MUST include
//   visible information about the author of the components inside
//   the application (e.g. in the About box, credits screen, or
//   splash screen), for example:
//
//       "Uses CWStudio components by Czesław Włudarczyk"
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//                                                                      //
//  Fluent UI v9 Color Tokens — Light + Dark (multi-listener edition)   //
//  Auto-generated from @fluentui/tokens                                //
//                                                                      //
//  Single set of variables — after FluentApplyTheme() the colors       //
//  change in place. Controls read the new values on the next paint.    //
//                                                                      //
//  Difference from CWSFluentColors:                                    //
//    This unit supports MANY listeners at the same time through        //
//    RegisterThemeChange / UnregisterThemeChange. Each control or      //
//    form may register its own handler — all of them are invoked       //
//    when the theme changes.                                           //
//                                                                      //
//  Usage:                                                              //
//    uses CWSFluentColorsMulti;                                        //
//                                                                      //
//    // Reading tokens:                                                //
//    Label1.Font.Color := flNeutralForeground1;                        //
//    Panel1.Color      := flNeutralBackground1;                        //
//                                                                      //
//    // At startup or when the Windows theme changes:                  //
//    FluentApplySystemTheme;        // auto from registry              //
//    FluentApplyTheme(ftmDark);     // force a specific mode           //
//    FluentSetDarkMode(True);       // shortcut for dark mode          //
//    FluentSetDarkMode(False);      // shortcut for light mode         //
//                                                                      //
//    // Detecting the current Windows setting:                         //
//    if FluentIsWindowsDarkMode then ...                               //
//                                                                      //
//    // Subscribing to theme changes (any number of listeners):        //
//    RegisterThemeChange(Form1.HandleThemeChange);                     //
//    RegisterThemeChange(Form2.HandleThemeChange);                     //
//    ...                                                               //
//    UnregisterThemeChange(Form1.HandleThemeChange); // on destroy     //
//                                                                      //
//    // Manually broadcast to all listeners (rarely needed —           //
//    // FluentApplyTheme already calls it internally):                 //
//    NotifyThemeChange;                                                //
//                                                                      //
//  Handler signature:                                                  //
//    TFluentThemeChangeProc = procedure of object;                     //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

unit CWSFluentColorsMulti;

interface

uses
  System.Classes, VCL.Graphics;

type
  TFluentThemeMode = (ftmLight, ftmDark);
  TFluentThemeChangeProc = procedure of object;
  // Fired only while the app is following the Windows theme (system colors).
  // ASystemIsDark tells the new OS setting after the change.
  TFluentSystemThemeProc = procedure(ASystemIsDark: Boolean) of object;

procedure RegisterThemeChange(const Handler: TFluentThemeChangeProc);
procedure UnregisterThemeChange(const Handler: TFluentThemeChangeProc);
procedure NotifyThemeChange;

var
  FluentThemeMode: TFluentThemeMode;

  // True while the colors follow the live Windows setting. Set automatically:
  //   FluentApplySystemTheme -> True  (option "system colors")
  //   FluentApplyTheme / FluentSetDarkMode -> False (explicit light/dark)
  // While True, an OS theme switch re-applies the colors (broadcasting to all
  // registered listeners) and fires FluentOnSystemThemeChange; while False,
  // OS changes are ignored.
  FluentFollowSystemTheme: Boolean;
  FluentOnSystemThemeChange: TFluentSystemThemeProc;

  flBackgroundOverlay: TColor;

  // --- Brand ---
  flBrandBackground: TColor;
  flBrandBackground2: TColor;
  flBrandBackground2Hover: TColor;
  flBrandBackground2Pressed: TColor;
  flBrandBackground3Static: TColor;
  flBrandBackground4Static: TColor;
  flBrandBackgroundHover: TColor;
  flBrandBackgroundInverted: TColor;
  flBrandBackgroundInvertedHover: TColor;
  flBrandBackgroundInvertedPressed: TColor;
  flBrandBackgroundInvertedSelected: TColor;
  flBrandBackgroundPressed: TColor;
  flBrandBackgroundSelected: TColor;
  flBrandBackgroundStatic: TColor;
  flBrandForeground1: TColor;
  flBrandForeground2: TColor;
  flBrandForeground2Hover: TColor;
  flBrandForeground2Pressed: TColor;
  flBrandForegroundInverted: TColor;
  flBrandForegroundInvertedHover: TColor;
  flBrandForegroundInvertedPressed: TColor;
  flBrandForegroundLink: TColor;
  flBrandForegroundLinkHover: TColor;
  flBrandForegroundLinkPressed: TColor;
  flBrandForegroundLinkSelected: TColor;
  flBrandForegroundOnLight: TColor;
  flBrandForegroundOnLightHover: TColor;
  flBrandForegroundOnLightPressed: TColor;
  flBrandForegroundOnLightSelected: TColor;
  flBrandShadowAmbient: TColor;
  flBrandShadowKey: TColor;
  flBrandStroke1: TColor;
  flBrandStroke2: TColor;
  flBrandStroke2Contrast: TColor;
  flBrandStroke2Hover: TColor;
  flBrandStroke2Pressed: TColor;

  // --- CompoundBrand ---
  flCompoundBrandBackground: TColor;
  flCompoundBrandBackgroundHover: TColor;
  flCompoundBrandBackgroundPressed: TColor;
  flCompoundBrandForeground1: TColor;
  flCompoundBrandForeground1Hover: TColor;
  flCompoundBrandForeground1Pressed: TColor;
  flCompoundBrandStroke: TColor;
  flCompoundBrandStrokeHover: TColor;
  flCompoundBrandStrokePressed: TColor;

  // --- Neutral ---
  flNeutralBackground1: TColor;
  flNeutralBackground1Hover: TColor;
  flNeutralBackground1Pressed: TColor;
  flNeutralBackground1Selected: TColor;
  flNeutralBackground2: TColor;
  flNeutralBackground2Hover: TColor;
  flNeutralBackground2Pressed: TColor;
  flNeutralBackground2Selected: TColor;
  flNeutralBackground3: TColor;
  flNeutralBackground3Hover: TColor;
  flNeutralBackground3Pressed: TColor;
  flNeutralBackground3Selected: TColor;
  flNeutralBackground4: TColor;
  flNeutralBackground4Hover: TColor;
  flNeutralBackground4Pressed: TColor;
  flNeutralBackground4Selected: TColor;
  flNeutralBackground5: TColor;
  flNeutralBackground5Hover: TColor;
  flNeutralBackground5Pressed: TColor;
  flNeutralBackground5Selected: TColor;
  flNeutralBackground6: TColor;
  flNeutralBackground7: TColor;
  flNeutralBackground7Hover: TColor;
  flNeutralBackground7Pressed: TColor;
  flNeutralBackground7Selected: TColor;
  flNeutralBackground8: TColor;
  flNeutralBackgroundAlpha: TColor;
  flNeutralBackgroundAlpha2: TColor;
  flNeutralBackgroundDisabled: TColor;
  flNeutralBackgroundDisabled2: TColor;
  flNeutralBackgroundInverted: TColor;
  flNeutralBackgroundInvertedDisabled: TColor;
  flNeutralBackgroundInvertedHover: TColor;
  flNeutralBackgroundInvertedPressed: TColor;
  flNeutralBackgroundInvertedSelected: TColor;
  flNeutralBackgroundStatic: TColor;
  flNeutralCardBackground: TColor;
  flNeutralCardBackgroundDisabled: TColor;
  flNeutralCardBackgroundHover: TColor;
  flNeutralCardBackgroundPressed: TColor;
  flNeutralCardBackgroundSelected: TColor;
  flNeutralForeground1: TColor;
  flNeutralForeground1Hover: TColor;
  flNeutralForeground1Pressed: TColor;
  flNeutralForeground1Selected: TColor;
  flNeutralForeground1Static: TColor;
  flNeutralForeground2: TColor;
  flNeutralForeground2BrandHover: TColor;
  flNeutralForeground2BrandPressed: TColor;
  flNeutralForeground2BrandSelected: TColor;
  flNeutralForeground2Hover: TColor;
  flNeutralForeground2Link: TColor;
  flNeutralForeground2LinkHover: TColor;
  flNeutralForeground2LinkPressed: TColor;
  flNeutralForeground2LinkSelected: TColor;
  flNeutralForeground2Pressed: TColor;
  flNeutralForeground2Selected: TColor;
  flNeutralForeground3: TColor;
  flNeutralForeground3BrandHover: TColor;
  flNeutralForeground3BrandPressed: TColor;
  flNeutralForeground3BrandSelected: TColor;
  flNeutralForeground3Hover: TColor;
  flNeutralForeground3Pressed: TColor;
  flNeutralForeground3Selected: TColor;
  flNeutralForeground4: TColor;
  flNeutralForeground5: TColor;
  flNeutralForeground5Hover: TColor;
  flNeutralForeground5Pressed: TColor;
  flNeutralForeground5Selected: TColor;
  flNeutralForegroundDisabled: TColor;
  flNeutralForegroundInverted: TColor;
  flNeutralForegroundInverted2: TColor;
  flNeutralForegroundInvertedDisabled: TColor;
  flNeutralForegroundInvertedHover: TColor;
  flNeutralForegroundInvertedLink: TColor;
  flNeutralForegroundInvertedLinkHover: TColor;
  flNeutralForegroundInvertedLinkPressed: TColor;
  flNeutralForegroundInvertedLinkSelected: TColor;
  flNeutralForegroundInvertedPressed: TColor;
  flNeutralForegroundInvertedSelected: TColor;
  flNeutralForegroundOnBrand: TColor;
  flNeutralForegroundStaticInverted: TColor;
  flNeutralShadowAmbient: TColor;
  flNeutralShadowAmbientDarker: TColor;
  flNeutralShadowAmbientLighter: TColor;
  flNeutralShadowKey: TColor;
  flNeutralShadowKeyDarker: TColor;
  flNeutralShadowKeyLighter: TColor;
  flNeutralStencil1: TColor;
  flNeutralStencil1Alpha: TColor;
  flNeutralStencil2: TColor;
  flNeutralStencil2Alpha: TColor;
  flNeutralStroke1: TColor;
  flNeutralStroke1Hover: TColor;
  flNeutralStroke1Pressed: TColor;
  flNeutralStroke1Selected: TColor;
  flNeutralStroke2: TColor;
  flNeutralStroke3: TColor;
  flNeutralStroke4: TColor;
  flNeutralStroke4Hover: TColor;
  flNeutralStroke4Pressed: TColor;
  flNeutralStroke4Selected: TColor;
  flNeutralStrokeAccessible: TColor;
  flNeutralStrokeAccessibleHover: TColor;
  flNeutralStrokeAccessiblePressed: TColor;
  flNeutralStrokeAccessibleSelected: TColor;
  flNeutralStrokeAlpha: TColor;
  flNeutralStrokeAlpha2: TColor;
  flNeutralStrokeDisabled: TColor;
  flNeutralStrokeDisabled2: TColor;
  flNeutralStrokeInvertedDisabled: TColor;
  flNeutralStrokeOnBrand: TColor;
  flNeutralStrokeOnBrand2: TColor;
  flNeutralStrokeOnBrand2Hover: TColor;
  flNeutralStrokeOnBrand2Pressed: TColor;
  flNeutralStrokeOnBrand2Selected: TColor;
  flNeutralStrokeSubtle: TColor;

  // --- PaletteAnchor ---
  flPaletteAnchorBackground2: TColor;

  // ---  ---
  flPaletteAnchorBorderActive: TColor;

  // --- PaletteAnchor ---
  flPaletteAnchorForeground2: TColor;

  // --- PaletteBeige ---
  flPaletteBeigeBackground2: TColor;

  // ---  ---
  flPaletteBeigeBorderActive: TColor;

  // --- PaletteBeige ---
  flPaletteBeigeForeground2: TColor;

  // --- PaletteBerry ---
  flPaletteBerryBackground1: TColor;
  flPaletteBerryBackground2: TColor;
  flPaletteBerryBackground3: TColor;

  // --- PaletteBerryBorder ---
  flPaletteBerryBorder1: TColor;
  flPaletteBerryBorder2: TColor;

  // ---  ---
  flPaletteBerryBorderActive: TColor;

  // --- PaletteBerry ---
  flPaletteBerryForeground1: TColor;
  flPaletteBerryForeground2: TColor;
  flPaletteBerryForeground3: TColor;

  // --- PaletteBlue ---
  flPaletteBlueBackground2: TColor;

  // ---  ---
  flPaletteBlueBorderActive: TColor;

  // --- PaletteBlue ---
  flPaletteBlueForeground2: TColor;

  // --- PaletteBrass ---
  flPaletteBrassBackground2: TColor;

  // ---  ---
  flPaletteBrassBorderActive: TColor;

  // --- PaletteBrass ---
  flPaletteBrassForeground2: TColor;

  // --- PaletteBrown ---
  flPaletteBrownBackground2: TColor;

  // ---  ---
  flPaletteBrownBorderActive: TColor;

  // --- PaletteBrown ---
  flPaletteBrownForeground2: TColor;

  // --- PaletteCornflower ---
  flPaletteCornflowerBackground2: TColor;

  // ---  ---
  flPaletteCornflowerBorderActive: TColor;

  // --- PaletteCornflower ---
  flPaletteCornflowerForeground2: TColor;

  // --- PaletteCranberry ---
  flPaletteCranberryBackground2: TColor;

  // ---  ---
  flPaletteCranberryBorderActive: TColor;

  // --- PaletteCranberry ---
  flPaletteCranberryForeground2: TColor;

  // --- PaletteDarkGreen ---
  flPaletteDarkGreenBackground2: TColor;

  // ---  ---
  flPaletteDarkGreenBorderActive: TColor;

  // --- PaletteDarkGreen ---
  flPaletteDarkGreenForeground2: TColor;

  // --- PaletteDarkOrange ---
  flPaletteDarkOrangeBackground1: TColor;
  flPaletteDarkOrangeBackground2: TColor;
  flPaletteDarkOrangeBackground3: TColor;

  // --- PaletteDarkOrangeBorder ---
  flPaletteDarkOrangeBorder1: TColor;
  flPaletteDarkOrangeBorder2: TColor;

  // ---  ---
  flPaletteDarkOrangeBorderActive: TColor;

  // --- PaletteDarkOrange ---
  flPaletteDarkOrangeForeground1: TColor;
  flPaletteDarkOrangeForeground2: TColor;
  flPaletteDarkOrangeForeground3: TColor;

  // --- PaletteDarkRed ---
  flPaletteDarkRedBackground2: TColor;

  // ---  ---
  flPaletteDarkRedBorderActive: TColor;

  // --- PaletteDarkRed ---
  flPaletteDarkRedForeground2: TColor;

  // --- PaletteForest ---
  flPaletteForestBackground2: TColor;

  // ---  ---
  flPaletteForestBorderActive: TColor;

  // --- PaletteForest ---
  flPaletteForestForeground2: TColor;

  // --- PaletteGold ---
  flPaletteGoldBackground2: TColor;

  // ---  ---
  flPaletteGoldBorderActive: TColor;

  // --- PaletteGold ---
  flPaletteGoldForeground2: TColor;

  // --- PaletteGrape ---
  flPaletteGrapeBackground2: TColor;

  // ---  ---
  flPaletteGrapeBorderActive: TColor;

  // --- PaletteGrape ---
  flPaletteGrapeForeground2: TColor;

  // --- PaletteGreen ---
  flPaletteGreenBackground1: TColor;
  flPaletteGreenBackground2: TColor;
  flPaletteGreenBackground3: TColor;

  // --- PaletteGreenBorder ---
  flPaletteGreenBorder1: TColor;
  flPaletteGreenBorder2: TColor;

  // ---  ---
  flPaletteGreenBorderActive: TColor;

  // --- PaletteGreen ---
  flPaletteGreenForeground1: TColor;
  flPaletteGreenForeground2: TColor;
  flPaletteGreenForeground3: TColor;
  flPaletteGreenForegroundInverted: TColor;

  // --- PaletteLavender ---
  flPaletteLavenderBackground2: TColor;

  // ---  ---
  flPaletteLavenderBorderActive: TColor;

  // --- PaletteLavender ---
  flPaletteLavenderForeground2: TColor;

  // --- PaletteLightGreen ---
  flPaletteLightGreenBackground1: TColor;
  flPaletteLightGreenBackground2: TColor;
  flPaletteLightGreenBackground3: TColor;

  // --- PaletteLightGreenBorder ---
  flPaletteLightGreenBorder1: TColor;
  flPaletteLightGreenBorder2: TColor;

  // ---  ---
  flPaletteLightGreenBorderActive: TColor;

  // --- PaletteLightGreen ---
  flPaletteLightGreenForeground1: TColor;
  flPaletteLightGreenForeground2: TColor;
  flPaletteLightGreenForeground3: TColor;

  // --- PaletteLightTeal ---
  flPaletteLightTealBackground2: TColor;

  // ---  ---
  flPaletteLightTealBorderActive: TColor;

  // --- PaletteLightTeal ---
  flPaletteLightTealForeground2: TColor;

  // --- PaletteLilac ---
  flPaletteLilacBackground2: TColor;

  // ---  ---
  flPaletteLilacBorderActive: TColor;

  // --- PaletteLilac ---
  flPaletteLilacForeground2: TColor;

  // --- PaletteMagenta ---
  flPaletteMagentaBackground2: TColor;

  // ---  ---
  flPaletteMagentaBorderActive: TColor;

  // --- PaletteMagenta ---
  flPaletteMagentaForeground2: TColor;

  // --- PaletteMarigold ---
  flPaletteMarigoldBackground1: TColor;
  flPaletteMarigoldBackground2: TColor;
  flPaletteMarigoldBackground3: TColor;

  // --- PaletteMarigoldBorder ---
  flPaletteMarigoldBorder1: TColor;
  flPaletteMarigoldBorder2: TColor;

  // ---  ---
  flPaletteMarigoldBorderActive: TColor;

  // --- PaletteMarigold ---
  flPaletteMarigoldForeground1: TColor;
  flPaletteMarigoldForeground2: TColor;
  flPaletteMarigoldForeground3: TColor;

  // --- PaletteMink ---
  flPaletteMinkBackground2: TColor;

  // ---  ---
  flPaletteMinkBorderActive: TColor;

  // --- PaletteMink ---
  flPaletteMinkForeground2: TColor;

  // --- PaletteNavy ---
  flPaletteNavyBackground2: TColor;

  // ---  ---
  flPaletteNavyBorderActive: TColor;

  // --- PaletteNavy ---
  flPaletteNavyForeground2: TColor;

  // --- PalettePeach ---
  flPalettePeachBackground2: TColor;

  // ---  ---
  flPalettePeachBorderActive: TColor;

  // --- PalettePeach ---
  flPalettePeachForeground2: TColor;

  // --- PalettePink ---
  flPalettePinkBackground2: TColor;

  // ---  ---
  flPalettePinkBorderActive: TColor;

  // --- PalettePink ---
  flPalettePinkForeground2: TColor;

  // --- PalettePlatinum ---
  flPalettePlatinumBackground2: TColor;

  // ---  ---
  flPalettePlatinumBorderActive: TColor;

  // --- PalettePlatinum ---
  flPalettePlatinumForeground2: TColor;

  // --- PalettePlum ---
  flPalettePlumBackground2: TColor;

  // ---  ---
  flPalettePlumBorderActive: TColor;

  // --- PalettePlum ---
  flPalettePlumForeground2: TColor;

  // --- PalettePumpkin ---
  flPalettePumpkinBackground2: TColor;

  // ---  ---
  flPalettePumpkinBorderActive: TColor;

  // --- PalettePumpkin ---
  flPalettePumpkinForeground2: TColor;

  // --- PalettePurple ---
  flPalettePurpleBackground2: TColor;

  // ---  ---
  flPalettePurpleBorderActive: TColor;

  // --- PalettePurple ---
  flPalettePurpleForeground2: TColor;

  // --- PaletteRed ---
  flPaletteRedBackground1: TColor;
  flPaletteRedBackground2: TColor;
  flPaletteRedBackground3: TColor;

  // --- PaletteRedBorder ---
  flPaletteRedBorder1: TColor;
  flPaletteRedBorder2: TColor;

  // ---  ---
  flPaletteRedBorderActive: TColor;

  // --- PaletteRed ---
  flPaletteRedForeground1: TColor;
  flPaletteRedForeground2: TColor;
  flPaletteRedForeground3: TColor;
  flPaletteRedForegroundInverted: TColor;

  // --- PaletteRoyalBlue ---
  flPaletteRoyalBlueBackground2: TColor;

  // ---  ---
  flPaletteRoyalBlueBorderActive: TColor;

  // --- PaletteRoyalBlue ---
  flPaletteRoyalBlueForeground2: TColor;

  // --- PaletteSeafoam ---
  flPaletteSeafoamBackground2: TColor;

  // ---  ---
  flPaletteSeafoamBorderActive: TColor;

  // --- PaletteSeafoam ---
  flPaletteSeafoamForeground2: TColor;

  // --- PaletteSteel ---
  flPaletteSteelBackground2: TColor;

  // ---  ---
  flPaletteSteelBorderActive: TColor;

  // --- PaletteSteel ---
  flPaletteSteelForeground2: TColor;

  // --- PaletteTeal ---
  flPaletteTealBackground2: TColor;

  // ---  ---
  flPaletteTealBorderActive: TColor;

  // --- PaletteTeal ---
  flPaletteTealForeground2: TColor;

  // --- PaletteYellow ---
  flPaletteYellowBackground1: TColor;
  flPaletteYellowBackground2: TColor;
  flPaletteYellowBackground3: TColor;

  // --- PaletteYellowBorder ---
  flPaletteYellowBorder1: TColor;
  flPaletteYellowBorder2: TColor;

  // ---  ---
  flPaletteYellowBorderActive: TColor;

  // --- PaletteYellow ---
  flPaletteYellowForeground1: TColor;
  flPaletteYellowForeground2: TColor;
  flPaletteYellowForeground3: TColor;
  flPaletteYellowForegroundInverted: TColor;

  // ---  ---
  flScrollbarOverlay: TColor;

  // --- StatusDanger ---
  flStatusDangerBackground1: TColor;
  flStatusDangerBackground2: TColor;
  flStatusDangerBackground3: TColor;
  flStatusDangerBackground3Hover: TColor;
  flStatusDangerBackground3Pressed: TColor;

  // --- StatusDangerBorder ---
  flStatusDangerBorder1: TColor;
  flStatusDangerBorder2: TColor;

  // ---  ---
  flStatusDangerBorderActive: TColor;

  // --- StatusDanger ---
  flStatusDangerForeground1: TColor;
  flStatusDangerForeground2: TColor;
  flStatusDangerForeground3: TColor;
  flStatusDangerForegroundInverted: TColor;

  // --- StatusSuccess ---
  flStatusSuccessBackground1: TColor;
  flStatusSuccessBackground2: TColor;
  flStatusSuccessBackground3: TColor;

  // --- StatusSuccessBorder ---
  flStatusSuccessBorder1: TColor;
  flStatusSuccessBorder2: TColor;

  // ---  ---
  flStatusSuccessBorderActive: TColor;

  // --- StatusSuccess ---
  flStatusSuccessForeground1: TColor;
  flStatusSuccessForeground2: TColor;
  flStatusSuccessForeground3: TColor;
  flStatusSuccessForegroundInverted: TColor;

  // --- StatusWarning ---
  flStatusWarningBackground1: TColor;
  flStatusWarningBackground2: TColor;
  flStatusWarningBackground3: TColor;

  // --- StatusWarningBorder ---
  flStatusWarningBorder1: TColor;
  flStatusWarningBorder2: TColor;

  // ---  ---
  flStatusWarningBorderActive: TColor;

  // --- StatusWarning ---
  flStatusWarningForeground1: TColor;
  flStatusWarningForeground2: TColor;
  flStatusWarningForeground3: TColor;
  flStatusWarningForegroundInverted: TColor;

  // --- StrokeFocus ---
  flStrokeFocus1: TColor;
  flStrokeFocus2: TColor;

  // --- Subtle ---
  flSubtleBackgroundHover: TColor;
  flSubtleBackgroundInvertedHover: TColor;
  flSubtleBackgroundInvertedPressed: TColor;
  flSubtleBackgroundInvertedSelected: TColor;
  flSubtleBackgroundLightAlphaHover: TColor;
  flSubtleBackgroundLightAlphaPressed: TColor;
  flSubtleBackgroundPressed: TColor;
  flSubtleBackgroundSelected: TColor;

const
  flBackgroundOverlayLight: TColor = $00000000; // rgba(0, 0, 0, 0.4)

  // --- Brand ---
  flBrandBackgroundLight: TColor = $00BD6C0F; // #0f6cbd
  flBrandBackground2Light: TColor = $00FCF3EB; // #ebf3fc
  flBrandBackground2HoverLight: TColor = $00FAE4CF; // #cfe4fa
  flBrandBackground2PressedLight: TColor = $00FAC696; // #96c6fa
  flBrandBackground3StaticLight: TColor = $008C540F; // #0f548c
  flBrandBackground4StaticLight: TColor = $005E3B0C; // #0c3b5e
  flBrandBackgroundHoverLight: TColor = $00A35E11; // #115ea3
  flBrandBackgroundInvertedLight: TColor = $00FFFFFF; // #ffffff
  flBrandBackgroundInvertedHoverLight: TColor = $00FCF3EB; // #ebf3fc
  flBrandBackgroundInvertedPressedLight: TColor = $00FAD6B4; // #b4d6fa
  flBrandBackgroundInvertedSelectedLight: TColor = $00FAE4CF; // #cfe4fa
  flBrandBackgroundPressedLight: TColor = $005E3B0C; // #0c3b5e
  flBrandBackgroundSelectedLight: TColor = $008C540F; // #0f548c
  flBrandBackgroundStaticLight: TColor = $00BD6C0F; // #0f6cbd
  flBrandForeground1Light: TColor = $00BD6C0F; // #0f6cbd
  flBrandForeground2Light: TColor = $00A35E11; // #115ea3
  flBrandForeground2HoverLight: TColor = $008C540F; // #0f548c
  flBrandForeground2PressedLight: TColor = $004A2E0A; // #0a2e4a
  flBrandForegroundInvertedLight: TColor = $00F59E47; // #479ef5
  flBrandForegroundInvertedHoverLight: TColor = $00F5AB62; // #62abf5
  flBrandForegroundInvertedPressedLight: TColor = $00F59E47; // #479ef5
  flBrandForegroundLinkLight: TColor = $00A35E11; // #115ea3
  flBrandForegroundLinkHoverLight: TColor = $008C540F; // #0f548c
  flBrandForegroundLinkPressedLight: TColor = $005E3B0C; // #0c3b5e
  flBrandForegroundLinkSelectedLight: TColor = $00A35E11; // #115ea3
  flBrandForegroundOnLightLight: TColor = $00BD6C0F; // #0f6cbd
  flBrandForegroundOnLightHoverLight: TColor = $00A35E11; // #115ea3
  flBrandForegroundOnLightPressedLight: TColor = $0075470E; // #0e4775
  flBrandForegroundOnLightSelectedLight: TColor = $008C540F; // #0f548c
  flBrandShadowAmbientLight: TColor = $00000000; // rgba(0,0,0,0.30)
  flBrandShadowKeyLight: TColor = $00000000; // rgba(0,0,0,0.25)
  flBrandStroke1Light: TColor = $00BD6C0F; // #0f6cbd
  flBrandStroke2Light: TColor = $00FAD6B4; // #b4d6fa
  flBrandStroke2ContrastLight: TColor = $00FAD6B4; // #b4d6fa
  flBrandStroke2HoverLight: TColor = $00F7B777; // #77b7f7
  flBrandStroke2PressedLight: TColor = $00BD6C0F; // #0f6cbd

  // --- CompoundBrand ---
  flCompoundBrandBackgroundLight: TColor = $00BD6C0F; // #0f6cbd
  flCompoundBrandBackgroundHoverLight: TColor = $00A35E11; // #115ea3
  flCompoundBrandBackgroundPressedLight: TColor = $008C540F; // #0f548c
  flCompoundBrandForeground1Light: TColor = $00BD6C0F; // #0f6cbd
  flCompoundBrandForeground1HoverLight: TColor = $00A35E11; // #115ea3
  flCompoundBrandForeground1PressedLight: TColor = $008C540F; // #0f548c
  flCompoundBrandStrokeLight: TColor = $00BD6C0F; // #0f6cbd
  flCompoundBrandStrokeHoverLight: TColor = $00A35E11; // #115ea3
  flCompoundBrandStrokePressedLight: TColor = $008C540F; // #0f548c

  // --- Neutral ---
  flNeutralBackground1Light: TColor = $00FFFFFF; // #ffffff
  flNeutralBackground1HoverLight: TColor = $00F5F5F5; // #f5f5f5
  flNeutralBackground1PressedLight: TColor = $00E0E0E0; // #e0e0e0
  flNeutralBackground1SelectedLight: TColor = $00EBEBEB; // #ebebeb
  flNeutralBackground2Light: TColor = $00FAFAFA; // #fafafa
  flNeutralBackground2HoverLight: TColor = $00F0F0F0; // #f0f0f0
  flNeutralBackground2PressedLight: TColor = $00DBDBDB; // #dbdbdb
  flNeutralBackground2SelectedLight: TColor = $00E6E6E6; // #e6e6e6
  flNeutralBackground3Light: TColor = $00F5F5F5; // #f5f5f5
  flNeutralBackground3HoverLight: TColor = $00EBEBEB; // #ebebeb
  flNeutralBackground3PressedLight: TColor = $00D6D6D6; // #d6d6d6
  flNeutralBackground3SelectedLight: TColor = $00E0E0E0; // #e0e0e0
  flNeutralBackground4Light: TColor = $00F0F0F0; // #f0f0f0
  flNeutralBackground4HoverLight: TColor = $00FAFAFA; // #fafafa
  flNeutralBackground4PressedLight: TColor = $00F5F5F5; // #f5f5f5
  flNeutralBackground4SelectedLight: TColor = $00FFFFFF; // #ffffff
  flNeutralBackground5Light: TColor = $00EBEBEB; // #ebebeb
  flNeutralBackground5HoverLight: TColor = $00F5F5F5; // #f5f5f5
  flNeutralBackground5PressedLight: TColor = $00F0F0F0; // #f0f0f0
  flNeutralBackground5SelectedLight: TColor = $00FAFAFA; // #fafafa
  flNeutralBackground6Light: TColor = $00E6E6E6; // #e6e6e6
  flNeutralBackground7Light: TColor = $00000000; // #00000000
  flNeutralBackground7HoverLight: TColor = $00EBEBEB; // #ebebeb
  flNeutralBackground7PressedLight: TColor = $00D6D6D6; // #d6d6d6
  flNeutralBackground7SelectedLight: TColor = $00000000; // #00000000
  flNeutralBackground8Light: TColor = $00FCFCFC; // #fcfcfc
  flNeutralBackgroundAlphaLight: TColor = $00FFFFFF; // rgba(255, 255, 255, 0.5)
  flNeutralBackgroundAlpha2Light: TColor = $00FFFFFF; // rgba(255, 255, 255, 0.8)
  flNeutralBackgroundDisabledLight: TColor = $00F0F0F0; // #f0f0f0
  flNeutralBackgroundDisabled2Light: TColor = $00FFFFFF; // #ffffff
  flNeutralBackgroundInvertedLight: TColor = $00292929; // #292929
  flNeutralBackgroundInvertedDisabledLight: TColor = $00FFFFFF; // rgba(255, 255, 255, 0.1)
  flNeutralBackgroundInvertedHoverLight: TColor = $003D3D3D; // #3d3d3d
  flNeutralBackgroundInvertedPressedLight: TColor = $001F1F1F; // #1f1f1f
  flNeutralBackgroundInvertedSelectedLight: TColor = $00383838; // #383838
  flNeutralBackgroundStaticLight: TColor = $00333333; // #333333
  flNeutralCardBackgroundLight: TColor = $00FAFAFA; // #fafafa
  flNeutralCardBackgroundDisabledLight: TColor = $00F0F0F0; // #f0f0f0
  flNeutralCardBackgroundHoverLight: TColor = $00FFFFFF; // #ffffff
  flNeutralCardBackgroundPressedLight: TColor = $00F5F5F5; // #f5f5f5
  flNeutralCardBackgroundSelectedLight: TColor = $00EBEBEB; // #ebebeb
  flNeutralForeground1Light: TColor = $00242424; // #242424
  flNeutralForeground1HoverLight: TColor = $00242424; // #242424
  flNeutralForeground1PressedLight: TColor = $00242424; // #242424
  flNeutralForeground1SelectedLight: TColor = $00242424; // #242424
  flNeutralForeground1StaticLight: TColor = $00242424; // #242424
  flNeutralForeground2Light: TColor = $00424242; // #424242
  flNeutralForeground2BrandHoverLight: TColor = $00BD6C0F; // #0f6cbd
  flNeutralForeground2BrandPressedLight: TColor = $00A35E11; // #115ea3
  flNeutralForeground2BrandSelectedLight: TColor = $00BD6C0F; // #0f6cbd
  flNeutralForeground2HoverLight: TColor = $00242424; // #242424
  flNeutralForeground2LinkLight: TColor = $00424242; // #424242
  flNeutralForeground2LinkHoverLight: TColor = $00242424; // #242424
  flNeutralForeground2LinkPressedLight: TColor = $00242424; // #242424
  flNeutralForeground2LinkSelectedLight: TColor = $00242424; // #242424
  flNeutralForeground2PressedLight: TColor = $00242424; // #242424
  flNeutralForeground2SelectedLight: TColor = $00242424; // #242424
  flNeutralForeground3Light: TColor = $00616161; // #616161
  flNeutralForeground3BrandHoverLight: TColor = $00BD6C0F; // #0f6cbd
  flNeutralForeground3BrandPressedLight: TColor = $00A35E11; // #115ea3
  flNeutralForeground3BrandSelectedLight: TColor = $00BD6C0F; // #0f6cbd
  flNeutralForeground3HoverLight: TColor = $00424242; // #424242
  flNeutralForeground3PressedLight: TColor = $00424242; // #424242
  flNeutralForeground3SelectedLight: TColor = $00424242; // #424242
  flNeutralForeground4Light: TColor = $00707070; // #707070
  flNeutralForeground5Light: TColor = $00616161; // #616161
  flNeutralForeground5HoverLight: TColor = $00242424; // #242424
  flNeutralForeground5PressedLight: TColor = $00242424; // #242424
  flNeutralForeground5SelectedLight: TColor = $00242424; // #242424
  flNeutralForegroundDisabledLight: TColor = $00BDBDBD; // #bdbdbd
  flNeutralForegroundInvertedLight: TColor = $00FFFFFF; // #ffffff
  flNeutralForegroundInverted2Light: TColor = $00FFFFFF; // #ffffff
  flNeutralForegroundInvertedDisabledLight: TColor = $00FFFFFF; // rgba(255, 255, 255, 0.4)
  flNeutralForegroundInvertedHoverLight: TColor = $00FFFFFF; // #ffffff
  flNeutralForegroundInvertedLinkLight: TColor = $00FFFFFF; // #ffffff
  flNeutralForegroundInvertedLinkHoverLight: TColor = $00FFFFFF; // #ffffff
  flNeutralForegroundInvertedLinkPressedLight: TColor = $00FFFFFF; // #ffffff
  flNeutralForegroundInvertedLinkSelectedLight: TColor = $00FFFFFF; // #ffffff
  flNeutralForegroundInvertedPressedLight: TColor = $00FFFFFF; // #ffffff
  flNeutralForegroundInvertedSelectedLight: TColor = $00FFFFFF; // #ffffff
  flNeutralForegroundOnBrandLight: TColor = $00FFFFFF; // #ffffff
  flNeutralForegroundStaticInvertedLight: TColor = $00FFFFFF; // #ffffff
  flNeutralShadowAmbientLight: TColor = $00000000; // rgba(0,0,0,0.12)
  flNeutralShadowAmbientDarkerLight: TColor = $00000000; // rgba(0,0,0,0.20)
  flNeutralShadowAmbientLighterLight: TColor = $00000000; // rgba(0,0,0,0.06)
  flNeutralShadowKeyLight: TColor = $00000000; // rgba(0,0,0,0.14)
  flNeutralShadowKeyDarkerLight: TColor = $00000000; // rgba(0,0,0,0.24)
  flNeutralShadowKeyLighterLight: TColor = $00000000; // rgba(0,0,0,0.07)
  flNeutralStencil1Light: TColor = $00E6E6E6; // #e6e6e6
  flNeutralStencil1AlphaLight: TColor = $00000000; // rgba(0, 0, 0, 0.1)
  flNeutralStencil2Light: TColor = $00FAFAFA; // #fafafa
  flNeutralStencil2AlphaLight: TColor = $00000000; // rgba(0, 0, 0, 0.05)
  flNeutralStroke1Light: TColor = $00D1D1D1; // #d1d1d1
  flNeutralStroke1HoverLight: TColor = $00C7C7C7; // #c7c7c7
  flNeutralStroke1PressedLight: TColor = $00B3B3B3; // #b3b3b3
  flNeutralStroke1SelectedLight: TColor = $00BDBDBD; // #bdbdbd
  flNeutralStroke2Light: TColor = $00E0E0E0; // #e0e0e0
  flNeutralStroke3Light: TColor = $00F0F0F0; // #f0f0f0
  flNeutralStroke4Light: TColor = $00EBEBEB; // #ebebeb
  flNeutralStroke4HoverLight: TColor = $00E0E0E0; // #e0e0e0
  flNeutralStroke4PressedLight: TColor = $00D6D6D6; // #d6d6d6
  flNeutralStroke4SelectedLight: TColor = $00EBEBEB; // #ebebeb
  flNeutralStrokeAccessibleLight: TColor = $00616161; // #616161
  flNeutralStrokeAccessibleHoverLight: TColor = $00575757; // #575757
  flNeutralStrokeAccessiblePressedLight: TColor = $004D4D4D; // #4d4d4d
  flNeutralStrokeAccessibleSelectedLight: TColor = $00BD6C0F; // #0f6cbd
  flNeutralStrokeAlphaLight: TColor = $00000000; // rgba(0, 0, 0, 0.05)
  flNeutralStrokeAlpha2Light: TColor = $00FFFFFF; // rgba(255, 255, 255, 0.2)
  flNeutralStrokeDisabledLight: TColor = $00E0E0E0; // #e0e0e0
  flNeutralStrokeDisabled2Light: TColor = $00EBEBEB; // #ebebeb
  flNeutralStrokeInvertedDisabledLight: TColor = $00FFFFFF; // rgba(255, 255, 255, 0.4)
  flNeutralStrokeOnBrandLight: TColor = $00FFFFFF; // #ffffff
  flNeutralStrokeOnBrand2Light: TColor = $00FFFFFF; // #ffffff
  flNeutralStrokeOnBrand2HoverLight: TColor = $00FFFFFF; // #ffffff
  flNeutralStrokeOnBrand2PressedLight: TColor = $00FFFFFF; // #ffffff
  flNeutralStrokeOnBrand2SelectedLight: TColor = $00FFFFFF; // #ffffff
  flNeutralStrokeSubtleLight: TColor = $00E0E0E0; // #e0e0e0

  // --- PaletteAnchor ---
  flPaletteAnchorBackground2Light: TColor = $00C7C3BC; // #bcc3c7

  // ---  ---
  flPaletteAnchorBorderActiveLight: TColor = $00464139; // #394146

  // --- PaletteAnchor ---
  flPaletteAnchorForeground2Light: TColor = $00272420; // #202427

  // --- PaletteBeige ---
  flPaletteBeigeBackground2Light: TColor = $00D4D4D7; // #d7d4d4

  // ---  ---
  flPaletteBeigeBorderActiveLight: TColor = $0074757A; // #7a7574

  // --- PaletteBeige ---
  flPaletteBeigeForeground2Light: TColor = $00414244; // #444241

  // --- PaletteBerry ---
  flPaletteBerryBackground1Light: TColor = $00FCF5FD; // #fdf5fc
  flPaletteBerryBackground2Light: TColor = $00E7BBED; // #edbbe7
  flPaletteBerryBackground3Light: TColor = $00B339C2; // #c239b3

  // --- PaletteBerryBorder ---
  flPaletteBerryBorder1Light: TColor = $00E7BBED; // #edbbe7
  flPaletteBerryBorder2Light: TColor = $00B339C2; // #c239b3

  // ---  ---
  flPaletteBerryBorderActiveLight: TColor = $00B339C2; // #c239b3

  // --- PaletteBerry ---
  flPaletteBerryForeground1Light: TColor = $00A133AF; // #af33a1
  flPaletteBerryForeground2Light: TColor = $0064206D; // #6d2064
  flPaletteBerryForeground3Light: TColor = $00B339C2; // #c239b3

  // --- PaletteBlue ---
  flPaletteBlueBackground2Light: TColor = $00F2D3A9; // #a9d3f2

  // ---  ---
  flPaletteBlueBorderActiveLight: TColor = $00D47800; // #0078d4

  // --- PaletteBlue ---
  flPaletteBlueForeground2Light: TColor = $00774300; // #004377

  // --- PaletteBrass ---
  flPaletteBrassBackground2Light: TColor = $00A2CEE0; // #e0cea2

  // ---  ---
  flPaletteBrassBorderActiveLight: TColor = $000B6F98; // #986f0b

  // --- PaletteBrass ---
  flPaletteBrassForeground2Light: TColor = $00063E55; // #553e06

  // --- PaletteBrown ---
  flPaletteBrownBackground2Light: TColor = $00B0C3DD; // #ddc3b0

  // ---  ---
  flPaletteBrownBorderActiveLight: TColor = $002E568E; // #8e562e

  // --- PaletteBrown ---
  flPaletteBrownForeground2Light: TColor = $001A3050; // #50301a

  // --- PaletteCornflower ---
  flPaletteCornflowerBackground2Light: TColor = $00FAD1C8; // #c8d1fa

  // ---  ---
  flPaletteCornflowerBorderActiveLight: TColor = $00ED6B4F; // #4f6bed

  // --- PaletteCornflower ---
  flPaletteCornflowerForeground2Light: TColor = $00853C2C; // #2c3c85

  // --- PaletteCranberry ---
  flPaletteCranberryBackground2Light: TColor = $00B2ACEE; // #eeacb2

  // ---  ---
  flPaletteCranberryBorderActiveLight: TColor = $001F0FC5; // #c50f1f

  // --- PaletteCranberry ---
  flPaletteCranberryForeground2Light: TColor = $0011086E; // #6e0811

  // --- PaletteDarkGreen ---
  flPaletteDarkGreenBackground2Light: TColor = $009AD29A; // #9ad29a

  // ---  ---
  flPaletteDarkGreenBorderActiveLight: TColor = $000B6A0B; // #0b6a0b

  // --- PaletteDarkGreen ---
  flPaletteDarkGreenForeground2Light: TColor = $00063B06; // #063b06

  // --- PaletteDarkOrange ---
  flPaletteDarkOrangeBackground1Light: TColor = $00F3F6FD; // #fdf6f3
  flPaletteDarkOrangeBackground2Light: TColor = $00ABBFF4; // #f4bfab
  flPaletteDarkOrangeBackground3Light: TColor = $00013BDA; // #da3b01

  // --- PaletteDarkOrangeBorder ---
  flPaletteDarkOrangeBorder1Light: TColor = $00ABBFF4; // #f4bfab
  flPaletteDarkOrangeBorder2Light: TColor = $00013BDA; // #da3b01

  // ---  ---
  flPaletteDarkOrangeBorderActiveLight: TColor = $00013BDA; // #da3b01

  // --- PaletteDarkOrange ---
  flPaletteDarkOrangeForeground1Light: TColor = $000135C4; // #c43501
  flPaletteDarkOrangeForeground2Light: TColor = $0001217A; // #7a2101
  flPaletteDarkOrangeForeground3Light: TColor = $00013BDA; // #da3b01

  // --- PaletteDarkRed ---
  flPaletteDarkRedBackground2Light: TColor = $00A59CD6; // #d69ca5

  // ---  ---
  flPaletteDarkRedBorderActiveLight: TColor = $001C0B75; // #750b1c

  // --- PaletteDarkRed ---
  flPaletteDarkRedForeground2Light: TColor = $00100642; // #420610

  // --- PaletteForest ---
  flPaletteForestBackground2Light: TColor = $009BD9BD; // #bdd99b

  // ---  ---
  flPaletteForestBorderActiveLight: TColor = $00058249; // #498205

  // --- PaletteForest ---
  flPaletteForestForeground2Light: TColor = $00034929; // #294903

  // --- PaletteGold ---
  flPaletteGoldBackground2Light: TColor = $00A5DFEC; // #ecdfa5

  // ---  ---
  flPaletteGoldBorderActiveLight: TColor = $00009CC1; // #c19c00

  // --- PaletteGold ---
  flPaletteGoldForeground2Light: TColor = $0000576C; // #6c5700

  // --- PaletteGrape ---
  flPaletteGrapeBackground2Light: TColor = $00E0A7D9; // #d9a7e0

  // ---  ---
  flPaletteGrapeBorderActiveLight: TColor = $00981788; // #881798

  // --- PaletteGrape ---
  flPaletteGrapeForeground2Light: TColor = $00550D4C; // #4c0d55

  // --- PaletteGreen ---
  flPaletteGreenBackground1Light: TColor = $00F1FAF1; // #f1faf1
  flPaletteGreenBackground2Light: TColor = $009FD89F; // #9fd89f
  flPaletteGreenBackground3Light: TColor = $00107C10; // #107c10

  // --- PaletteGreenBorder ---
  flPaletteGreenBorder1Light: TColor = $009FD89F; // #9fd89f
  flPaletteGreenBorder2Light: TColor = $00107C10; // #107c10

  // ---  ---
  flPaletteGreenBorderActiveLight: TColor = $00107C10; // #107c10

  // --- PaletteGreen ---
  flPaletteGreenForeground1Light: TColor = $000E700E; // #0e700e
  flPaletteGreenForeground2Light: TColor = $00094509; // #094509
  flPaletteGreenForeground3Light: TColor = $00107C10; // #107c10
  flPaletteGreenForegroundInvertedLight: TColor = $00359B35; // #359b35

  // --- PaletteLavender ---
  flPaletteLavenderBackground2Light: TColor = $00F8CCD2; // #d2ccf8

  // ---  ---
  flPaletteLavenderBorderActiveLight: TColor = $00E86071; // #7160e8

  // --- PaletteLavender ---
  flPaletteLavenderForeground2Light: TColor = $0082363F; // #3f3682

  // --- PaletteLightGreen ---
  flPaletteLightGreenBackground1Light: TColor = $00F2FBF2; // #f2fbf2
  flPaletteLightGreenBackground2Light: TColor = $00A5E3A7; // #a7e3a5
  flPaletteLightGreenBackground3Light: TColor = $000EA113; // #13a10e

  // --- PaletteLightGreenBorder ---
  flPaletteLightGreenBorder1Light: TColor = $00A5E3A7; // #a7e3a5
  flPaletteLightGreenBorder2Light: TColor = $000EA113; // #13a10e

  // ---  ---
  flPaletteLightGreenBorderActiveLight: TColor = $000EA113; // #13a10e

  // --- PaletteLightGreen ---
  flPaletteLightGreenForeground1Light: TColor = $000D9111; // #11910d
  flPaletteLightGreenForeground2Light: TColor = $00085A0B; // #0b5a08
  flPaletteLightGreenForeground3Light: TColor = $000EA113; // #13a10e

  // --- PaletteLightTeal ---
  flPaletteLightTealBackground2Light: TColor = $00EDE9A6; // #a6e9ed

  // ---  ---
  flPaletteLightTealBorderActiveLight: TColor = $00C3B700; // #00b7c3

  // --- PaletteLightTeal ---
  flPaletteLightTealForeground2Light: TColor = $006D6600; // #00666d

  // --- PaletteLilac ---
  flPaletteLilacBackground2Light: TColor = $00EDBFE6; // #e6bfed

  // ---  ---
  flPaletteLilacBorderActiveLight: TColor = $00C246B1; // #b146c2

  // --- PaletteLilac ---
  flPaletteLilacForeground2Light: TColor = $006D2763; // #63276d

  // --- PaletteMagenta ---
  flPaletteMagentaBackground2Light: TColor = $00D1A5EC; // #eca5d1

  // ---  ---
  flPaletteMagentaBorderActiveLight: TColor = $007700BF; // #bf0077

  // --- PaletteMagenta ---
  flPaletteMagentaForeground2Light: TColor = $0043006B; // #6b0043

  // --- PaletteMarigold ---
  flPaletteMarigoldBackground1Light: TColor = $00F4FBFE; // #fefbf4
  flPaletteMarigoldBackground2Light: TColor = $00AEE2F9; // #f9e2ae
  flPaletteMarigoldBackground3Light: TColor = $0000A3EA; // #eaa300

  // --- PaletteMarigoldBorder ---
  flPaletteMarigoldBorder1Light: TColor = $00AEE2F9; // #f9e2ae
  flPaletteMarigoldBorder2Light: TColor = $0000A3EA; // #eaa300

  // ---  ---
  flPaletteMarigoldBorderActiveLight: TColor = $0000A3EA; // #eaa300

  // --- PaletteMarigold ---
  flPaletteMarigoldForeground1Light: TColor = $000093D3; // #d39300
  flPaletteMarigoldForeground2Light: TColor = $00005B83; // #835b00
  flPaletteMarigoldForeground3Light: TColor = $0000A3EA; // #eaa300

  // --- PaletteMink ---
  flPaletteMinkBackground2Light: TColor = $00CBCCCE; // #cecccb

  // ---  ---
  flPaletteMinkBorderActiveLight: TColor = $00585A5D; // #5d5a58

  // --- PaletteMink ---
  flPaletteMinkForeground2Light: TColor = $00313234; // #343231

  // --- PaletteNavy ---
  flPaletteNavyBackground2Light: TColor = $00E8B2A3; // #a3b2e8

  // ---  ---
  flPaletteNavyBorderActiveLight: TColor = $00B42700; // #0027b4

  // --- PaletteNavy ---
  flPaletteNavyForeground2Light: TColor = $00651600; // #001665

  // --- PalettePeach ---
  flPalettePeachBackground2Light: TColor = $00B3DDFF; // #ffddb3

  // ---  ---
  flPalettePeachBorderActiveLight: TColor = $00008CFF; // #ff8c00

  // --- PalettePeach ---
  flPalettePeachForeground2Light: TColor = $00004E8F; // #8f4e00

  // --- PalettePink ---
  flPalettePinkBackground2Light: TColor = $00E3C0F7; // #f7c0e3

  // ---  ---
  flPalettePinkBorderActiveLight: TColor = $00A63BE4; // #e43ba6

  // --- PalettePink ---
  flPalettePinkForeground2Light: TColor = $005D2180; // #80215d

  // --- PalettePlatinum ---
  flPalettePlatinumBackground2Light: TColor = $00D8D6CD; // #cdd6d8

  // ---  ---
  flPalettePlatinumBorderActiveLight: TColor = $007E7969; // #69797e

  // --- PalettePlatinum ---
  flPalettePlatinumForeground2Light: TColor = $0047443B; // #3b4447

  // --- PalettePlum ---
  flPalettePlumBackground2Light: TColor = $00C096D6; // #d696c0

  // ---  ---
  flPalettePlumBorderActiveLight: TColor = $004D0077; // #77004d

  // --- PalettePlum ---
  flPalettePlumForeground2Light: TColor = $002B0043; // #43002b

  // --- PalettePumpkin ---
  flPalettePumpkinBackground2Light: TColor = $00ADC4EF; // #efc4ad

  // ---  ---
  flPalettePumpkinBorderActiveLight: TColor = $001050CA; // #ca5010

  // --- PalettePumpkin ---
  flPalettePumpkinForeground2Light: TColor = $00092D71; // #712d09

  // --- PalettePurple ---
  flPalettePurpleBackground2Light: TColor = $00DEB1C6; // #c6b1de

  // ---  ---
  flPalettePurpleBorderActiveLight: TColor = $00912E5C; // #5c2e91

  // --- PalettePurple ---
  flPalettePurpleForeground2Light: TColor = $00511A34; // #341a51

  // --- PaletteRed ---
  flPaletteRedBackground1Light: TColor = $00F6F6FD; // #fdf6f6
  flPaletteRedBackground2Light: TColor = $00BCBBF1; // #f1bbbc
  flPaletteRedBackground3Light: TColor = $003834D1; // #d13438

  // --- PaletteRedBorder ---
  flPaletteRedBorder1Light: TColor = $00BCBBF1; // #f1bbbc
  flPaletteRedBorder2Light: TColor = $003834D1; // #d13438

  // ---  ---
  flPaletteRedBorderActiveLight: TColor = $003834D1; // #d13438

  // --- PaletteRed ---
  flPaletteRedForeground1Light: TColor = $00322FBC; // #bc2f32
  flPaletteRedForeground2Light: TColor = $001F1D75; // #751d1f
  flPaletteRedForeground3Light: TColor = $003834D1; // #d13438
  flPaletteRedForegroundInvertedLight: TColor = $00625EDC; // #dc5e62

  // --- PaletteRoyalBlue ---
  flPaletteRoyalBlueBackground2Light: TColor = $00DCBF9A; // #9abfdc

  // ---  ---
  flPaletteRoyalBlueBorderActiveLight: TColor = $008C4E00; // #004e8c

  // --- PaletteRoyalBlue ---
  flPaletteRoyalBlueForeground2Light: TColor = $004E2C00; // #002c4e

  // --- PaletteSeafoam ---
  flPaletteSeafoamBackground2Light: TColor = $00CDF0A8; // #a8f0cd

  // ---  ---
  flPaletteSeafoamBorderActiveLight: TColor = $006ACC00; // #00cc6a

  // --- PaletteSeafoam ---
  flPaletteSeafoamForeground2Light: TColor = $003B7200; // #00723b

  // --- PaletteSteel ---
  flPaletteSteelBackground2Light: TColor = $00D4C894; // #94c8d4

  // ---  ---
  flPaletteSteelBorderActiveLight: TColor = $00705B00; // #005b70

  // --- PaletteSteel ---
  flPaletteSteelForeground2Light: TColor = $003F3300; // #00333f

  // --- PaletteTeal ---
  flPaletteTealBackground2Light: TColor = $00DBD99B; // #9bd9db

  // ---  ---
  flPaletteTealBorderActiveLight: TColor = $00878303; // #038387

  // --- PaletteTeal ---
  flPaletteTealForeground2Light: TColor = $004C4902; // #02494c

  // --- PaletteYellow ---
  flPaletteYellowBackground1Light: TColor = $00F5FEFF; // #fffef5
  flPaletteYellowBackground2Light: TColor = $00B2F7FE; // #fef7b2
  flPaletteYellowBackground3Light: TColor = $0000E3FD; // #fde300

  // --- PaletteYellowBorder ---
  flPaletteYellowBorder1Light: TColor = $00B2F7FE; // #fef7b2
  flPaletteYellowBorder2Light: TColor = $0000E3FD; // #fde300

  // ---  ---
  flPaletteYellowBorderActiveLight: TColor = $0000E3FD; // #fde300

  // --- PaletteYellow ---
  flPaletteYellowForeground1Light: TColor = $00007481; // #817400
  flPaletteYellowForeground2Light: TColor = $00007481; // #817400
  flPaletteYellowForeground3Light: TColor = $0000E3FD; // #fde300
  flPaletteYellowForegroundInvertedLight: TColor = $00B2F7FE; // #fef7b2

  // ---  ---
  flScrollbarOverlayLight: TColor = $00000000; // rgba(0, 0, 0, 0.5)

  // --- StatusDanger ---
  flStatusDangerBackground1Light: TColor = $00F4F3FD; // #fdf3f4
  flStatusDangerBackground2Light: TColor = $00B2ACEE; // #eeacb2
  flStatusDangerBackground3Light: TColor = $001F0FC5; // #c50f1f
  flStatusDangerBackground3HoverLight: TColor = $001C0EB1; // #b10e1c
  flStatusDangerBackground3PressedLight: TColor = $00180B96; // #960b18

  // --- StatusDangerBorder ---
  flStatusDangerBorder1Light: TColor = $00B2ACEE; // #eeacb2
  flStatusDangerBorder2Light: TColor = $001F0FC5; // #c50f1f

  // ---  ---
  flStatusDangerBorderActiveLight: TColor = $001F0FC5; // #c50f1f

  // --- StatusDanger ---
  flStatusDangerForeground1Light: TColor = $001C0EB1; // #b10e1c
  flStatusDangerForeground2Light: TColor = $0011086E; // #6e0811
  flStatusDangerForeground3Light: TColor = $001F0FC5; // #c50f1f
  flStatusDangerForegroundInvertedLight: TColor = $006D62DC; // #dc626d

  // --- StatusSuccess ---
  flStatusSuccessBackground1Light: TColor = $00F1FAF1; // #f1faf1
  flStatusSuccessBackground2Light: TColor = $009FD89F; // #9fd89f
  flStatusSuccessBackground3Light: TColor = $00107C10; // #107c10

  // --- StatusSuccessBorder ---
  flStatusSuccessBorder1Light: TColor = $009FD89F; // #9fd89f
  flStatusSuccessBorder2Light: TColor = $00107C10; // #107c10

  // ---  ---
  flStatusSuccessBorderActiveLight: TColor = $00107C10; // #107c10

  // --- StatusSuccess ---
  flStatusSuccessForeground1Light: TColor = $000E700E; // #0e700e
  flStatusSuccessForeground2Light: TColor = $00094509; // #094509
  flStatusSuccessForeground3Light: TColor = $00107C10; // #107c10
  flStatusSuccessForegroundInvertedLight: TColor = $0054B054; // #54b054

  // --- StatusWarning ---
  flStatusWarningBackground1Light: TColor = $00F5F9FF; // #fff9f5
  flStatusWarningBackground2Light: TColor = $00B4CFFD; // #fdcfb4
  flStatusWarningBackground3Light: TColor = $000C63F7; // #f7630c

  // --- StatusWarningBorder ---
  flStatusWarningBorder1Light: TColor = $00B4CFFD; // #fdcfb4
  flStatusWarningBorder2Light: TColor = $00094BBC; // #bc4b09

  // ---  ---
  flStatusWarningBorderActiveLight: TColor = $000C63F7; // #f7630c

  // --- StatusWarning ---
  flStatusWarningForeground1Light: TColor = $00094BBC; // #bc4b09
  flStatusWarningForeground2Light: TColor = $0007378A; // #8a3707
  flStatusWarningForeground3Light: TColor = $00094BBC; // #bc4b09
  flStatusWarningForegroundInvertedLight: TColor = $006BA0FA; // #faa06b

  // --- StrokeFocus ---
  flStrokeFocus1Light: TColor = $00FFFFFF; // #ffffff
  flStrokeFocus2Light: TColor = $00000000; // #000000

  // --- Subtle ---
  flSubtleBackgroundHoverLight: TColor = $00F5F5F5; // #f5f5f5
  flSubtleBackgroundInvertedHoverLight: TColor = $00000000; // rgba(0, 0, 0, 0.1)
  flSubtleBackgroundInvertedPressedLight: TColor = $00000000; // rgba(0, 0, 0, 0.3)
  flSubtleBackgroundInvertedSelectedLight: TColor = $00000000; // rgba(0, 0, 0, 0.2)
  flSubtleBackgroundLightAlphaHoverLight: TColor = $00FFFFFF; // rgba(255, 255, 255, 0.7)
  flSubtleBackgroundLightAlphaPressedLight: TColor = $00FFFFFF; // rgba(255, 255, 255, 0.5)
  flSubtleBackgroundPressedLight: TColor = $00E0E0E0; // #e0e0e0
  flSubtleBackgroundSelectedLight: TColor = $00EBEBEB; // #ebebeb

  flBackgroundOverlayDark: TColor = $00000000; // rgba(0, 0, 0, 0.5)

  // --- Brand ---
  flBrandBackgroundDark: TColor = $00A35E11; // #115ea3
  flBrandBackground2Dark: TColor = $00382308; // #082338
  flBrandBackground2HoverDark: TColor = $005E3B0C; // #0c3b5e
  flBrandBackground2PressedDark: TColor = $00241706; // #061724
  flBrandBackground3StaticDark: TColor = $008C540F; // #0f548c
  flBrandBackground4StaticDark: TColor = $005E3B0C; // #0c3b5e
  flBrandBackgroundHoverDark: TColor = $00BD6C0F; // #0f6cbd
  flBrandBackgroundInvertedDark: TColor = $00FFFFFF; // #ffffff
  flBrandBackgroundInvertedHoverDark: TColor = $00FCF3EB; // #ebf3fc
  flBrandBackgroundInvertedPressedDark: TColor = $00FAD6B4; // #b4d6fa
  flBrandBackgroundInvertedSelectedDark: TColor = $00FAE4CF; // #cfe4fa
  flBrandBackgroundPressedDark: TColor = $005E3B0C; // #0c3b5e
  flBrandBackgroundSelectedDark: TColor = $008C540F; // #0f548c
  flBrandBackgroundStaticDark: TColor = $00BD6C0F; // #0f6cbd
  flBrandForeground1Dark: TColor = $00F59E47; // #479ef5
  flBrandForeground2Dark: TColor = $00F5AB62; // #62abf5
  flBrandForeground2HoverDark: TColor = $00FAC696; // #96c6fa
  flBrandForeground2PressedDark: TColor = $00FCF3EB; // #ebf3fc
  flBrandForegroundInvertedDark: TColor = $00BD6C0F; // #0f6cbd
  flBrandForegroundInvertedHoverDark: TColor = $00A35E11; // #115ea3
  flBrandForegroundInvertedPressedDark: TColor = $008C540F; // #0f548c
  flBrandForegroundLinkDark: TColor = $00F59E47; // #479ef5
  flBrandForegroundLinkHoverDark: TColor = $00F5AB62; // #62abf5
  flBrandForegroundLinkPressedDark: TColor = $00DE8628; // #2886de
  flBrandForegroundLinkSelectedDark: TColor = $00F59E47; // #479ef5
  flBrandForegroundOnLightDark: TColor = $00BD6C0F; // #0f6cbd
  flBrandForegroundOnLightHoverDark: TColor = $00A35E11; // #115ea3
  flBrandForegroundOnLightPressedDark: TColor = $0075470E; // #0e4775
  flBrandForegroundOnLightSelectedDark: TColor = $008C540F; // #0f548c
  flBrandShadowAmbientDark: TColor = $00000000; // rgba(0,0,0,0.30)
  flBrandShadowKeyDark: TColor = $00000000; // rgba(0,0,0,0.25)
  flBrandStroke1Dark: TColor = $00F59E47; // #479ef5
  flBrandStroke2Dark: TColor = $0075470E; // #0e4775
  flBrandStroke2ContrastDark: TColor = $0075470E; // #0e4775
  flBrandStroke2HoverDark: TColor = $0075470E; // #0e4775
  flBrandStroke2PressedDark: TColor = $004A2E0A; // #0a2e4a

  // --- CompoundBrand ---
  flCompoundBrandBackgroundDark: TColor = $00F59E47; // #479ef5
  flCompoundBrandBackgroundHoverDark: TColor = $00F5AB62; // #62abf5
  flCompoundBrandBackgroundPressedDark: TColor = $00DE8628; // #2886de
  flCompoundBrandForeground1Dark: TColor = $00F59E47; // #479ef5
  flCompoundBrandForeground1HoverDark: TColor = $00F5AB62; // #62abf5
  flCompoundBrandForeground1PressedDark: TColor = $00DE8628; // #2886de
  flCompoundBrandStrokeDark: TColor = $00F59E47; // #479ef5
  flCompoundBrandStrokeHoverDark: TColor = $00F5AB62; // #62abf5
  flCompoundBrandStrokePressedDark: TColor = $00DE8628; // #2886de

  // --- Neutral ---
  flNeutralBackground1Dark: TColor = $00292929; // #292929
  flNeutralBackground1HoverDark: TColor = $003D3D3D; // #3d3d3d
  flNeutralBackground1PressedDark: TColor = $001F1F1F; // #1f1f1f
  flNeutralBackground1SelectedDark: TColor = $00383838; // #383838
  flNeutralBackground2Dark: TColor = $001F1F1F; // #1f1f1f
  flNeutralBackground2HoverDark: TColor = $00333333; // #333333
  flNeutralBackground2PressedDark: TColor = $00141414; // #141414
  flNeutralBackground2SelectedDark: TColor = $002E2E2E; // #2e2e2e
  flNeutralBackground3Dark: TColor = $00141414; // #141414
  flNeutralBackground3HoverDark: TColor = $00292929; // #292929
  flNeutralBackground3PressedDark: TColor = $000A0A0A; // #0a0a0a
  flNeutralBackground3SelectedDark: TColor = $00242424; // #242424
  flNeutralBackground4Dark: TColor = $000A0A0A; // #0a0a0a
  flNeutralBackground4HoverDark: TColor = $001F1F1F; // #1f1f1f
  flNeutralBackground4PressedDark: TColor = $00000000; // #000000
  flNeutralBackground4SelectedDark: TColor = $001A1A1A; // #1a1a1a
  flNeutralBackground5Dark: TColor = $00000000; // #000000
  flNeutralBackground5HoverDark: TColor = $00141414; // #141414
  flNeutralBackground5PressedDark: TColor = $00050505; // #050505
  flNeutralBackground5SelectedDark: TColor = $000F0F0F; // #0f0f0f
  flNeutralBackground6Dark: TColor = $00333333; // #333333
  flNeutralBackground7Dark: TColor = $00000000; // #00000000
  flNeutralBackground7HoverDark: TColor = $001A1A1A; // #1a1a1a
  flNeutralBackground7PressedDark: TColor = $000A0A0A; // #0a0a0a
  flNeutralBackground7SelectedDark: TColor = $00000000; // #00000000
  flNeutralBackground8Dark: TColor = $00292929; // #292929
  flNeutralBackgroundAlphaDark: TColor = $001A1A1A; // rgba(26, 26, 26, 0.5)
  flNeutralBackgroundAlpha2Dark: TColor = $001F1F1F; // rgba(31, 31, 31, 0.7)
  flNeutralBackgroundDisabledDark: TColor = $00141414; // #141414
  flNeutralBackgroundDisabled2Dark: TColor = $00292929; // #292929
  flNeutralBackgroundInvertedDark: TColor = $00FFFFFF; // #ffffff
  flNeutralBackgroundInvertedDisabledDark: TColor = $00FFFFFF; // rgba(255, 255, 255, 0.1)
  flNeutralBackgroundInvertedHoverDark: TColor = $00F5F5F5; // #f5f5f5
  flNeutralBackgroundInvertedPressedDark: TColor = $00E0E0E0; // #e0e0e0
  flNeutralBackgroundInvertedSelectedDark: TColor = $00EBEBEB; // #ebebeb
  flNeutralBackgroundStaticDark: TColor = $003D3D3D; // #3d3d3d
  flNeutralCardBackgroundDark: TColor = $00333333; // #333333
  flNeutralCardBackgroundDisabledDark: TColor = $00141414; // #141414
  flNeutralCardBackgroundHoverDark: TColor = $003D3D3D; // #3d3d3d
  flNeutralCardBackgroundPressedDark: TColor = $002E2E2E; // #2e2e2e
  flNeutralCardBackgroundSelectedDark: TColor = $00383838; // #383838
  flNeutralForeground1Dark: TColor = $00FFFFFF; // #ffffff
  flNeutralForeground1HoverDark: TColor = $00FFFFFF; // #ffffff
  flNeutralForeground1PressedDark: TColor = $00FFFFFF; // #ffffff
  flNeutralForeground1SelectedDark: TColor = $00FFFFFF; // #ffffff
  flNeutralForeground1StaticDark: TColor = $00242424; // #242424
  flNeutralForeground2Dark: TColor = $00D6D6D6; // #d6d6d6
  flNeutralForeground2BrandHoverDark: TColor = $00F59E47; // #479ef5
  flNeutralForeground2BrandPressedDark: TColor = $00DE8628; // #2886de
  flNeutralForeground2BrandSelectedDark: TColor = $00F59E47; // #479ef5
  flNeutralForeground2HoverDark: TColor = $00FFFFFF; // #ffffff
  flNeutralForeground2LinkDark: TColor = $00D6D6D6; // #d6d6d6
  flNeutralForeground2LinkHoverDark: TColor = $00FFFFFF; // #ffffff
  flNeutralForeground2LinkPressedDark: TColor = $00FFFFFF; // #ffffff
  flNeutralForeground2LinkSelectedDark: TColor = $00FFFFFF; // #ffffff
  flNeutralForeground2PressedDark: TColor = $00FFFFFF; // #ffffff
  flNeutralForeground2SelectedDark: TColor = $00FFFFFF; // #ffffff
  flNeutralForeground3Dark: TColor = $00ADADAD; // #adadad
  flNeutralForeground3BrandHoverDark: TColor = $00F59E47; // #479ef5
  flNeutralForeground3BrandPressedDark: TColor = $00DE8628; // #2886de
  flNeutralForeground3BrandSelectedDark: TColor = $00F59E47; // #479ef5
  flNeutralForeground3HoverDark: TColor = $00D6D6D6; // #d6d6d6
  flNeutralForeground3PressedDark: TColor = $00D6D6D6; // #d6d6d6
  flNeutralForeground3SelectedDark: TColor = $00D6D6D6; // #d6d6d6
  flNeutralForeground4Dark: TColor = $00999999; // #999999
  flNeutralForeground5Dark: TColor = $00ADADAD; // #adadad
  flNeutralForeground5HoverDark: TColor = $00FFFFFF; // #ffffff
  flNeutralForeground5PressedDark: TColor = $00FFFFFF; // #ffffff
  flNeutralForeground5SelectedDark: TColor = $00FFFFFF; // #ffffff
  flNeutralForegroundDisabledDark: TColor = $005C5C5C; // #5c5c5c
  flNeutralForegroundInvertedDark: TColor = $00242424; // #242424
  flNeutralForegroundInverted2Dark: TColor = $00242424; // #242424
  flNeutralForegroundInvertedDisabledDark: TColor = $00FFFFFF; // rgba(255, 255, 255, 0.4)
  flNeutralForegroundInvertedHoverDark: TColor = $00242424; // #242424
  flNeutralForegroundInvertedLinkDark: TColor = $00FFFFFF; // #ffffff
  flNeutralForegroundInvertedLinkHoverDark: TColor = $00FFFFFF; // #ffffff
  flNeutralForegroundInvertedLinkPressedDark: TColor = $00FFFFFF; // #ffffff
  flNeutralForegroundInvertedLinkSelectedDark: TColor = $00FFFFFF; // #ffffff
  flNeutralForegroundInvertedPressedDark: TColor = $00242424; // #242424
  flNeutralForegroundInvertedSelectedDark: TColor = $00242424; // #242424
  flNeutralForegroundOnBrandDark: TColor = $00FFFFFF; // #ffffff
  flNeutralForegroundStaticInvertedDark: TColor = $00FFFFFF; // #ffffff
  flNeutralShadowAmbientDark: TColor = $00000000; // rgba(0,0,0,0.24)
  flNeutralShadowAmbientDarkerDark: TColor = $00000000; // rgba(0,0,0,0.40)
  flNeutralShadowAmbientLighterDark: TColor = $00000000; // rgba(0,0,0,0.12)
  flNeutralShadowKeyDark: TColor = $00000000; // rgba(0,0,0,0.28)
  flNeutralShadowKeyDarkerDark: TColor = $00000000; // rgba(0,0,0,0.48)
  flNeutralShadowKeyLighterDark: TColor = $00000000; // rgba(0,0,0,0.14)
  flNeutralStencil1Dark: TColor = $00575757; // #575757
  flNeutralStencil1AlphaDark: TColor = $00FFFFFF; // rgba(255, 255, 255, 0.1)
  flNeutralStencil2Dark: TColor = $00333333; // #333333
  flNeutralStencil2AlphaDark: TColor = $00FFFFFF; // rgba(255, 255, 255, 0.05)
  flNeutralStroke1Dark: TColor = $00666666; // #666666
  flNeutralStroke1HoverDark: TColor = $00757575; // #757575
  flNeutralStroke1PressedDark: TColor = $006B6B6B; // #6b6b6b
  flNeutralStroke1SelectedDark: TColor = $00707070; // #707070
  flNeutralStroke2Dark: TColor = $00525252; // #525252
  flNeutralStroke3Dark: TColor = $003D3D3D; // #3d3d3d
  flNeutralStroke4Dark: TColor = $003D3D3D; // #3d3d3d
  flNeutralStroke4HoverDark: TColor = $002E2E2E; // #2e2e2e
  flNeutralStroke4PressedDark: TColor = $00242424; // #242424
  flNeutralStroke4SelectedDark: TColor = $003D3D3D; // #3d3d3d
  flNeutralStrokeAccessibleDark: TColor = $00ADADAD; // #adadad
  flNeutralStrokeAccessibleHoverDark: TColor = $00BDBDBD; // #bdbdbd
  flNeutralStrokeAccessiblePressedDark: TColor = $00B3B3B3; // #b3b3b3
  flNeutralStrokeAccessibleSelectedDark: TColor = $00F59E47; // #479ef5
  flNeutralStrokeAlphaDark: TColor = $00FFFFFF; // rgba(255, 255, 255, 0.1)
  flNeutralStrokeAlpha2Dark: TColor = $00FFFFFF; // rgba(255, 255, 255, 0.2)
  flNeutralStrokeDisabledDark: TColor = $00424242; // #424242
  flNeutralStrokeDisabled2Dark: TColor = $003D3D3D; // #3d3d3d
  flNeutralStrokeInvertedDisabledDark: TColor = $00FFFFFF; // rgba(255, 255, 255, 0.4)
  flNeutralStrokeOnBrandDark: TColor = $00292929; // #292929
  flNeutralStrokeOnBrand2Dark: TColor = $00FFFFFF; // #ffffff
  flNeutralStrokeOnBrand2HoverDark: TColor = $00FFFFFF; // #ffffff
  flNeutralStrokeOnBrand2PressedDark: TColor = $00FFFFFF; // #ffffff
  flNeutralStrokeOnBrand2SelectedDark: TColor = $00FFFFFF; // #ffffff
  flNeutralStrokeSubtleDark: TColor = $000A0A0A; // #0a0a0a

  // --- PaletteAnchor ---
  flPaletteAnchorBackground2Dark: TColor = $00272420; // #202427

  // ---  ---
  flPaletteAnchorBorderActiveDark: TColor = $00908A80; // #808a90

  // --- PaletteAnchor ---
  flPaletteAnchorForeground2Dark: TColor = $00C7C3BC; // #bcc3c7

  // --- PaletteBeige ---
  flPaletteBeigeBackground2Dark: TColor = $00414244; // #444241

  // ---  ---
  flPaletteBeigeBorderActiveDark: TColor = $00AAABAF; // #afabaa

  // --- PaletteBeige ---
  flPaletteBeigeForeground2Dark: TColor = $00D4D4D7; // #d7d4d4

  // --- PaletteBerry ---
  flPaletteBerryBackground1Dark: TColor = $0036113A; // #3a1136
  flPaletteBerryBackground2Dark: TColor = $0064206D; // #6d2064
  flPaletteBerryBackground3Dark: TColor = $00B339C2; // #c239b3

  // --- PaletteBerryBorder ---
  flPaletteBerryBorder1Dark: TColor = $00B339C2; // #c239b3
  flPaletteBerryBorder2Dark: TColor = $00C461D1; // #d161c4

  // ---  ---
  flPaletteBerryBorderActiveDark: TColor = $00D07EDA; // #da7ed0

  // --- PaletteBerry ---
  flPaletteBerryForeground1Dark: TColor = $00D07EDA; // #da7ed0
  flPaletteBerryForeground2Dark: TColor = $00E7BBED; // #edbbe7
  flPaletteBerryForeground3Dark: TColor = $00C461D1; // #d161c4

  // --- PaletteBlue ---
  flPaletteBlueBackground2Dark: TColor = $00774300; // #004377

  // ---  ---
  flPaletteBlueBorderActiveDark: TColor = $00E5AA5C; // #5caae5

  // --- PaletteBlue ---
  flPaletteBlueForeground2Dark: TColor = $00F2D3A9; // #a9d3f2

  // --- PaletteBrass ---
  flPaletteBrassBackground2Dark: TColor = $00063E55; // #553e06

  // ---  ---
  flPaletteBrassBorderActiveDark: TColor = $0056A2C1; // #c1a256

  // --- PaletteBrass ---
  flPaletteBrassForeground2Dark: TColor = $00A2CEE0; // #e0cea2

  // --- PaletteBrown ---
  flPaletteBrownBackground2Dark: TColor = $001A3050; // #50301a

  // ---  ---
  flPaletteBrownBorderActiveDark: TColor = $006F8FBB; // #bb8f6f

  // --- PaletteBrown ---
  flPaletteBrownForeground2Dark: TColor = $00B0C3DD; // #ddc3b0

  // --- PaletteCornflower ---
  flPaletteCornflowerBackground2Dark: TColor = $00853C2C; // #2c3c85

  // ---  ---
  flPaletteCornflowerBorderActiveDark: TColor = $00F4A493; // #93a4f4

  // --- PaletteCornflower ---
  flPaletteCornflowerForeground2Dark: TColor = $00FAD1C8; // #c8d1fa

  // --- PaletteCranberry ---
  flPaletteCranberryBackground2Dark: TColor = $0011086E; // #6e0811

  // ---  ---
  flPaletteCranberryBorderActiveDark: TColor = $006D62DC; // #dc626d

  // --- PaletteCranberry ---
  flPaletteCranberryForeground2Dark: TColor = $00B2ACEE; // #eeacb2

  // --- PaletteDarkGreen ---
  flPaletteDarkGreenBackground2Dark: TColor = $00063B06; // #063b06

  // ---  ---
  flPaletteDarkGreenBorderActiveDark: TColor = $004DA64D; // #4da64d

  // --- PaletteDarkGreen ---
  flPaletteDarkGreenForeground2Dark: TColor = $009AD29A; // #9ad29a

  // --- PaletteDarkOrange ---
  flPaletteDarkOrangeBackground1Dark: TColor = $00001241; // #411200
  flPaletteDarkOrangeBackground2Dark: TColor = $0001217A; // #7a2101
  flPaletteDarkOrangeBackground3Dark: TColor = $00013BDA; // #da3b01

  // --- PaletteDarkOrangeBorder ---
  flPaletteDarkOrangeBorder1Dark: TColor = $00013BDA; // #da3b01
  flPaletteDarkOrangeBorder2Dark: TColor = $005E83E9; // #e9835e

  // ---  ---
  flPaletteDarkOrangeBorderActiveDark: TColor = $005E83E9; // #e9835e

  // --- PaletteDarkOrange ---
  flPaletteDarkOrangeForeground1Dark: TColor = $005E83E9; // #e9835e
  flPaletteDarkOrangeForeground2Dark: TColor = $00ABBFF4; // #f4bfab
  flPaletteDarkOrangeForeground3Dark: TColor = $005E83E9; // #e9835e

  // --- PaletteDarkRed ---
  flPaletteDarkRedBackground2Dark: TColor = $00150859; // #590815

  // ---  ---
  flPaletteDarkRedBorderActiveDark: TColor = $005E4FAC; // #ac4f5e

  // --- PaletteDarkRed ---
  flPaletteDarkRedForeground2Dark: TColor = $00A59CD6; // #d69ca5

  // --- PaletteForest ---
  flPaletteForestBackground2Dark: TColor = $00034929; // #294903

  // ---  ---
  flPaletteForestBorderActiveDark: TColor = $004CB485; // #85b44c

  // --- PaletteForest ---
  flPaletteForestForeground2Dark: TColor = $009BD9BD; // #bdd99b

  // --- PaletteGold ---
  flPaletteGoldBackground2Dark: TColor = $0000576C; // #6c5700

  // ---  ---
  flPaletteGoldBorderActiveDark: TColor = $0057C1DA; // #dac157

  // --- PaletteGold ---
  flPaletteGoldForeground2Dark: TColor = $00A5DFEC; // #ecdfa5

  // --- PaletteGrape ---
  flPaletteGrapeBackground2Dark: TColor = $00550D4C; // #4c0d55

  // ---  ---
  flPaletteGrapeBorderActiveDark: TColor = $00C15FB5; // #b55fc1

  // --- PaletteGrape ---
  flPaletteGrapeForeground2Dark: TColor = $00E0A7D9; // #d9a7e0

  // --- PaletteGreen ---
  flPaletteGreenBackground1Dark: TColor = $00052505; // #052505
  flPaletteGreenBackground2Dark: TColor = $00094509; // #094509
  flPaletteGreenBackground3Dark: TColor = $00107C10; // #107c10

  // --- PaletteGreenBorder ---
  flPaletteGreenBorder1Dark: TColor = $00107C10; // #107c10
  flPaletteGreenBorder2Dark: TColor = $009FD89F; // #9fd89f

  // ---  ---
  flPaletteGreenBorderActiveDark: TColor = $0054B054; // #54b054

  // --- PaletteGreen ---
  flPaletteGreenForeground1Dark: TColor = $0054B054; // #54b054
  flPaletteGreenForeground2Dark: TColor = $009FD89F; // #9fd89f
  flPaletteGreenForeground3Dark: TColor = $009FD89F; // #9fd89f
  flPaletteGreenForegroundInvertedDark: TColor = $00107C10; // #107c10

  // --- PaletteLavender ---
  flPaletteLavenderBackground2Dark: TColor = $0082363F; // #3f3682

  // ---  ---
  flPaletteLavenderBorderActiveDark: TColor = $00F19CA7; // #a79cf1

  // --- PaletteLavender ---
  flPaletteLavenderForeground2Dark: TColor = $00F8CCD2; // #d2ccf8

  // --- PaletteLightGreen ---
  flPaletteLightGreenBackground1Dark: TColor = $00043006; // #063004
  flPaletteLightGreenBackground2Dark: TColor = $00085A0B; // #0b5a08
  flPaletteLightGreenBackground3Dark: TColor = $000EA113; // #13a10e

  // --- PaletteLightGreenBorder ---
  flPaletteLightGreenBorder1Dark: TColor = $000EA113; // #13a10e
  flPaletteLightGreenBorder2Dark: TColor = $0038B83D; // #3db838

  // ---  ---
  flPaletteLightGreenBorderActiveDark: TColor = $005AC75E; // #5ec75a

  // --- PaletteLightGreen ---
  flPaletteLightGreenForeground1Dark: TColor = $005AC75E; // #5ec75a
  flPaletteLightGreenForeground2Dark: TColor = $00A5E3A7; // #a7e3a5
  flPaletteLightGreenForeground3Dark: TColor = $0038B83D; // #3db838

  // --- PaletteLightTeal ---
  flPaletteLightTealBackground2Dark: TColor = $006D6600; // #00666d

  // ---  ---
  flPaletteLightTealBorderActiveDark: TColor = $00DBD358; // #58d3db

  // --- PaletteLightTeal ---
  flPaletteLightTealForeground2Dark: TColor = $00EDE9A6; // #a6e9ed

  // --- PaletteLilac ---
  flPaletteLilacBackground2Dark: TColor = $006D2763; // #63276d

  // ---  ---
  flPaletteLilacBorderActiveDark: TColor = $00DA87CF; // #cf87da

  // --- PaletteLilac ---
  flPaletteLilacForeground2Dark: TColor = $00EDBFE6; // #e6bfed

  // --- PaletteMagenta ---
  flPaletteMagentaBackground2Dark: TColor = $0043006B; // #6b0043

  // ---  ---
  flPaletteMagentaBorderActiveDark: TColor = $00A857D9; // #d957a8

  // --- PaletteMagenta ---
  flPaletteMagentaForeground2Dark: TColor = $00D1A5EC; // #eca5d1

  // --- PaletteMarigold ---
  flPaletteMarigoldBackground1Dark: TColor = $00003146; // #463100
  flPaletteMarigoldBackground2Dark: TColor = $00005B83; // #835b00
  flPaletteMarigoldBackground3Dark: TColor = $0000A3EA; // #eaa300

  // --- PaletteMarigoldBorder ---
  flPaletteMarigoldBorder1Dark: TColor = $0000A3EA; // #eaa300
  flPaletteMarigoldBorder2Dark: TColor = $0039B8EF; // #efb839

  // ---  ---
  flPaletteMarigoldBorderActiveDark: TColor = $0061C6F2; // #f2c661

  // --- PaletteMarigold ---
  flPaletteMarigoldForeground1Dark: TColor = $0061C6F2; // #f2c661
  flPaletteMarigoldForeground2Dark: TColor = $00AEE2F9; // #f9e2ae
  flPaletteMarigoldForeground3Dark: TColor = $0039B8EF; // #efb839

  // --- PaletteMink ---
  flPaletteMinkBackground2Dark: TColor = $00313234; // #343231

  // ---  ---
  flPaletteMinkBorderActiveDark: TColor = $00999B9E; // #9e9b99

  // --- PaletteMink ---
  flPaletteMinkForeground2Dark: TColor = $00CBCCCE; // #cecccb

  // --- PaletteNavy ---
  flPaletteNavyBackground2Dark: TColor = $00651600; // #001665

  // ---  ---
  flPaletteNavyBorderActiveDark: TColor = $00D26F54; // #546fd2

  // --- PaletteNavy ---
  flPaletteNavyForeground2Dark: TColor = $00E8B2A3; // #a3b2e8

  // --- PalettePeach ---
  flPalettePeachBackground2Dark: TColor = $00004E8F; // #8f4e00

  // ---  ---
  flPalettePeachBorderActiveDark: TColor = $0066BAFF; // #ffba66

  // --- PalettePeach ---
  flPalettePeachForeground2Dark: TColor = $00B3DDFF; // #ffddb3

  // --- PalettePink ---
  flPalettePinkBackground2Dark: TColor = $005D2180; // #80215d

  // ---  ---
  flPalettePinkBorderActiveDark: TColor = $00C885EF; // #ef85c8

  // --- PalettePink ---
  flPalettePinkForeground2Dark: TColor = $00E3C0F7; // #f7c0e3

  // --- PalettePlatinum ---
  flPalettePlatinumBackground2Dark: TColor = $0047443B; // #3b4447

  // ---  ---
  flPalettePlatinumBorderActiveDark: TColor = $00B2ADA0; // #a0adb2

  // --- PalettePlatinum ---
  flPalettePlatinumForeground2Dark: TColor = $00D8D6CD; // #cdd6d8

  // --- PalettePlum ---
  flPalettePlumBackground2Dark: TColor = $003B005A; // #5a003b

  // ---  ---
  flPalettePlumBorderActiveDark: TColor = $008945AD; // #ad4589

  // --- PalettePlum ---
  flPalettePlumForeground2Dark: TColor = $00C096D6; // #d696c0

  // --- PalettePumpkin ---
  flPalettePumpkinBackground2Dark: TColor = $00092D71; // #712d09

  // ---  ---
  flPalettePumpkinBorderActiveDark: TColor = $00648EDF; // #df8e64

  // --- PalettePumpkin ---
  flPalettePumpkinForeground2Dark: TColor = $00ADC4EF; // #efc4ad

  // --- PalettePurple ---
  flPalettePurpleBackground2Dark: TColor = $00511A34; // #341a51

  // ---  ---
  flPalettePurpleBorderActiveDark: TColor = $00BD7094; // #9470bd

  // --- PalettePurple ---
  flPalettePurpleForeground2Dark: TColor = $00DEB1C6; // #c6b1de

  // --- PaletteRed ---
  flPaletteRedBackground1Dark: TColor = $0011103F; // #3f1011
  flPaletteRedBackground2Dark: TColor = $001F1D75; // #751d1f
  flPaletteRedBackground3Dark: TColor = $003834D1; // #d13438

  // --- PaletteRedBorder ---
  flPaletteRedBorder1Dark: TColor = $003834D1; // #d13438
  flPaletteRedBorder2Dark: TColor = $00807DE3; // #e37d80

  // ---  ---
  flPaletteRedBorderActiveDark: TColor = $00807DE3; // #e37d80

  // --- PaletteRed ---
  flPaletteRedForeground1Dark: TColor = $00807DE3; // #e37d80
  flPaletteRedForeground2Dark: TColor = $00BCBBF1; // #f1bbbc
  flPaletteRedForeground3Dark: TColor = $00807DE3; // #e37d80
  flPaletteRedForegroundInvertedDark: TColor = $003834D1; // #d13438

  // --- PaletteRoyalBlue ---
  flPaletteRoyalBlueBackground2Dark: TColor = $004E2C00; // #002c4e

  // ---  ---
  flPaletteRoyalBlueBorderActiveDark: TColor = $00BA894A; // #4a89ba

  // --- PaletteRoyalBlue ---
  flPaletteRoyalBlueForeground2Dark: TColor = $00DCBF9A; // #9abfdc

  // --- PaletteSeafoam ---
  flPaletteSeafoamBackground2Dark: TColor = $003B7200; // #00723b

  // ---  ---
  flPaletteSeafoamBorderActiveDark: TColor = $00A0E05A; // #5ae0a0

  // --- PaletteSeafoam ---
  flPaletteSeafoamForeground2Dark: TColor = $00CDF0A8; // #a8f0cd

  // --- PaletteSteel ---
  flPaletteSteelBackground2Dark: TColor = $003F3300; // #00333f

  // ---  ---
  flPaletteSteelBorderActiveDark: TColor = $00A99644; // #4496a9

  // --- PaletteSteel ---
  flPaletteSteelForeground2Dark: TColor = $00D4C894; // #94c8d4

  // --- PaletteTeal ---
  flPaletteTealBackground2Dark: TColor = $004C4902; // #02494c

  // ---  ---
  flPaletteTealBorderActiveDark: TColor = $00B7B44C; // #4cb4b7

  // --- PaletteTeal ---
  flPaletteTealForeground2Dark: TColor = $00DBD99B; // #9bd9db

  // --- PaletteYellow ---
  flPaletteYellowBackground1Dark: TColor = $0000444C; // #4c4400
  flPaletteYellowBackground2Dark: TColor = $00007481; // #817400
  flPaletteYellowBackground3Dark: TColor = $0000E3FD; // #fde300

  // --- PaletteYellowBorder ---
  flPaletteYellowBorder1Dark: TColor = $0000E3FD; // #fde300
  flPaletteYellowBorder2Dark: TColor = $003DEAFD; // #fdea3d

  // ---  ---
  flPaletteYellowBorderActiveDark: TColor = $0066EEFE; // #feee66

  // --- PaletteYellow ---
  flPaletteYellowForeground1Dark: TColor = $0066EEFE; // #feee66
  flPaletteYellowForeground2Dark: TColor = $00B2F7FE; // #fef7b2
  flPaletteYellowForeground3Dark: TColor = $003DEAFD; // #fdea3d
  flPaletteYellowForegroundInvertedDark: TColor = $00007481; // #817400

  // ---  ---
  flScrollbarOverlayDark: TColor = $00FFFFFF; // rgba(255, 255, 255, 0.6)

  // --- StatusDanger ---
  flStatusDangerBackground1Dark: TColor = $0009053B; // #3b0509
  flStatusDangerBackground2Dark: TColor = $0011086E; // #6e0811
  flStatusDangerBackground3Dark: TColor = $001F0FC5; // #c50f1f
  flStatusDangerBackground3HoverDark: TColor = $001C0EB1; // #b10e1c
  flStatusDangerBackground3PressedDark: TColor = $00180B96; // #960b18

  // --- StatusDangerBorder ---
  flStatusDangerBorder1Dark: TColor = $001F0FC5; // #c50f1f
  flStatusDangerBorder2Dark: TColor = $006D62DC; // #dc626d

  // ---  ---
  flStatusDangerBorderActiveDark: TColor = $006D62DC; // #dc626d

  // --- StatusDanger ---
  flStatusDangerForeground1Dark: TColor = $006D62DC; // #dc626d
  flStatusDangerForeground2Dark: TColor = $00B2ACEE; // #eeacb2
  flStatusDangerForeground3Dark: TColor = $00B2ACEE; // #eeacb2
  flStatusDangerForegroundInvertedDark: TColor = $001C0EB1; // #b10e1c

  // --- StatusSuccess ---
  flStatusSuccessBackground1Dark: TColor = $00052505; // #052505
  flStatusSuccessBackground2Dark: TColor = $00094509; // #094509
  flStatusSuccessBackground3Dark: TColor = $00107C10; // #107c10

  // --- StatusSuccessBorder ---
  flStatusSuccessBorder1Dark: TColor = $00107C10; // #107c10
  flStatusSuccessBorder2Dark: TColor = $009FD89F; // #9fd89f

  // ---  ---
  flStatusSuccessBorderActiveDark: TColor = $0054B054; // #54b054

  // --- StatusSuccess ---
  flStatusSuccessForeground1Dark: TColor = $0054B054; // #54b054
  flStatusSuccessForeground2Dark: TColor = $009FD89F; // #9fd89f
  flStatusSuccessForeground3Dark: TColor = $009FD89F; // #9fd89f
  flStatusSuccessForegroundInvertedDark: TColor = $000E700E; // #0e700e

  // --- StatusWarning ---
  flStatusWarningBackground1Dark: TColor = $00041E4A; // #4a1e04
  flStatusWarningBackground2Dark: TColor = $0007378A; // #8a3707
  flStatusWarningBackground3Dark: TColor = $000C63F7; // #f7630c

  // --- StatusWarningBorder ---
  flStatusWarningBorder1Dark: TColor = $000C63F7; // #f7630c
  flStatusWarningBorder2Dark: TColor = $004588F9; // #f98845

  // ---  ---
  flStatusWarningBorderActiveDark: TColor = $006BA0FA; // #faa06b

  // --- StatusWarning ---
  flStatusWarningForeground1Dark: TColor = $006BA0FA; // #faa06b
  flStatusWarningForeground2Dark: TColor = $00B4CFFD; // #fdcfb4
  flStatusWarningForeground3Dark: TColor = $004588F9; // #f98845
  flStatusWarningForegroundInvertedDark: TColor = $00094BBC; // #bc4b09

  // --- StrokeFocus ---
  flStrokeFocus1Dark: TColor = $00000000; // #000000
  flStrokeFocus2Dark: TColor = $00FFFFFF; // #ffffff

  // --- Subtle ---
  flSubtleBackgroundHoverDark: TColor = $00383838; // #383838
  flSubtleBackgroundInvertedHoverDark: TColor = $00000000; // rgba(0, 0, 0, 0.1)
  flSubtleBackgroundInvertedPressedDark: TColor = $00000000; // rgba(0, 0, 0, 0.3)
  flSubtleBackgroundInvertedSelectedDark: TColor = $00000000; // rgba(0, 0, 0, 0.2)
  flSubtleBackgroundLightAlphaHoverDark: TColor = $00242424; // rgba(36, 36, 36, 0.8)
  flSubtleBackgroundLightAlphaPressedDark: TColor = $00242424; // rgba(36, 36, 36, 0.5)
  flSubtleBackgroundPressedDark: TColor = $002E2E2E; // #2e2e2e
  flSubtleBackgroundSelectedDark: TColor = $00333333; // #333333

procedure FluentApplySystemTheme;
procedure FluentSetDarkMode(ADark: Boolean);
procedure FluentApplyTheme(AMode: TFluentThemeMode);
function FluentIsWindowsDarkMode: Boolean;

implementation

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils,
  System.Win.Registry, System.Generics.Collections;

var
  FThemeChangeHandlers: TList<TFluentThemeChangeProc>;

procedure RegisterThemeChange(const Handler: TFluentThemeChangeProc);
begin
  if not Assigned(FThemeChangeHandlers) then
    FThemeChangeHandlers := TList<TFluentThemeChangeProc>.Create;
  if not FThemeChangeHandlers.Contains(Handler) then
    FThemeChangeHandlers.Add(Handler);
end;

procedure UnregisterThemeChange(const Handler: TFluentThemeChangeProc);
begin
  if Assigned(FThemeChangeHandlers) then
    FThemeChangeHandlers.Remove(Handler);
end;

procedure NotifyThemeChange;
var
  Handler: TFluentThemeChangeProc;
begin
  if Assigned(FThemeChangeHandlers) then
    for Handler in FThemeChangeHandlers do
      Handler;
end;

procedure FluentApplyTheme(AMode: TFluentThemeMode);
begin
  FluentThemeMode := AMode;
  // An explicit light/dark choice stops following the system setting.
  FluentFollowSystemTheme := False;
  case AMode of
    ftmLight:
      begin
        flBackgroundOverlay := flBackgroundOverlayLight;
        flBrandBackground := flBrandBackgroundLight;
        flBrandBackground2 := flBrandBackground2Light;
        flBrandBackground2Hover := flBrandBackground2HoverLight;
        flBrandBackground2Pressed := flBrandBackground2PressedLight;
        flBrandBackground3Static := flBrandBackground3StaticLight;
        flBrandBackground4Static := flBrandBackground4StaticLight;
        flBrandBackgroundHover := flBrandBackgroundHoverLight;
        flBrandBackgroundInverted := flBrandBackgroundInvertedLight;
        flBrandBackgroundInvertedHover := flBrandBackgroundInvertedHoverLight;
        flBrandBackgroundInvertedPressed := flBrandBackgroundInvertedPressedLight;
        flBrandBackgroundInvertedSelected := flBrandBackgroundInvertedSelectedLight;
        flBrandBackgroundPressed := flBrandBackgroundPressedLight;
        flBrandBackgroundSelected := flBrandBackgroundSelectedLight;
        flBrandBackgroundStatic := flBrandBackgroundStaticLight;
        flBrandForeground1 := flBrandForeground1Light;
        flBrandForeground2 := flBrandForeground2Light;
        flBrandForeground2Hover := flBrandForeground2HoverLight;
        flBrandForeground2Pressed := flBrandForeground2PressedLight;
        flBrandForegroundInverted := flBrandForegroundInvertedLight;
        flBrandForegroundInvertedHover := flBrandForegroundInvertedHoverLight;
        flBrandForegroundInvertedPressed := flBrandForegroundInvertedPressedLight;
        flBrandForegroundLink := flBrandForegroundLinkLight;
        flBrandForegroundLinkHover := flBrandForegroundLinkHoverLight;
        flBrandForegroundLinkPressed := flBrandForegroundLinkPressedLight;
        flBrandForegroundLinkSelected := flBrandForegroundLinkSelectedLight;
        flBrandForegroundOnLight := flBrandForegroundOnLightLight;
        flBrandForegroundOnLightHover := flBrandForegroundOnLightHoverLight;
        flBrandForegroundOnLightPressed := flBrandForegroundOnLightPressedLight;
        flBrandForegroundOnLightSelected := flBrandForegroundOnLightSelectedLight;
        flBrandShadowAmbient := flBrandShadowAmbientLight;
        flBrandShadowKey := flBrandShadowKeyLight;
        flBrandStroke1 := flBrandStroke1Light;
        flBrandStroke2 := flBrandStroke2Light;
        flBrandStroke2Contrast := flBrandStroke2ContrastLight;
        flBrandStroke2Hover := flBrandStroke2HoverLight;
        flBrandStroke2Pressed := flBrandStroke2PressedLight;
        flCompoundBrandBackground := flCompoundBrandBackgroundLight;
        flCompoundBrandBackgroundHover := flCompoundBrandBackgroundHoverLight;
        flCompoundBrandBackgroundPressed := flCompoundBrandBackgroundPressedLight;
        flCompoundBrandForeground1 := flCompoundBrandForeground1Light;
        flCompoundBrandForeground1Hover := flCompoundBrandForeground1HoverLight;
        flCompoundBrandForeground1Pressed := flCompoundBrandForeground1PressedLight;
        flCompoundBrandStroke := flCompoundBrandStrokeLight;
        flCompoundBrandStrokeHover := flCompoundBrandStrokeHoverLight;
        flCompoundBrandStrokePressed := flCompoundBrandStrokePressedLight;
        flNeutralBackground1 := flNeutralBackground1Light;
        flNeutralBackground1Hover := flNeutralBackground1HoverLight;
        flNeutralBackground1Pressed := flNeutralBackground1PressedLight;
        flNeutralBackground1Selected := flNeutralBackground1SelectedLight;
        flNeutralBackground2 := flNeutralBackground2Light;
        flNeutralBackground2Hover := flNeutralBackground2HoverLight;
        flNeutralBackground2Pressed := flNeutralBackground2PressedLight;
        flNeutralBackground2Selected := flNeutralBackground2SelectedLight;
        flNeutralBackground3 := flNeutralBackground3Light;
        flNeutralBackground3Hover := flNeutralBackground3HoverLight;
        flNeutralBackground3Pressed := flNeutralBackground3PressedLight;
        flNeutralBackground3Selected := flNeutralBackground3SelectedLight;
        flNeutralBackground4 := flNeutralBackground4Light;
        flNeutralBackground4Hover := flNeutralBackground4HoverLight;
        flNeutralBackground4Pressed := flNeutralBackground4PressedLight;
        flNeutralBackground4Selected := flNeutralBackground4SelectedLight;
        flNeutralBackground5 := flNeutralBackground5Light;
        flNeutralBackground5Hover := flNeutralBackground5HoverLight;
        flNeutralBackground5Pressed := flNeutralBackground5PressedLight;
        flNeutralBackground5Selected := flNeutralBackground5SelectedLight;
        flNeutralBackground6 := flNeutralBackground6Light;
        flNeutralBackground7 := flNeutralBackground7Light;
        flNeutralBackground7Hover := flNeutralBackground7HoverLight;
        flNeutralBackground7Pressed := flNeutralBackground7PressedLight;
        flNeutralBackground7Selected := flNeutralBackground7SelectedLight;
        flNeutralBackground8 := flNeutralBackground8Light;
        flNeutralBackgroundAlpha := flNeutralBackgroundAlphaLight;
        flNeutralBackgroundAlpha2 := flNeutralBackgroundAlpha2Light;
        flNeutralBackgroundDisabled := flNeutralBackgroundDisabledLight;
        flNeutralBackgroundDisabled2 := flNeutralBackgroundDisabled2Light;
        flNeutralBackgroundInverted := flNeutralBackgroundInvertedLight;
        flNeutralBackgroundInvertedDisabled := flNeutralBackgroundInvertedDisabledLight;
        flNeutralBackgroundInvertedHover := flNeutralBackgroundInvertedHoverLight;
        flNeutralBackgroundInvertedPressed := flNeutralBackgroundInvertedPressedLight;
        flNeutralBackgroundInvertedSelected := flNeutralBackgroundInvertedSelectedLight;
        flNeutralBackgroundStatic := flNeutralBackgroundStaticLight;
        flNeutralCardBackground := flNeutralCardBackgroundLight;
        flNeutralCardBackgroundDisabled := flNeutralCardBackgroundDisabledLight;
        flNeutralCardBackgroundHover := flNeutralCardBackgroundHoverLight;
        flNeutralCardBackgroundPressed := flNeutralCardBackgroundPressedLight;
        flNeutralCardBackgroundSelected := flNeutralCardBackgroundSelectedLight;
        flNeutralForeground1 := flNeutralForeground1Light;
        flNeutralForeground1Hover := flNeutralForeground1HoverLight;
        flNeutralForeground1Pressed := flNeutralForeground1PressedLight;
        flNeutralForeground1Selected := flNeutralForeground1SelectedLight;
        flNeutralForeground1Static := flNeutralForeground1StaticLight;
        flNeutralForeground2 := flNeutralForeground2Light;
        flNeutralForeground2BrandHover := flNeutralForeground2BrandHoverLight;
        flNeutralForeground2BrandPressed := flNeutralForeground2BrandPressedLight;
        flNeutralForeground2BrandSelected := flNeutralForeground2BrandSelectedLight;
        flNeutralForeground2Hover := flNeutralForeground2HoverLight;
        flNeutralForeground2Link := flNeutralForeground2LinkLight;
        flNeutralForeground2LinkHover := flNeutralForeground2LinkHoverLight;
        flNeutralForeground2LinkPressed := flNeutralForeground2LinkPressedLight;
        flNeutralForeground2LinkSelected := flNeutralForeground2LinkSelectedLight;
        flNeutralForeground2Pressed := flNeutralForeground2PressedLight;
        flNeutralForeground2Selected := flNeutralForeground2SelectedLight;
        flNeutralForeground3 := flNeutralForeground3Light;
        flNeutralForeground3BrandHover := flNeutralForeground3BrandHoverLight;
        flNeutralForeground3BrandPressed := flNeutralForeground3BrandPressedLight;
        flNeutralForeground3BrandSelected := flNeutralForeground3BrandSelectedLight;
        flNeutralForeground3Hover := flNeutralForeground3HoverLight;
        flNeutralForeground3Pressed := flNeutralForeground3PressedLight;
        flNeutralForeground3Selected := flNeutralForeground3SelectedLight;
        flNeutralForeground4 := flNeutralForeground4Light;
        flNeutralForeground5 := flNeutralForeground5Light;
        flNeutralForeground5Hover := flNeutralForeground5HoverLight;
        flNeutralForeground5Pressed := flNeutralForeground5PressedLight;
        flNeutralForeground5Selected := flNeutralForeground5SelectedLight;
        flNeutralForegroundDisabled := flNeutralForegroundDisabledLight;
        flNeutralForegroundInverted := flNeutralForegroundInvertedLight;
        flNeutralForegroundInverted2 := flNeutralForegroundInverted2Light;
        flNeutralForegroundInvertedDisabled := flNeutralForegroundInvertedDisabledLight;
        flNeutralForegroundInvertedHover := flNeutralForegroundInvertedHoverLight;
        flNeutralForegroundInvertedLink := flNeutralForegroundInvertedLinkLight;
        flNeutralForegroundInvertedLinkHover := flNeutralForegroundInvertedLinkHoverLight;
        flNeutralForegroundInvertedLinkPressed := flNeutralForegroundInvertedLinkPressedLight;
        flNeutralForegroundInvertedLinkSelected := flNeutralForegroundInvertedLinkSelectedLight;
        flNeutralForegroundInvertedPressed := flNeutralForegroundInvertedPressedLight;
        flNeutralForegroundInvertedSelected := flNeutralForegroundInvertedSelectedLight;
        flNeutralForegroundOnBrand := flNeutralForegroundOnBrandLight;
        flNeutralForegroundStaticInverted := flNeutralForegroundStaticInvertedLight;
        flNeutralShadowAmbient := flNeutralShadowAmbientLight;
        flNeutralShadowAmbientDarker := flNeutralShadowAmbientDarkerLight;
        flNeutralShadowAmbientLighter := flNeutralShadowAmbientLighterLight;
        flNeutralShadowKey := flNeutralShadowKeyLight;
        flNeutralShadowKeyDarker := flNeutralShadowKeyDarkerLight;
        flNeutralShadowKeyLighter := flNeutralShadowKeyLighterLight;
        flNeutralStencil1 := flNeutralStencil1Light;
        flNeutralStencil1Alpha := flNeutralStencil1AlphaLight;
        flNeutralStencil2 := flNeutralStencil2Light;
        flNeutralStencil2Alpha := flNeutralStencil2AlphaLight;
        flNeutralStroke1 := flNeutralStroke1Light;
        flNeutralStroke1Hover := flNeutralStroke1HoverLight;
        flNeutralStroke1Pressed := flNeutralStroke1PressedLight;
        flNeutralStroke1Selected := flNeutralStroke1SelectedLight;
        flNeutralStroke2 := flNeutralStroke2Light;
        flNeutralStroke3 := flNeutralStroke3Light;
        flNeutralStroke4 := flNeutralStroke4Light;
        flNeutralStroke4Hover := flNeutralStroke4HoverLight;
        flNeutralStroke4Pressed := flNeutralStroke4PressedLight;
        flNeutralStroke4Selected := flNeutralStroke4SelectedLight;
        flNeutralStrokeAccessible := flNeutralStrokeAccessibleLight;
        flNeutralStrokeAccessibleHover := flNeutralStrokeAccessibleHoverLight;
        flNeutralStrokeAccessiblePressed := flNeutralStrokeAccessiblePressedLight;
        flNeutralStrokeAccessibleSelected := flNeutralStrokeAccessibleSelectedLight;
        flNeutralStrokeAlpha := flNeutralStrokeAlphaLight;
        flNeutralStrokeAlpha2 := flNeutralStrokeAlpha2Light;
        flNeutralStrokeDisabled := flNeutralStrokeDisabledLight;
        flNeutralStrokeDisabled2 := flNeutralStrokeDisabled2Light;
        flNeutralStrokeInvertedDisabled := flNeutralStrokeInvertedDisabledLight;
        flNeutralStrokeOnBrand := flNeutralStrokeOnBrandLight;
        flNeutralStrokeOnBrand2 := flNeutralStrokeOnBrand2Light;
        flNeutralStrokeOnBrand2Hover := flNeutralStrokeOnBrand2HoverLight;
        flNeutralStrokeOnBrand2Pressed := flNeutralStrokeOnBrand2PressedLight;
        flNeutralStrokeOnBrand2Selected := flNeutralStrokeOnBrand2SelectedLight;
        flNeutralStrokeSubtle := flNeutralStrokeSubtleLight;
        flPaletteAnchorBackground2 := flPaletteAnchorBackground2Light;
        flPaletteAnchorBorderActive := flPaletteAnchorBorderActiveLight;
        flPaletteAnchorForeground2 := flPaletteAnchorForeground2Light;
        flPaletteBeigeBackground2 := flPaletteBeigeBackground2Light;
        flPaletteBeigeBorderActive := flPaletteBeigeBorderActiveLight;
        flPaletteBeigeForeground2 := flPaletteBeigeForeground2Light;
        flPaletteBerryBackground1 := flPaletteBerryBackground1Light;
        flPaletteBerryBackground2 := flPaletteBerryBackground2Light;
        flPaletteBerryBackground3 := flPaletteBerryBackground3Light;
        flPaletteBerryBorder1 := flPaletteBerryBorder1Light;
        flPaletteBerryBorder2 := flPaletteBerryBorder2Light;
        flPaletteBerryBorderActive := flPaletteBerryBorderActiveLight;
        flPaletteBerryForeground1 := flPaletteBerryForeground1Light;
        flPaletteBerryForeground2 := flPaletteBerryForeground2Light;
        flPaletteBerryForeground3 := flPaletteBerryForeground3Light;
        flPaletteBlueBackground2 := flPaletteBlueBackground2Light;
        flPaletteBlueBorderActive := flPaletteBlueBorderActiveLight;
        flPaletteBlueForeground2 := flPaletteBlueForeground2Light;
        flPaletteBrassBackground2 := flPaletteBrassBackground2Light;
        flPaletteBrassBorderActive := flPaletteBrassBorderActiveLight;
        flPaletteBrassForeground2 := flPaletteBrassForeground2Light;
        flPaletteBrownBackground2 := flPaletteBrownBackground2Light;
        flPaletteBrownBorderActive := flPaletteBrownBorderActiveLight;
        flPaletteBrownForeground2 := flPaletteBrownForeground2Light;
        flPaletteCornflowerBackground2 := flPaletteCornflowerBackground2Light;
        flPaletteCornflowerBorderActive := flPaletteCornflowerBorderActiveLight;
        flPaletteCornflowerForeground2 := flPaletteCornflowerForeground2Light;
        flPaletteCranberryBackground2 := flPaletteCranberryBackground2Light;
        flPaletteCranberryBorderActive := flPaletteCranberryBorderActiveLight;
        flPaletteCranberryForeground2 := flPaletteCranberryForeground2Light;
        flPaletteDarkGreenBackground2 := flPaletteDarkGreenBackground2Light;
        flPaletteDarkGreenBorderActive := flPaletteDarkGreenBorderActiveLight;
        flPaletteDarkGreenForeground2 := flPaletteDarkGreenForeground2Light;
        flPaletteDarkOrangeBackground1 := flPaletteDarkOrangeBackground1Light;
        flPaletteDarkOrangeBackground2 := flPaletteDarkOrangeBackground2Light;
        flPaletteDarkOrangeBackground3 := flPaletteDarkOrangeBackground3Light;
        flPaletteDarkOrangeBorder1 := flPaletteDarkOrangeBorder1Light;
        flPaletteDarkOrangeBorder2 := flPaletteDarkOrangeBorder2Light;
        flPaletteDarkOrangeBorderActive := flPaletteDarkOrangeBorderActiveLight;
        flPaletteDarkOrangeForeground1 := flPaletteDarkOrangeForeground1Light;
        flPaletteDarkOrangeForeground2 := flPaletteDarkOrangeForeground2Light;
        flPaletteDarkOrangeForeground3 := flPaletteDarkOrangeForeground3Light;
        flPaletteDarkRedBackground2 := flPaletteDarkRedBackground2Light;
        flPaletteDarkRedBorderActive := flPaletteDarkRedBorderActiveLight;
        flPaletteDarkRedForeground2 := flPaletteDarkRedForeground2Light;
        flPaletteForestBackground2 := flPaletteForestBackground2Light;
        flPaletteForestBorderActive := flPaletteForestBorderActiveLight;
        flPaletteForestForeground2 := flPaletteForestForeground2Light;
        flPaletteGoldBackground2 := flPaletteGoldBackground2Light;
        flPaletteGoldBorderActive := flPaletteGoldBorderActiveLight;
        flPaletteGoldForeground2 := flPaletteGoldForeground2Light;
        flPaletteGrapeBackground2 := flPaletteGrapeBackground2Light;
        flPaletteGrapeBorderActive := flPaletteGrapeBorderActiveLight;
        flPaletteGrapeForeground2 := flPaletteGrapeForeground2Light;
        flPaletteGreenBackground1 := flPaletteGreenBackground1Light;
        flPaletteGreenBackground2 := flPaletteGreenBackground2Light;
        flPaletteGreenBackground3 := flPaletteGreenBackground3Light;
        flPaletteGreenBorder1 := flPaletteGreenBorder1Light;
        flPaletteGreenBorder2 := flPaletteGreenBorder2Light;
        flPaletteGreenBorderActive := flPaletteGreenBorderActiveLight;
        flPaletteGreenForeground1 := flPaletteGreenForeground1Light;
        flPaletteGreenForeground2 := flPaletteGreenForeground2Light;
        flPaletteGreenForeground3 := flPaletteGreenForeground3Light;
        flPaletteGreenForegroundInverted := flPaletteGreenForegroundInvertedLight;
        flPaletteLavenderBackground2 := flPaletteLavenderBackground2Light;
        flPaletteLavenderBorderActive := flPaletteLavenderBorderActiveLight;
        flPaletteLavenderForeground2 := flPaletteLavenderForeground2Light;
        flPaletteLightGreenBackground1 := flPaletteLightGreenBackground1Light;
        flPaletteLightGreenBackground2 := flPaletteLightGreenBackground2Light;
        flPaletteLightGreenBackground3 := flPaletteLightGreenBackground3Light;
        flPaletteLightGreenBorder1 := flPaletteLightGreenBorder1Light;
        flPaletteLightGreenBorder2 := flPaletteLightGreenBorder2Light;
        flPaletteLightGreenBorderActive := flPaletteLightGreenBorderActiveLight;
        flPaletteLightGreenForeground1 := flPaletteLightGreenForeground1Light;
        flPaletteLightGreenForeground2 := flPaletteLightGreenForeground2Light;
        flPaletteLightGreenForeground3 := flPaletteLightGreenForeground3Light;
        flPaletteLightTealBackground2 := flPaletteLightTealBackground2Light;
        flPaletteLightTealBorderActive := flPaletteLightTealBorderActiveLight;
        flPaletteLightTealForeground2 := flPaletteLightTealForeground2Light;
        flPaletteLilacBackground2 := flPaletteLilacBackground2Light;
        flPaletteLilacBorderActive := flPaletteLilacBorderActiveLight;
        flPaletteLilacForeground2 := flPaletteLilacForeground2Light;
        flPaletteMagentaBackground2 := flPaletteMagentaBackground2Light;
        flPaletteMagentaBorderActive := flPaletteMagentaBorderActiveLight;
        flPaletteMagentaForeground2 := flPaletteMagentaForeground2Light;
        flPaletteMarigoldBackground1 := flPaletteMarigoldBackground1Light;
        flPaletteMarigoldBackground2 := flPaletteMarigoldBackground2Light;
        flPaletteMarigoldBackground3 := flPaletteMarigoldBackground3Light;
        flPaletteMarigoldBorder1 := flPaletteMarigoldBorder1Light;
        flPaletteMarigoldBorder2 := flPaletteMarigoldBorder2Light;
        flPaletteMarigoldBorderActive := flPaletteMarigoldBorderActiveLight;
        flPaletteMarigoldForeground1 := flPaletteMarigoldForeground1Light;
        flPaletteMarigoldForeground2 := flPaletteMarigoldForeground2Light;
        flPaletteMarigoldForeground3 := flPaletteMarigoldForeground3Light;
        flPaletteMinkBackground2 := flPaletteMinkBackground2Light;
        flPaletteMinkBorderActive := flPaletteMinkBorderActiveLight;
        flPaletteMinkForeground2 := flPaletteMinkForeground2Light;
        flPaletteNavyBackground2 := flPaletteNavyBackground2Light;
        flPaletteNavyBorderActive := flPaletteNavyBorderActiveLight;
        flPaletteNavyForeground2 := flPaletteNavyForeground2Light;
        flPalettePeachBackground2 := flPalettePeachBackground2Light;
        flPalettePeachBorderActive := flPalettePeachBorderActiveLight;
        flPalettePeachForeground2 := flPalettePeachForeground2Light;
        flPalettePinkBackground2 := flPalettePinkBackground2Light;
        flPalettePinkBorderActive := flPalettePinkBorderActiveLight;
        flPalettePinkForeground2 := flPalettePinkForeground2Light;
        flPalettePlatinumBackground2 := flPalettePlatinumBackground2Light;
        flPalettePlatinumBorderActive := flPalettePlatinumBorderActiveLight;
        flPalettePlatinumForeground2 := flPalettePlatinumForeground2Light;
        flPalettePlumBackground2 := flPalettePlumBackground2Light;
        flPalettePlumBorderActive := flPalettePlumBorderActiveLight;
        flPalettePlumForeground2 := flPalettePlumForeground2Light;
        flPalettePumpkinBackground2 := flPalettePumpkinBackground2Light;
        flPalettePumpkinBorderActive := flPalettePumpkinBorderActiveLight;
        flPalettePumpkinForeground2 := flPalettePumpkinForeground2Light;
        flPalettePurpleBackground2 := flPalettePurpleBackground2Light;
        flPalettePurpleBorderActive := flPalettePurpleBorderActiveLight;
        flPalettePurpleForeground2 := flPalettePurpleForeground2Light;
        flPaletteRedBackground1 := flPaletteRedBackground1Light;
        flPaletteRedBackground2 := flPaletteRedBackground2Light;
        flPaletteRedBackground3 := flPaletteRedBackground3Light;
        flPaletteRedBorder1 := flPaletteRedBorder1Light;
        flPaletteRedBorder2 := flPaletteRedBorder2Light;
        flPaletteRedBorderActive := flPaletteRedBorderActiveLight;
        flPaletteRedForeground1 := flPaletteRedForeground1Light;
        flPaletteRedForeground2 := flPaletteRedForeground2Light;
        flPaletteRedForeground3 := flPaletteRedForeground3Light;
        flPaletteRedForegroundInverted := flPaletteRedForegroundInvertedLight;
        flPaletteRoyalBlueBackground2 := flPaletteRoyalBlueBackground2Light;
        flPaletteRoyalBlueBorderActive := flPaletteRoyalBlueBorderActiveLight;
        flPaletteRoyalBlueForeground2 := flPaletteRoyalBlueForeground2Light;
        flPaletteSeafoamBackground2 := flPaletteSeafoamBackground2Light;
        flPaletteSeafoamBorderActive := flPaletteSeafoamBorderActiveLight;
        flPaletteSeafoamForeground2 := flPaletteSeafoamForeground2Light;
        flPaletteSteelBackground2 := flPaletteSteelBackground2Light;
        flPaletteSteelBorderActive := flPaletteSteelBorderActiveLight;
        flPaletteSteelForeground2 := flPaletteSteelForeground2Light;
        flPaletteTealBackground2 := flPaletteTealBackground2Light;
        flPaletteTealBorderActive := flPaletteTealBorderActiveLight;
        flPaletteTealForeground2 := flPaletteTealForeground2Light;
        flPaletteYellowBackground1 := flPaletteYellowBackground1Light;
        flPaletteYellowBackground2 := flPaletteYellowBackground2Light;
        flPaletteYellowBackground3 := flPaletteYellowBackground3Light;
        flPaletteYellowBorder1 := flPaletteYellowBorder1Light;
        flPaletteYellowBorder2 := flPaletteYellowBorder2Light;
        flPaletteYellowBorderActive := flPaletteYellowBorderActiveLight;
        flPaletteYellowForeground1 := flPaletteYellowForeground1Light;
        flPaletteYellowForeground2 := flPaletteYellowForeground2Light;
        flPaletteYellowForeground3 := flPaletteYellowForeground3Light;
        flPaletteYellowForegroundInverted := flPaletteYellowForegroundInvertedLight;
        flScrollbarOverlay := flScrollbarOverlayLight;
        flStatusDangerBackground1 := flStatusDangerBackground1Light;
        flStatusDangerBackground2 := flStatusDangerBackground2Light;
        flStatusDangerBackground3 := flStatusDangerBackground3Light;
        flStatusDangerBackground3Hover := flStatusDangerBackground3HoverLight;
        flStatusDangerBackground3Pressed := flStatusDangerBackground3PressedLight;
        flStatusDangerBorder1 := flStatusDangerBorder1Light;
        flStatusDangerBorder2 := flStatusDangerBorder2Light;
        flStatusDangerBorderActive := flStatusDangerBorderActiveLight;
        flStatusDangerForeground1 := flStatusDangerForeground1Light;
        flStatusDangerForeground2 := flStatusDangerForeground2Light;
        flStatusDangerForeground3 := flStatusDangerForeground3Light;
        flStatusDangerForegroundInverted := flStatusDangerForegroundInvertedLight;
        flStatusSuccessBackground1 := flStatusSuccessBackground1Light;
        flStatusSuccessBackground2 := flStatusSuccessBackground2Light;
        flStatusSuccessBackground3 := flStatusSuccessBackground3Light;
        flStatusSuccessBorder1 := flStatusSuccessBorder1Light;
        flStatusSuccessBorder2 := flStatusSuccessBorder2Light;
        flStatusSuccessBorderActive := flStatusSuccessBorderActiveLight;
        flStatusSuccessForeground1 := flStatusSuccessForeground1Light;
        flStatusSuccessForeground2 := flStatusSuccessForeground2Light;
        flStatusSuccessForeground3 := flStatusSuccessForeground3Light;
        flStatusSuccessForegroundInverted := flStatusSuccessForegroundInvertedLight;
        flStatusWarningBackground1 := flStatusWarningBackground1Light;
        flStatusWarningBackground2 := flStatusWarningBackground2Light;
        flStatusWarningBackground3 := flStatusWarningBackground3Light;
        flStatusWarningBorder1 := flStatusWarningBorder1Light;
        flStatusWarningBorder2 := flStatusWarningBorder2Light;
        flStatusWarningBorderActive := flStatusWarningBorderActiveLight;
        flStatusWarningForeground1 := flStatusWarningForeground1Light;
        flStatusWarningForeground2 := flStatusWarningForeground2Light;
        flStatusWarningForeground3 := flStatusWarningForeground3Light;
        flStatusWarningForegroundInverted := flStatusWarningForegroundInvertedLight;
        flStrokeFocus1 := flStrokeFocus1Light;
        flStrokeFocus2 := flStrokeFocus2Light;
        flSubtleBackgroundHover := flSubtleBackgroundHoverLight;
        flSubtleBackgroundInvertedHover := flSubtleBackgroundInvertedHoverLight;
        flSubtleBackgroundInvertedPressed := flSubtleBackgroundInvertedPressedLight;
        flSubtleBackgroundInvertedSelected := flSubtleBackgroundInvertedSelectedLight;
        flSubtleBackgroundLightAlphaHover := flSubtleBackgroundLightAlphaHoverLight;
        flSubtleBackgroundLightAlphaPressed := flSubtleBackgroundLightAlphaPressedLight;
        flSubtleBackgroundPressed := flSubtleBackgroundPressedLight;
        flSubtleBackgroundSelected := flSubtleBackgroundSelectedLight;
      end;
    ftmDark:
      begin
        flBackgroundOverlay := flBackgroundOverlayDark;
        flBrandBackground := flBrandBackgroundDark;
        flBrandBackground2 := flBrandBackground2Dark;
        flBrandBackground2Hover := flBrandBackground2HoverDark;
        flBrandBackground2Pressed := flBrandBackground2PressedDark;
        flBrandBackground3Static := flBrandBackground3StaticDark;
        flBrandBackground4Static := flBrandBackground4StaticDark;
        flBrandBackgroundHover := flBrandBackgroundHoverDark;
        flBrandBackgroundInverted := flBrandBackgroundInvertedDark;
        flBrandBackgroundInvertedHover := flBrandBackgroundInvertedHoverDark;
        flBrandBackgroundInvertedPressed := flBrandBackgroundInvertedPressedDark;
        flBrandBackgroundInvertedSelected := flBrandBackgroundInvertedSelectedDark;
        flBrandBackgroundPressed := flBrandBackgroundPressedDark;
        flBrandBackgroundSelected := flBrandBackgroundSelectedDark;
        flBrandBackgroundStatic := flBrandBackgroundStaticDark;
        flBrandForeground1 := flBrandForeground1Dark;
        flBrandForeground2 := flBrandForeground2Dark;
        flBrandForeground2Hover := flBrandForeground2HoverDark;
        flBrandForeground2Pressed := flBrandForeground2PressedDark;
        flBrandForegroundInverted := flBrandForegroundInvertedDark;
        flBrandForegroundInvertedHover := flBrandForegroundInvertedHoverDark;
        flBrandForegroundInvertedPressed := flBrandForegroundInvertedPressedDark;
        flBrandForegroundLink := flBrandForegroundLinkDark;
        flBrandForegroundLinkHover := flBrandForegroundLinkHoverDark;
        flBrandForegroundLinkPressed := flBrandForegroundLinkPressedDark;
        flBrandForegroundLinkSelected := flBrandForegroundLinkSelectedDark;
        flBrandForegroundOnLight := flBrandForegroundOnLightDark;
        flBrandForegroundOnLightHover := flBrandForegroundOnLightHoverDark;
        flBrandForegroundOnLightPressed := flBrandForegroundOnLightPressedDark;
        flBrandForegroundOnLightSelected := flBrandForegroundOnLightSelectedDark;
        flBrandShadowAmbient := flBrandShadowAmbientDark;
        flBrandShadowKey := flBrandShadowKeyDark;
        flBrandStroke1 := flBrandStroke1Dark;
        flBrandStroke2 := flBrandStroke2Dark;
        flBrandStroke2Contrast := flBrandStroke2ContrastDark;
        flBrandStroke2Hover := flBrandStroke2HoverDark;
        flBrandStroke2Pressed := flBrandStroke2PressedDark;
        flCompoundBrandBackground := flCompoundBrandBackgroundDark;
        flCompoundBrandBackgroundHover := flCompoundBrandBackgroundHoverDark;
        flCompoundBrandBackgroundPressed := flCompoundBrandBackgroundPressedDark;
        flCompoundBrandForeground1 := flCompoundBrandForeground1Dark;
        flCompoundBrandForeground1Hover := flCompoundBrandForeground1HoverDark;
        flCompoundBrandForeground1Pressed := flCompoundBrandForeground1PressedDark;
        flCompoundBrandStroke := flCompoundBrandStrokeDark;
        flCompoundBrandStrokeHover := flCompoundBrandStrokeHoverDark;
        flCompoundBrandStrokePressed := flCompoundBrandStrokePressedDark;
        flNeutralBackground1 := flNeutralBackground1Dark;
        flNeutralBackground1Hover := flNeutralBackground1HoverDark;
        flNeutralBackground1Pressed := flNeutralBackground1PressedDark;
        flNeutralBackground1Selected := flNeutralBackground1SelectedDark;
        flNeutralBackground2 := flNeutralBackground2Dark;
        flNeutralBackground2Hover := flNeutralBackground2HoverDark;
        flNeutralBackground2Pressed := flNeutralBackground2PressedDark;
        flNeutralBackground2Selected := flNeutralBackground2SelectedDark;
        flNeutralBackground3 := flNeutralBackground3Dark;
        flNeutralBackground3Hover := flNeutralBackground3HoverDark;
        flNeutralBackground3Pressed := flNeutralBackground3PressedDark;
        flNeutralBackground3Selected := flNeutralBackground3SelectedDark;
        flNeutralBackground4 := flNeutralBackground4Dark;
        flNeutralBackground4Hover := flNeutralBackground4HoverDark;
        flNeutralBackground4Pressed := flNeutralBackground4PressedDark;
        flNeutralBackground4Selected := flNeutralBackground4SelectedDark;
        flNeutralBackground5 := flNeutralBackground5Dark;
        flNeutralBackground5Hover := flNeutralBackground5HoverDark;
        flNeutralBackground5Pressed := flNeutralBackground5PressedDark;
        flNeutralBackground5Selected := flNeutralBackground5SelectedDark;
        flNeutralBackground6 := flNeutralBackground6Dark;
        flNeutralBackground7 := flNeutralBackground7Dark;
        flNeutralBackground7Hover := flNeutralBackground7HoverDark;
        flNeutralBackground7Pressed := flNeutralBackground7PressedDark;
        flNeutralBackground7Selected := flNeutralBackground7SelectedDark;
        flNeutralBackground8 := flNeutralBackground8Dark;
        flNeutralBackgroundAlpha := flNeutralBackgroundAlphaDark;
        flNeutralBackgroundAlpha2 := flNeutralBackgroundAlpha2Dark;
        flNeutralBackgroundDisabled := flNeutralBackgroundDisabledDark;
        flNeutralBackgroundDisabled2 := flNeutralBackgroundDisabled2Dark;
        flNeutralBackgroundInverted := flNeutralBackgroundInvertedDark;
        flNeutralBackgroundInvertedDisabled := flNeutralBackgroundInvertedDisabledDark;
        flNeutralBackgroundInvertedHover := flNeutralBackgroundInvertedHoverDark;
        flNeutralBackgroundInvertedPressed := flNeutralBackgroundInvertedPressedDark;
        flNeutralBackgroundInvertedSelected := flNeutralBackgroundInvertedSelectedDark;
        flNeutralBackgroundStatic := flNeutralBackgroundStaticDark;
        flNeutralCardBackground := flNeutralCardBackgroundDark;
        flNeutralCardBackgroundDisabled := flNeutralCardBackgroundDisabledDark;
        flNeutralCardBackgroundHover := flNeutralCardBackgroundHoverDark;
        flNeutralCardBackgroundPressed := flNeutralCardBackgroundPressedDark;
        flNeutralCardBackgroundSelected := flNeutralCardBackgroundSelectedDark;
        flNeutralForeground1 := flNeutralForeground1Dark;
        flNeutralForeground1Hover := flNeutralForeground1HoverDark;
        flNeutralForeground1Pressed := flNeutralForeground1PressedDark;
        flNeutralForeground1Selected := flNeutralForeground1SelectedDark;
        flNeutralForeground1Static := flNeutralForeground1StaticDark;
        flNeutralForeground2 := flNeutralForeground2Dark;
        flNeutralForeground2BrandHover := flNeutralForeground2BrandHoverDark;
        flNeutralForeground2BrandPressed := flNeutralForeground2BrandPressedDark;
        flNeutralForeground2BrandSelected := flNeutralForeground2BrandSelectedDark;
        flNeutralForeground2Hover := flNeutralForeground2HoverDark;
        flNeutralForeground2Link := flNeutralForeground2LinkDark;
        flNeutralForeground2LinkHover := flNeutralForeground2LinkHoverDark;
        flNeutralForeground2LinkPressed := flNeutralForeground2LinkPressedDark;
        flNeutralForeground2LinkSelected := flNeutralForeground2LinkSelectedDark;
        flNeutralForeground2Pressed := flNeutralForeground2PressedDark;
        flNeutralForeground2Selected := flNeutralForeground2SelectedDark;
        flNeutralForeground3 := flNeutralForeground3Dark;
        flNeutralForeground3BrandHover := flNeutralForeground3BrandHoverDark;
        flNeutralForeground3BrandPressed := flNeutralForeground3BrandPressedDark;
        flNeutralForeground3BrandSelected := flNeutralForeground3BrandSelectedDark;
        flNeutralForeground3Hover := flNeutralForeground3HoverDark;
        flNeutralForeground3Pressed := flNeutralForeground3PressedDark;
        flNeutralForeground3Selected := flNeutralForeground3SelectedDark;
        flNeutralForeground4 := flNeutralForeground4Dark;
        flNeutralForeground5 := flNeutralForeground5Dark;
        flNeutralForeground5Hover := flNeutralForeground5HoverDark;
        flNeutralForeground5Pressed := flNeutralForeground5PressedDark;
        flNeutralForeground5Selected := flNeutralForeground5SelectedDark;
        flNeutralForegroundDisabled := flNeutralForegroundDisabledDark;
        flNeutralForegroundInverted := flNeutralForegroundInvertedDark;
        flNeutralForegroundInverted2 := flNeutralForegroundInverted2Dark;
        flNeutralForegroundInvertedDisabled := flNeutralForegroundInvertedDisabledDark;
        flNeutralForegroundInvertedHover := flNeutralForegroundInvertedHoverDark;
        flNeutralForegroundInvertedLink := flNeutralForegroundInvertedLinkDark;
        flNeutralForegroundInvertedLinkHover := flNeutralForegroundInvertedLinkHoverDark;
        flNeutralForegroundInvertedLinkPressed := flNeutralForegroundInvertedLinkPressedDark;
        flNeutralForegroundInvertedLinkSelected := flNeutralForegroundInvertedLinkSelectedDark;
        flNeutralForegroundInvertedPressed := flNeutralForegroundInvertedPressedDark;
        flNeutralForegroundInvertedSelected := flNeutralForegroundInvertedSelectedDark;
        flNeutralForegroundOnBrand := flNeutralForegroundOnBrandDark;
        flNeutralForegroundStaticInverted := flNeutralForegroundStaticInvertedDark;
        flNeutralShadowAmbient := flNeutralShadowAmbientDark;
        flNeutralShadowAmbientDarker := flNeutralShadowAmbientDarkerDark;
        flNeutralShadowAmbientLighter := flNeutralShadowAmbientLighterDark;
        flNeutralShadowKey := flNeutralShadowKeyDark;
        flNeutralShadowKeyDarker := flNeutralShadowKeyDarkerDark;
        flNeutralShadowKeyLighter := flNeutralShadowKeyLighterDark;
        flNeutralStencil1 := flNeutralStencil1Dark;
        flNeutralStencil1Alpha := flNeutralStencil1AlphaDark;
        flNeutralStencil2 := flNeutralStencil2Dark;
        flNeutralStencil2Alpha := flNeutralStencil2AlphaDark;
        flNeutralStroke1 := flNeutralStroke1Dark;
        flNeutralStroke1Hover := flNeutralStroke1HoverDark;
        flNeutralStroke1Pressed := flNeutralStroke1PressedDark;
        flNeutralStroke1Selected := flNeutralStroke1SelectedDark;
        flNeutralStroke2 := flNeutralStroke2Dark;
        flNeutralStroke3 := flNeutralStroke3Dark;
        flNeutralStroke4 := flNeutralStroke4Dark;
        flNeutralStroke4Hover := flNeutralStroke4HoverDark;
        flNeutralStroke4Pressed := flNeutralStroke4PressedDark;
        flNeutralStroke4Selected := flNeutralStroke4SelectedDark;
        flNeutralStrokeAccessible := flNeutralStrokeAccessibleDark;
        flNeutralStrokeAccessibleHover := flNeutralStrokeAccessibleHoverDark;
        flNeutralStrokeAccessiblePressed := flNeutralStrokeAccessiblePressedDark;
        flNeutralStrokeAccessibleSelected := flNeutralStrokeAccessibleSelectedDark;
        flNeutralStrokeAlpha := flNeutralStrokeAlphaDark;
        flNeutralStrokeAlpha2 := flNeutralStrokeAlpha2Dark;
        flNeutralStrokeDisabled := flNeutralStrokeDisabledDark;
        flNeutralStrokeDisabled2 := flNeutralStrokeDisabled2Dark;
        flNeutralStrokeInvertedDisabled := flNeutralStrokeInvertedDisabledDark;
        flNeutralStrokeOnBrand := flNeutralStrokeOnBrandDark;
        flNeutralStrokeOnBrand2 := flNeutralStrokeOnBrand2Dark;
        flNeutralStrokeOnBrand2Hover := flNeutralStrokeOnBrand2HoverDark;
        flNeutralStrokeOnBrand2Pressed := flNeutralStrokeOnBrand2PressedDark;
        flNeutralStrokeOnBrand2Selected := flNeutralStrokeOnBrand2SelectedDark;
        flNeutralStrokeSubtle := flNeutralStrokeSubtleDark;
        flPaletteAnchorBackground2 := flPaletteAnchorBackground2Dark;
        flPaletteAnchorBorderActive := flPaletteAnchorBorderActiveDark;
        flPaletteAnchorForeground2 := flPaletteAnchorForeground2Dark;
        flPaletteBeigeBackground2 := flPaletteBeigeBackground2Dark;
        flPaletteBeigeBorderActive := flPaletteBeigeBorderActiveDark;
        flPaletteBeigeForeground2 := flPaletteBeigeForeground2Dark;
        flPaletteBerryBackground1 := flPaletteBerryBackground1Dark;
        flPaletteBerryBackground2 := flPaletteBerryBackground2Dark;
        flPaletteBerryBackground3 := flPaletteBerryBackground3Dark;
        flPaletteBerryBorder1 := flPaletteBerryBorder1Dark;
        flPaletteBerryBorder2 := flPaletteBerryBorder2Dark;
        flPaletteBerryBorderActive := flPaletteBerryBorderActiveDark;
        flPaletteBerryForeground1 := flPaletteBerryForeground1Dark;
        flPaletteBerryForeground2 := flPaletteBerryForeground2Dark;
        flPaletteBerryForeground3 := flPaletteBerryForeground3Dark;
        flPaletteBlueBackground2 := flPaletteBlueBackground2Dark;
        flPaletteBlueBorderActive := flPaletteBlueBorderActiveDark;
        flPaletteBlueForeground2 := flPaletteBlueForeground2Dark;
        flPaletteBrassBackground2 := flPaletteBrassBackground2Dark;
        flPaletteBrassBorderActive := flPaletteBrassBorderActiveDark;
        flPaletteBrassForeground2 := flPaletteBrassForeground2Dark;
        flPaletteBrownBackground2 := flPaletteBrownBackground2Dark;
        flPaletteBrownBorderActive := flPaletteBrownBorderActiveDark;
        flPaletteBrownForeground2 := flPaletteBrownForeground2Dark;
        flPaletteCornflowerBackground2 := flPaletteCornflowerBackground2Dark;
        flPaletteCornflowerBorderActive := flPaletteCornflowerBorderActiveDark;
        flPaletteCornflowerForeground2 := flPaletteCornflowerForeground2Dark;
        flPaletteCranberryBackground2 := flPaletteCranberryBackground2Dark;
        flPaletteCranberryBorderActive := flPaletteCranberryBorderActiveDark;
        flPaletteCranberryForeground2 := flPaletteCranberryForeground2Dark;
        flPaletteDarkGreenBackground2 := flPaletteDarkGreenBackground2Dark;
        flPaletteDarkGreenBorderActive := flPaletteDarkGreenBorderActiveDark;
        flPaletteDarkGreenForeground2 := flPaletteDarkGreenForeground2Dark;
        flPaletteDarkOrangeBackground1 := flPaletteDarkOrangeBackground1Dark;
        flPaletteDarkOrangeBackground2 := flPaletteDarkOrangeBackground2Dark;
        flPaletteDarkOrangeBackground3 := flPaletteDarkOrangeBackground3Dark;
        flPaletteDarkOrangeBorder1 := flPaletteDarkOrangeBorder1Dark;
        flPaletteDarkOrangeBorder2 := flPaletteDarkOrangeBorder2Dark;
        flPaletteDarkOrangeBorderActive := flPaletteDarkOrangeBorderActiveDark;
        flPaletteDarkOrangeForeground1 := flPaletteDarkOrangeForeground1Dark;
        flPaletteDarkOrangeForeground2 := flPaletteDarkOrangeForeground2Dark;
        flPaletteDarkOrangeForeground3 := flPaletteDarkOrangeForeground3Dark;
        flPaletteDarkRedBackground2 := flPaletteDarkRedBackground2Dark;
        flPaletteDarkRedBorderActive := flPaletteDarkRedBorderActiveDark;
        flPaletteDarkRedForeground2 := flPaletteDarkRedForeground2Dark;
        flPaletteForestBackground2 := flPaletteForestBackground2Dark;
        flPaletteForestBorderActive := flPaletteForestBorderActiveDark;
        flPaletteForestForeground2 := flPaletteForestForeground2Dark;
        flPaletteGoldBackground2 := flPaletteGoldBackground2Dark;
        flPaletteGoldBorderActive := flPaletteGoldBorderActiveDark;
        flPaletteGoldForeground2 := flPaletteGoldForeground2Dark;
        flPaletteGrapeBackground2 := flPaletteGrapeBackground2Dark;
        flPaletteGrapeBorderActive := flPaletteGrapeBorderActiveDark;
        flPaletteGrapeForeground2 := flPaletteGrapeForeground2Dark;
        flPaletteGreenBackground1 := flPaletteGreenBackground1Dark;
        flPaletteGreenBackground2 := flPaletteGreenBackground2Dark;
        flPaletteGreenBackground3 := flPaletteGreenBackground3Dark;
        flPaletteGreenBorder1 := flPaletteGreenBorder1Dark;
        flPaletteGreenBorder2 := flPaletteGreenBorder2Dark;
        flPaletteGreenBorderActive := flPaletteGreenBorderActiveDark;
        flPaletteGreenForeground1 := flPaletteGreenForeground1Dark;
        flPaletteGreenForeground2 := flPaletteGreenForeground2Dark;
        flPaletteGreenForeground3 := flPaletteGreenForeground3Dark;
        flPaletteGreenForegroundInverted := flPaletteGreenForegroundInvertedDark;
        flPaletteLavenderBackground2 := flPaletteLavenderBackground2Dark;
        flPaletteLavenderBorderActive := flPaletteLavenderBorderActiveDark;
        flPaletteLavenderForeground2 := flPaletteLavenderForeground2Dark;
        flPaletteLightGreenBackground1 := flPaletteLightGreenBackground1Dark;
        flPaletteLightGreenBackground2 := flPaletteLightGreenBackground2Dark;
        flPaletteLightGreenBackground3 := flPaletteLightGreenBackground3Dark;
        flPaletteLightGreenBorder1 := flPaletteLightGreenBorder1Dark;
        flPaletteLightGreenBorder2 := flPaletteLightGreenBorder2Dark;
        flPaletteLightGreenBorderActive := flPaletteLightGreenBorderActiveDark;
        flPaletteLightGreenForeground1 := flPaletteLightGreenForeground1Dark;
        flPaletteLightGreenForeground2 := flPaletteLightGreenForeground2Dark;
        flPaletteLightGreenForeground3 := flPaletteLightGreenForeground3Dark;
        flPaletteLightTealBackground2 := flPaletteLightTealBackground2Dark;
        flPaletteLightTealBorderActive := flPaletteLightTealBorderActiveDark;
        flPaletteLightTealForeground2 := flPaletteLightTealForeground2Dark;
        flPaletteLilacBackground2 := flPaletteLilacBackground2Dark;
        flPaletteLilacBorderActive := flPaletteLilacBorderActiveDark;
        flPaletteLilacForeground2 := flPaletteLilacForeground2Dark;
        flPaletteMagentaBackground2 := flPaletteMagentaBackground2Dark;
        flPaletteMagentaBorderActive := flPaletteMagentaBorderActiveDark;
        flPaletteMagentaForeground2 := flPaletteMagentaForeground2Dark;
        flPaletteMarigoldBackground1 := flPaletteMarigoldBackground1Dark;
        flPaletteMarigoldBackground2 := flPaletteMarigoldBackground2Dark;
        flPaletteMarigoldBackground3 := flPaletteMarigoldBackground3Dark;
        flPaletteMarigoldBorder1 := flPaletteMarigoldBorder1Dark;
        flPaletteMarigoldBorder2 := flPaletteMarigoldBorder2Dark;
        flPaletteMarigoldBorderActive := flPaletteMarigoldBorderActiveDark;
        flPaletteMarigoldForeground1 := flPaletteMarigoldForeground1Dark;
        flPaletteMarigoldForeground2 := flPaletteMarigoldForeground2Dark;
        flPaletteMarigoldForeground3 := flPaletteMarigoldForeground3Dark;
        flPaletteMinkBackground2 := flPaletteMinkBackground2Dark;
        flPaletteMinkBorderActive := flPaletteMinkBorderActiveDark;
        flPaletteMinkForeground2 := flPaletteMinkForeground2Dark;
        flPaletteNavyBackground2 := flPaletteNavyBackground2Dark;
        flPaletteNavyBorderActive := flPaletteNavyBorderActiveDark;
        flPaletteNavyForeground2 := flPaletteNavyForeground2Dark;
        flPalettePeachBackground2 := flPalettePeachBackground2Dark;
        flPalettePeachBorderActive := flPalettePeachBorderActiveDark;
        flPalettePeachForeground2 := flPalettePeachForeground2Dark;
        flPalettePinkBackground2 := flPalettePinkBackground2Dark;
        flPalettePinkBorderActive := flPalettePinkBorderActiveDark;
        flPalettePinkForeground2 := flPalettePinkForeground2Dark;
        flPalettePlatinumBackground2 := flPalettePlatinumBackground2Dark;
        flPalettePlatinumBorderActive := flPalettePlatinumBorderActiveDark;
        flPalettePlatinumForeground2 := flPalettePlatinumForeground2Dark;
        flPalettePlumBackground2 := flPalettePlumBackground2Dark;
        flPalettePlumBorderActive := flPalettePlumBorderActiveDark;
        flPalettePlumForeground2 := flPalettePlumForeground2Dark;
        flPalettePumpkinBackground2 := flPalettePumpkinBackground2Dark;
        flPalettePumpkinBorderActive := flPalettePumpkinBorderActiveDark;
        flPalettePumpkinForeground2 := flPalettePumpkinForeground2Dark;
        flPalettePurpleBackground2 := flPalettePurpleBackground2Dark;
        flPalettePurpleBorderActive := flPalettePurpleBorderActiveDark;
        flPalettePurpleForeground2 := flPalettePurpleForeground2Dark;
        flPaletteRedBackground1 := flPaletteRedBackground1Dark;
        flPaletteRedBackground2 := flPaletteRedBackground2Dark;
        flPaletteRedBackground3 := flPaletteRedBackground3Dark;
        flPaletteRedBorder1 := flPaletteRedBorder1Dark;
        flPaletteRedBorder2 := flPaletteRedBorder2Dark;
        flPaletteRedBorderActive := flPaletteRedBorderActiveDark;
        flPaletteRedForeground1 := flPaletteRedForeground1Dark;
        flPaletteRedForeground2 := flPaletteRedForeground2Dark;
        flPaletteRedForeground3 := flPaletteRedForeground3Dark;
        flPaletteRedForegroundInverted := flPaletteRedForegroundInvertedDark;
        flPaletteRoyalBlueBackground2 := flPaletteRoyalBlueBackground2Dark;
        flPaletteRoyalBlueBorderActive := flPaletteRoyalBlueBorderActiveDark;
        flPaletteRoyalBlueForeground2 := flPaletteRoyalBlueForeground2Dark;
        flPaletteSeafoamBackground2 := flPaletteSeafoamBackground2Dark;
        flPaletteSeafoamBorderActive := flPaletteSeafoamBorderActiveDark;
        flPaletteSeafoamForeground2 := flPaletteSeafoamForeground2Dark;
        flPaletteSteelBackground2 := flPaletteSteelBackground2Dark;
        flPaletteSteelBorderActive := flPaletteSteelBorderActiveDark;
        flPaletteSteelForeground2 := flPaletteSteelForeground2Dark;
        flPaletteTealBackground2 := flPaletteTealBackground2Dark;
        flPaletteTealBorderActive := flPaletteTealBorderActiveDark;
        flPaletteTealForeground2 := flPaletteTealForeground2Dark;
        flPaletteYellowBackground1 := flPaletteYellowBackground1Dark;
        flPaletteYellowBackground2 := flPaletteYellowBackground2Dark;
        flPaletteYellowBackground3 := flPaletteYellowBackground3Dark;
        flPaletteYellowBorder1 := flPaletteYellowBorder1Dark;
        flPaletteYellowBorder2 := flPaletteYellowBorder2Dark;
        flPaletteYellowBorderActive := flPaletteYellowBorderActiveDark;
        flPaletteYellowForeground1 := flPaletteYellowForeground1Dark;
        flPaletteYellowForeground2 := flPaletteYellowForeground2Dark;
        flPaletteYellowForeground3 := flPaletteYellowForeground3Dark;
        flPaletteYellowForegroundInverted := flPaletteYellowForegroundInvertedDark;
        flScrollbarOverlay := flScrollbarOverlayDark;
        flStatusDangerBackground1 := flStatusDangerBackground1Dark;
        flStatusDangerBackground2 := flStatusDangerBackground2Dark;
        flStatusDangerBackground3 := flStatusDangerBackground3Dark;
        flStatusDangerBackground3Hover := flStatusDangerBackground3HoverDark;
        flStatusDangerBackground3Pressed := flStatusDangerBackground3PressedDark;
        flStatusDangerBorder1 := flStatusDangerBorder1Dark;
        flStatusDangerBorder2 := flStatusDangerBorder2Dark;
        flStatusDangerBorderActive := flStatusDangerBorderActiveDark;
        flStatusDangerForeground1 := flStatusDangerForeground1Dark;
        flStatusDangerForeground2 := flStatusDangerForeground2Dark;
        flStatusDangerForeground3 := flStatusDangerForeground3Dark;
        flStatusDangerForegroundInverted := flStatusDangerForegroundInvertedDark;
        flStatusSuccessBackground1 := flStatusSuccessBackground1Dark;
        flStatusSuccessBackground2 := flStatusSuccessBackground2Dark;
        flStatusSuccessBackground3 := flStatusSuccessBackground3Dark;
        flStatusSuccessBorder1 := flStatusSuccessBorder1Dark;
        flStatusSuccessBorder2 := flStatusSuccessBorder2Dark;
        flStatusSuccessBorderActive := flStatusSuccessBorderActiveDark;
        flStatusSuccessForeground1 := flStatusSuccessForeground1Dark;
        flStatusSuccessForeground2 := flStatusSuccessForeground2Dark;
        flStatusSuccessForeground3 := flStatusSuccessForeground3Dark;
        flStatusSuccessForegroundInverted := flStatusSuccessForegroundInvertedDark;
        flStatusWarningBackground1 := flStatusWarningBackground1Dark;
        flStatusWarningBackground2 := flStatusWarningBackground2Dark;
        flStatusWarningBackground3 := flStatusWarningBackground3Dark;
        flStatusWarningBorder1 := flStatusWarningBorder1Dark;
        flStatusWarningBorder2 := flStatusWarningBorder2Dark;
        flStatusWarningBorderActive := flStatusWarningBorderActiveDark;
        flStatusWarningForeground1 := flStatusWarningForeground1Dark;
        flStatusWarningForeground2 := flStatusWarningForeground2Dark;
        flStatusWarningForeground3 := flStatusWarningForeground3Dark;
        flStatusWarningForegroundInverted := flStatusWarningForegroundInvertedDark;
        flStrokeFocus1 := flStrokeFocus1Dark;
        flStrokeFocus2 := flStrokeFocus2Dark;
        flSubtleBackgroundHover := flSubtleBackgroundHoverDark;
        flSubtleBackgroundInvertedHover := flSubtleBackgroundInvertedHoverDark;
        flSubtleBackgroundInvertedPressed := flSubtleBackgroundInvertedPressedDark;
        flSubtleBackgroundInvertedSelected := flSubtleBackgroundInvertedSelectedDark;
        flSubtleBackgroundLightAlphaHover := flSubtleBackgroundLightAlphaHoverDark;
        flSubtleBackgroundLightAlphaPressed := flSubtleBackgroundLightAlphaPressedDark;
        flSubtleBackgroundPressed := flSubtleBackgroundPressedDark;
        flSubtleBackgroundSelected := flSubtleBackgroundSelectedDark;
      end;
  end;

  NotifyThemeChange;
end;

function FluentIsWindowsDarkMode: Boolean;
var
  Reg: TRegistry;
begin
  Result := False;
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKeyReadOnly(
      'Software\Microsoft\Windows\CurrentVersion\Themes\Personalize') then
    begin
      if Reg.ValueExists('AppsUseLightTheme') then
        Result := Reg.ReadInteger('AppsUseLightTheme') = 0;
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

// Re-evaluates the OS setting and re-applies the colors. Does nothing unless
// the app is currently following the system theme. Called from the hidden
// window whenever Windows broadcasts a theme change.
procedure FluentSystemThemeChanged;
var
  Dark: Boolean;
begin
  if not FluentFollowSystemTheme then
    Exit;
  Dark := FluentIsWindowsDarkMode;
  if Dark then
    FluentApplyTheme(ftmDark)
  else
    FluentApplyTheme(ftmLight);
  // FluentApplyTheme cleared the flag — we are still following the system.
  FluentFollowSystemTheme := True;
  if Assigned(FluentOnSystemThemeChange) then
    FluentOnSystemThemeChange(Dark);
end;

type
  // Hidden helper window that listens for WM_SETTINGCHANGE so we learn when
  // the user flips Windows between light and dark mode at run time.
  TFluentThemeWatcher = class
  private
    FWnd: HWND;
    procedure WndProc(var Msg: TMessage);
  public
    constructor Create;
    destructor Destroy; override;
  end;

constructor TFluentThemeWatcher.Create;
begin
  inherited Create;
  FWnd := AllocateHWnd(WndProc);
end;

destructor TFluentThemeWatcher.Destroy;
begin
  if FWnd <> 0 then
    DeallocateHWnd(FWnd);
  inherited Destroy;
end;

procedure TFluentThemeWatcher.WndProc(var Msg: TMessage);
begin
  if (Msg.Msg = WM_SETTINGCHANGE) and (Msg.LParam <> 0) and
     (lstrcmpi(PChar(Msg.LParam), 'ImmersiveColorSet') = 0) then
    FluentSystemThemeChanged;
  Msg.Result := DefWindowProc(FWnd, Msg.Msg, Msg.WParam, Msg.LParam);
end;

var
  FThemeWatcher: TFluentThemeWatcher;

procedure FluentEnsureThemeWatch;
begin
  if not Assigned(FThemeWatcher) then
    FThemeWatcher := TFluentThemeWatcher.Create;
end;

procedure FluentApplySystemTheme;
begin
  if FluentIsWindowsDarkMode then
    FluentApplyTheme(ftmDark)
  else
    FluentApplyTheme(ftmLight);
  // Selecting "system colors": follow the OS and react to later changes.
  FluentFollowSystemTheme := True;
  FluentEnsureThemeWatch;
end;

procedure FluentSetDarkMode(ADark: Boolean);
begin
  if ADark then
    FluentApplyTheme(ftmDark)
  else
    FluentApplyTheme(ftmLight);
end;

initialization

finalization
  FreeAndNil(FThemeWatcher);
  if Assigned(FThemeChangeHandlers) then
  begin
    FThemeChangeHandlers.Clear; // Optionally clear the list
    FThemeChangeHandlers.Free;
  end;

end.


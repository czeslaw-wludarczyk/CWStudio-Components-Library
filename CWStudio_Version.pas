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
unit CWStudio_Version;

interface

const
  { Version components — keep in sync with VerInfo in the .dproj files }
  CWStudioVersionMajor   = 1;
  CWStudioVersionMinor   = 6;
  CWStudioVersionRelease = 7;
  CWStudioVersionBuild   = 0;

  { Human-readable version (Major.Minor.Release) }
  CWStudioVersion = '1.6.7';

  { Full version in VerInfo format (Major.Minor.Release.Build) }
  CWStudioVersionFull = '1.6.7.0';

  { Version label shown on the splash screen / in the About Box, e.g. 'V1.6.2.0' }
  CWStudioVersionLabel = 'V' + CWStudioVersionFull;

  { Product name — appears on the splash screen and in the IDE About Box }
  CWStudioProductName = 'CWStudio Components';

  { Full caption: name + version, e.g. 'CWStudio Component 1.6.2' }
  CWStudioCaption = CWStudioProductName + ' ' + CWStudioVersion;

  CWStudioCopyright = '© Czesław Włudarczyk';
  CWStudioLicense   = 'MIT';

implementation

end.

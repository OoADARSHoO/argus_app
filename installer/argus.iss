; =============================================================================
; NOTE: This Inno Setup script has been REPLACED by Velopack (Phase 10).
; It is preserved here for historical reference only.
; For all packaging and releases, use the Velopack script:
;   powershell .\scripts\package.ps1
; =============================================================================
; Inno Setup Script for Argus (LEGACY / SUPERSEDED)
; Publisher: Bitekoi Labs
; Version: 0.1.15
;
; This script packages the Flutter Windows Release build into an installer.
; Compile with Inno Setup Compiler (ISCC.exe or the Inno Setup IDE).

#define MyAppName "Argus"
#define MyAppVersion "0.1.15"
#define MyAppPublisher "Bitekoi Labs"
#define MyAppURL "https://bitekoilabs.com"
#define MyAppExeName "Argus.exe"
#define MyAppSourceDir "..\argus_app\build\windows\x64\runner\Release"
#define MyAppIcon "..\argus_app\assets\icons\app_icon.ico"

[Setup]
; App Identity & Metadata
AppId={{E6815B2D-9B2F-4A9B-9831-F9D104E98F21}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}

; Installation Target: Program Files\Argus
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes

; Output Configuration
OutputDir=output
OutputBaseFilename=Argus-Setup-{#MyAppVersion}
SetupIconFile={#MyAppIcon}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern

; Execution & Privileges (Installs to Program Files, so administrative rights are required)
PrivilegesRequired=admin
ArchitecturesInstallIn64BitMode=x64compatible
CloseApplications=yes
CloseApplicationsFilter=*.exe

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; The entire release directory contents
Source: "{#MyAppSourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon; IconFilename: "{app}\{#MyAppExeName}"

[Run]
Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Filename: "{app}\{#MyAppExeName}"; Flags: nowait postinstall skipifsilent

[Registry]
; Clean up startup entry on uninstall:
; launch_at_startup registers under HKCU\Software\Microsoft\Windows\CurrentVersion\Run with name "Argus"
; and HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run with name "Argus".
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueName: "Argus"; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run"; ValueName: "Argus"; Flags: uninsdeletevalue

[Code]
// Close any running instance of Argus before installing or uninstalling.
function InitializeSetup(): Boolean;
var
  ErrorCode: Integer;
begin
  // Terminate any running Argus.exe process cleanly or via taskkill if running
  ShellExec('open', 'taskkill.exe', '/f /im Argus.exe', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode);
  Result := True;
end;

function InitializeUninstall(): Boolean;
var
  ErrorCode: Integer;
begin
  // Ensure running Argus instance is closed before files are removed
  ShellExec('open', 'taskkill.exe', '/f /im Argus.exe', '', SW_HIDE, ewWaitUntilTerminated, ErrorCode);
  Result := True;
end;


; ZeroType — Inno Setup installer script.
;
; Run from the repository root after `flutter build windows --release`:
;   iscc installer\zerotype.iss
;
; CI passes the version via /DMyAppVersion=<x.y.z>; for local builds we fall
; back to a placeholder so iscc doesn't fail.
#ifndef MyAppVersion
  #define MyAppVersion "0.0.0-local"
#endif

#define MyAppName        "ZeroType"
#define MyAppPublisher   "ZeroType"
#define MyAppURL         "https://github.com/alarmz/ZeroType"
#define MyAppExeName     "zero_type.exe"
#define BuildOutputDir   "..\build\windows\x64\runner\Release"

[Setup]
; A unique AppId. Do NOT regenerate this for new versions — Windows uses it
; to identify upgrades vs side-by-side installs.
AppId={{8C5F4A3D-3F6E-4D2B-B8A1-D9C6E7F2B9A3}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
; Admin is the *recommended* mode (system-wide install + auto-configure
; microphone permission + auto launch-at-startup), but the user may decline
; the UAC prompt and continue as a standard user. In that case we install
; per-user under LocalAppData and skip the auto-config registry writes;
; the welcome page (InfoBeforeFile) explains the trade-off in both
; languages so the choice is informed.
PrivilegesRequired=admin
PrivilegesRequiredOverridesAllowed=dialog commandline
InfoBeforeFile=install-mode-info.txt
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir=Output
OutputBaseFilename=ZeroTypeSetup-{#MyAppVersion}
SolidCompression=yes
Compression=lzma2
WizardStyle=modern
UninstallDisplayName={#MyAppName} {#MyAppVersion}
UninstallDisplayIcon={app}\{#MyAppExeName}
CloseApplications=force
RestartApplications=no
; If a previous version of zero_type.exe is running, kill it before files
; get replaced — otherwise the file copy will fail with "in use".
SetupLogging=yes

[Languages]
; Wizard chrome stays English. The Chinese-speaking audience reads the
; bilingual InfoBeforeFile page which carries the actual setup choices.
; (Inno Setup ships ChineseTraditional only as an "unofficial" language
; file that's not present on every install — including the default GHA
; windows-latest image.)
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon";     Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
; Auto-launch task is only offered in admin mode — in non-admin mode the
; user is told to enable it from inside ZeroType's Settings page instead.
Name: "launchatstartup"; Description: "Launch {#MyAppName} when Windows starts"; GroupDescription: "Startup:"; Check: IsAdminInstallMode

[Files]
Source: "{#BuildOutputDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}";       Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Registry]
; Pre-allow microphone access for ZeroType so the user doesn't have to dig
; into Settings → Privacy → Microphone the first time they hit Alt+Space.
;
; Only applied in admin install mode — the welcome page promises that
; non-admin installs leave the system untouched, so the user has a clear
; mental model: "admin = auto-configured, standard = I'll set it up myself".
;
; The Windows microphone consent store keys exe paths with backslashes
; replaced by '#'. The full subkey is computed at install time by
; GetMicConsentSubkey() in [Code] below.
;
; Note: this only takes effect if the global "Allow desktop apps to access
; your microphone" toggle is on (default for most users). If it's off, the
; user still has to flip it manually — by design, since flipping a global
; privacy toggle silently would be hostile.
Root: HKCU; Subkey: "{code:GetMicConsentSubkey}"; ValueType: string; ValueName: "Value"; ValueData: "Allow"; Flags: uninsdeletekey; Check: IsAdminInstallMode

; Optional: launch on Windows startup. Stored on HKCU\…\Run instead of using
; the launch_at_startup plugin's own mechanism so it survives uninstall (we
; remove it on uninstall via uninsdeletevalue). Tied to the launchatstartup
; task which itself only appears in admin install mode.
Root: HKCU; Subkey: "SOFTWARE\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "ZeroType"; ValueData: """{app}\{#MyAppExeName}"""; Flags: uninsdeletevalue; Tasks: launchatstartup

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch {#MyAppName}"; Flags: postinstall nowait skipifsilent

[Code]
function GetMicConsentSubkey(Param: String): String;
var
  exePath: String;
begin
  exePath := ExpandConstant('{app}\{#MyAppExeName}');
  StringChange(exePath, '\', '#');
  Result := 'SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone\NonPackaged\' + exePath;
end;

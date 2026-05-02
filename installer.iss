[Setup]
AppName=Rythmify
AppVersion=1.0.0
AppPublisher=Rythmify Team
AppPublisherURL=https://rythmify.com
AppSupportURL=https://rythmify.com
AppUpdatesURL=https://rythmify.com
DefaultDirName={autopf}\Rythmify
DefaultGroupName=Rythmify
AllowNoIcons=yes
OutputDir=installer_output
OutputBaseFilename=Rythmify_Setup
SetupIconFile=windows\runner\resources\app_icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Rythmify"; Filename: "{app}\rythmify.exe"
Name: "{group}\{cm:UninstallProgram,Rythmify}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\Rythmify"; Filename: "{app}\rythmify.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\rythmify.exe"; Description: "{cm:LaunchProgram,Rythmify}"; Flags: nowait postinstall skipifsilent

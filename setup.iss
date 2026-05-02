[Setup]
AppName=Rythmify
AppVersion=1.0.0
AppPublisher=Rythmify
DefaultDirName={autopf}\Rythmify
Uninstallable=yes
WizardStyle=modern
OutputBaseFilename=RythmifySetup
Compression=lzma
SolidCompression=yes

[Files]
Source: "C:\cufe\spring26\SW\cross\build\windows\x64\runner\Release\*"; \
    DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Rythmify"; Filename: "{app}\Rythmify.exe"
Name: "{autodesktop}\Rythmify"; Filename: "{app}\Rythmify.exe"

[Run]
Filename: "{app}\Rythmify.exe"; Description: "Launch Rythmify"; Flags: nowait postinstall

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
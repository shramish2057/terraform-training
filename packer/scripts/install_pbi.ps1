<powershell>
# Power BI Desktop download + silent install
$destination = "C:\Temp"
New-Item -Path $destination -ItemType Directory -Force | Out-Null

# Use the latest download URL from Microsoft or a fixed version
$powerBIUrl = "https://download.microsoft.com/download/5/c/0/5c0f9730-75cf-4ff9-a183-17924e5ccaa5/PBIDesktopSetup_x64.exe"
$installer = "$destination\PBIDesktopSetup_x64.exe"

Invoke-WebRequest -Uri $powerBIUrl -OutFile $installer
Start-Process -FilePath $installer -ArgumentList "/quiet", "/norestart" -Wait
</powershell>

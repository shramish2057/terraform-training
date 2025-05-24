<powershell>
$gocdUrl = "https://download.go.cd/binaries/23.2.0-17873/win/go-server-23.2.0-17873-setup.exe"
$gocdInstaller = "C:\Temp\gocd.exe"
Invoke-WebRequest $gocdUrl -OutFile $gocdInstaller
Start-Process $gocdInstaller -ArgumentList "/S" -Wait
</powershell>

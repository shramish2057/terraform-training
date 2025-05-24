<powershell>
$javaUrl = "https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.1+12/OpenJDK21U-jdk_x64_windows_hotspot_21.0.1_12.msi"
$javaInstaller = "C:\Temp\adoptium.msi"
Invoke-WebRequest $javaUrl -OutFile $javaInstaller
Start-Process msiexec.exe -ArgumentList "/i", "$javaInstaller", "/qn" -Wait
</powershell>

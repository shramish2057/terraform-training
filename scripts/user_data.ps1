<powershell>
# Example script
Install-WindowsFeature Web-Server
Invoke-WebRequest https://github.com/adoptium/temurin/releases/download/jdk-21.0.1+12/OpenJDK21U-jdk_x64_windows_hotspot_21.0.1_12.msi -OutFile C:\temp\java.msi
Start-Process msiexec.exe -ArgumentList '/i', 'C:\temp\java.msi', '/qn' -NoNewWindow -Wait
</powershell>

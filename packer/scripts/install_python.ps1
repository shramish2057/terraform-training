<powershell>
$pythonUrl = "https://www.python.org/ftp/python/3.11.3/python-3.11.3-amd64.exe"
$pythonInstaller = "C:\Temp\python.exe"
Invoke-WebRequest $pythonUrl -OutFile $pythonInstaller
Start-Process $pythonInstaller -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
</powershell>

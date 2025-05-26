<powershell>
# Create temp directory
$destination = "C:\Temp"
New-Item -Path $destination -ItemType Directory -Force | Out-Null

# Download and install Python
$pythonUrl = "https://www.python.org/ftp/python/3.11.3/python-3.11.3-amd64.exe"
$pythonInstaller = "$destination\python.exe"
Invoke-WebRequest $pythonUrl -OutFile $pythonInstaller
Start-Process $pythonInstaller -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait

# Refresh environment variables
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Install required Python packages
python -m pip install --upgrade pip
python -m pip install boto3 openpyxl pandas numpy pyspark sqlalchemy beautifulsoup4

# Clean up
Remove-Item $pythonInstaller -Force
</powershell>

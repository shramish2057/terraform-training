# Enable WinRM
winrm quickconfig -quiet
Set-Item -Force WSMan:\localhost\Service\AllowUnencrypted $true
Set-Item -Force WSMan:\localhost\Service\Auth\Basic $true
Enable-PSRemoting -Force

# Open the WinRM ports in the Windows Firewall
New-NetFirewallRule -DisplayName "WinRM HTTP" -Direction Inbound -Protocol TCP -LocalPort 5985 -Action Allow
New-NetFirewallRule -DisplayName "WinRM HTTPS" -Direction Inbound -Protocol TCP -LocalPort 5986 -Action Allow

# Set timeout and memory settings
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="1024"}'
winrm set winrm/config '@{MaxTimeoutms="1800000"}'

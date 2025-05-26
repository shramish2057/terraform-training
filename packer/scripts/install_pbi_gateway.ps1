<powershell>
# Power BI Gateway download + silent install
$destination = "C:\Temp"
New-Item -Path $destination -ItemType Directory -Force | Out-Null

# Download Power BI Gateway
$gatewayUrl = "https://download.microsoft.com/download/8/8/0/880BCA75-79DD-4665-857D-39A1D1E9A0F4/OnPremisesDataGateway.msi"
$installer = "$destination\OnPremisesDataGateway.msi"

Invoke-WebRequest -Uri $gatewayUrl -OutFile $installer

# Install Power BI Gateway
Start-Process msiexec.exe -ArgumentList "/i", "$installer", "/qn", "ACCEPTEULA=1" -Wait

# Clean up
Remove-Item $installer -Force
</powershell> 
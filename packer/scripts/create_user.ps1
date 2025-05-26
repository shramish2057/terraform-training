<powershell>
# Create local user for Windows AMI
$username = "dotdata-svc"
$displayName = "DOT Enterprise Data Services"
$password = ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force

# Check if user already exists
$userExists = Get-LocalUser -Name $username -ErrorAction SilentlyContinue

if (-not $userExists) {
    # Create new local user
    New-LocalUser -Name $username `
                 -DisplayName $displayName `
                 -Password $password `
                 -AccountNeverExpires `
                 -PasswordNeverExpires

    # Add user to Administrators group
    Add-LocalGroupMember -Group "Administrators" -Member $username

    Write-Host "Created user $username with display name '$displayName'"
} else {
    Write-Host "User $username already exists"
}
</powershell> 
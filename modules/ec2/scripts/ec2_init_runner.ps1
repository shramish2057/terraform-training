<powershell>
# Set execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force

# Wait for network
Start-Sleep -Seconds 60

# Setup init script
$DB_HOST = "${db_host}"
$DB_USER = "${db_user}"
$DB_PASS = "${db_password}"
$DB_NAME = "${db_name}"

$env:PGPASSWORD = $DB_PASS
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f C:\init_db.sql
</powershell>

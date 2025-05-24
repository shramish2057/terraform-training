<powershell>
# Injected by Terraform
$env:PGPASSWORD = "${db_password}"

# Wait to ensure RDS is up
Start-Sleep -Seconds 90

# Run SQL Init
psql -h "${db_host}" -U "${db_user}" -d "${db_name}" -f "C:\\init_db.sql"
</powershell>

#Powershell module providing supporting functions
Import-Module '\\van-nas01\Backups\Scripts\Powershell\Demo\PS_SQL_Functions.psm1'
set-location "c:"

# Script Configuration 
$PrincipalInstance ='VAN-SQL2008v1\sql01' 
$SecondaryInstance = 'VAN-SQL2014v1\sql01'
$PrincipalEndpoint ='TCP://VAN-SQL2008v1.Iac.Net:5022' 
$MirrorEndpoint ='TCP://VAN-SQL2014v1.iac.net:5022'

# Generate Database List
# This can either be generated from SQL Server or Controlled by File
$Databases = Get-ChildItem "SQLServer:\SQL\$PrincipalInstance\Databases\" | where {$_.Name -ne 'DBMaint'}
#$Databases = Get-Content .\DBList.txt


#Loop through databases and configure mirroring based on configuration defined above
Foreach ($database in $Databases)
{
    write-host "Restoring Database: $database" -BackgroundColor Red

    Restore-DatabaseBackup -SourceInstance  $PrincipalInstance  -SourceDatabase $database.Name -DestInstance $SecondaryInstance -DestDatabase $database.Name -NoRecovery

    $SQLMirror  = "ALTER DATABASE $($Database.Name) SET PARTNER = N'$PrincipalEndpoint';"
    $SQLPrimary = "ALTER DATABASE $($Database.Name) SET PARTNER = N'$MirrorEndpoint'; ALTER DATABASE $($Database.Name) Set Safety Off;"

    Invoke-Sqlcmd -ServerInstance $SecondaryInstance -Query $SQLMirror
    Invoke-Sqlcmd -ServerInstance $PrincipalInstance -Query $SQLPrimary

}
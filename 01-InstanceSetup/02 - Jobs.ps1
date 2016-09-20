import-module sqlps | out-null
clear

#When SQL Logins are scripted, they are by default disabled and have a random password.
#This is less then ideal as there are better ways to transfer the logins. 

$SourceInstance = 'van-sql2008v1\sql01'
$DestInstance   = 'van-sql2014v1\sql01'

$Jobs = Get-ChildItem "SQLSERVER:\\SQL\\$SourceInstance\\JobServer\\Jobs\\" | where {$_.Name -inotmatch '##' -and $_.Name -inotmatch 'sa' -and $_.Name -inotmatch 'NT '}

$SQL = ''

FOREACH ($Job in $Jobs)
{
    $SQL += $Job.Script()
}

$SQL


#Invoke-Sqlcmd -ServerInstance $DestInstance -Query $SQL


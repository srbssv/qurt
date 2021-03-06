Import-Module ActiveDirectory

# экспортировать всееееееех учеников в один csv-файл

$ScriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$ScriptPath = $ScriptPath + "\exported.csv"

Get-ADUser -Filter * -SearchBase "OU=Students, OU=Users, OU=ALM-FM, dc=nis, dc=edu, dc=kz" -Properties Description | Select SamAccountName, GivenName, Surname, Description, UserPrincipalName | Export-CSV -Path $ScriptPath -Delimiter ";" -Encoding UTF8 -NoTypeInformation
"Done!"
Read-Host("Нажмите Enter...")
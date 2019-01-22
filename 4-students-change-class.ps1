Import-Module ActiveDirectory

$ScriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$Filename = Read-Host("ָלÿ פאיכא: ")
$Filename = $ScriptPath + "\" + $Filename + ".csv"

$users = Import-CSV -Path $Filename -Delimiter ";"
foreach ($user in $users) {
    if ($user.SamAccountName -ne ""){
        $SamAccountName = $user.SamAccountName
        $LastGrade = $user.LastGrade
        $NewGrade = $user.NewGrade
        $NewOU = Get-ADOrganizationalUnit -Filter {Name -like $NewGrade} -SearchBase "OU=Students, OU=Users, OU=ALM-FM, dc=nis, dc=edu, dc=kz" -SearchScope OneLevel
        $u = Get-ADUser -Filter {SamAccountName -like $SamAccountName} -SearchBase "OU=Students, OU=Users, OU=ALM-FM, dc=nis, dc=edu, dc=kz"
        Set-ADUser $u -Description $NewOU.Name
        Move-ADObject $u -TargetPath $NewOU.DistinguishedName
        $u.Name, $LastGrade, " -> ", $NewOU.Name
    }
}
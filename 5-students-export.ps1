Import-Module ActiveDirectory

$ScriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$Filename = Read-Host("Имя файла: ")
$Filename = $ScriptPath + "\" + $Filename + ".csv"

$users = Import-CSV -Path $Filename -Delimiter ";"
foreach ($user in $users) {
    $SamAccountName = $user.SamAccountName
    $u = Get-ADUser -Filter {SamAccountName -like $SamAccountName} -SearchBase "OU=Students, OU=Users, OU=ALM-FM, dc=nis, dc=edu, dc=kz" -Properties MemberOf
    $MemberOf = $u.MemberOf
    foreach ($Member in $MemberOf) {
        $GroupToRemove = Get-ADGroup $Member
        if ($GroupToRemove.Name -notlike "students_all*"){
            Remove-ADGroupMember $GroupToRemove -Members $u -Confirm:$False
            }
        }
    $Status = $user.Status.ToString()
    Set-ADUser $u -Description $Status
    $u | Disable-ADAccount
    Move-ADObject $u -TargetPath "OU=Import_Students, OU=Users, OU=ALM-FM, dc=nis, dc=edu, dc=kz"
}
Read-Host("Нажмите Enter...")
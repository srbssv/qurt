Import-Module ActiveDirectory

$ScriptPath = split-path -parent $MyInvocation.MyCommand.Definition

$FileName = Read-Host("Имя файла:")
$Pass = Read-Host("Придумай пароль:")
$Path = $ScriptPath + "\" + $FileName + ".csv"
$users = Import-CSV $Path -Delimiter ";"
$Group = Get-ADGroup -Filter {Name -like "students_all*"} -SearchBase "OU=Security, OU=Groups, OU=ALM-FM, dc=nis, dc=edu, dc=kz"
#$Pass = "Qqwerty1!"
$users
#
foreach ($u in $users){
        $OU = $u.grade
        $iin = $u.SamAccountName
        $TargetOU = "OU=" + $OU + ", OU=Students, OU=Users, OU=ALM-FM, dc=nis, dc=edu, dc=kz"
        $mail = $u.translated + "@fmalm.nis.edu.kz"
        $description = $u.grade
        $Name = $u.givenname + " " + $u.surname
        #if ($OU[0] -eq "7"){
            New-ADUser -UserPrincipalName $mail -AccountPassword (ConvertTo-SecureString $Pass -AsPlainText -Force) -Enabled $True -ChangePasswordAtLogon $true -PasswordNeverExpires $false -Description $description -Name $Name -SamAccountName $iin -EmailAddress $mail -GivenName $u.givenname -Surname $u.surname -DisplayName $Name -OtherAttributes @{'nISEDUKZIIN'=$iin} -Path $TargetOU
            $CurrentUser = Get-ADUser -Filter {SamAccountName -like $iin} -SearchBase "OU=Students, OU=Users, OU=ALM-FM, dc=nis, dc=edu, dc=kz"
            Add-ADGroupMember $Group -Members $CurrentUser
        #}
}
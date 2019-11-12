Import-Module ActiveDirectory
# Скрипт, создающий учетные записи новых учеников, если их нет в системе.
# Он также выявляет уже существующие учетки,
# весь список которых сохраняет в файле LOG.TXT

$ScriptPath = split-path -parent $MyInvocation.MyCommand.Definition

$FileName = Read-Host("Имя файла")
$Pass = Read-Host("Придумай пароль")
$Path = $ScriptPath + "\" + $FileName + ".csv"
$LogFile = $ScriptPath + "\" +"LOG.TXT"
$users = Import-CSV $Path -Delimiter ";"
$Group = Get-ADGroup -Filter {Name -like "students_all*"} -SearchBase "OU=Security, OU=Groups, OU=ALM-FM, dc=nis, dc=edu, dc=kz"
#
$ExistingUsers = @()
$role = "student"
foreach ($u in $users){
        $OU = $u.grade
        $iin = $u.SamAccountName
        $TargetOU = "OU=" + $OU + ", OU=Students, OU=Users, OU=ALM-FM, dc=nis, dc=edu, dc=kz"
        $mail = $u.translated + "@fmalm.nis.edu.kz"
        $description = $u.grade
        $Name = $u.givenname + " " + $u.surname
        $Exists = $false
        #if ($OU[0] -eq "7"){
            # Пробуем создать учетку
            try {
                New-ADUser -UserPrincipalName $mail -AccountPassword (ConvertTo-SecureString $Pass -AsPlainText -Force) -Enabled $True -ChangePasswordAtLogon $true -PasswordNeverExpires $false -Description $description -Name $Name -SamAccountName $iin -EmailAddress $mail -GivenName $u.givenname -Surname $u.surname -DisplayName $Name -OtherAttributes @{'nISEDUKZIIN'=$iin; 'nISEDUKZROLE'=$role} -Path $TargetOU
            }
            catch [Microsoft.ActiveDirectory.Management.ADInvalidOperationException] {
                # Если такой уже есть, то выводим о нем информацию на экран
                $usr = Get-ADUser -Filter {SamAccountName -like $iin} -Properties CanonicalName
                $CanonicalName = $usr.CanonicalName.ToString()
                Write-Output("--- Ученик '"+$usr.Name.ToString()+"' уже существует: "+$CanonicalName)
                $Exists = $True
                $ExistingUsers += $CanonicalName
                #
                
            }
            if ($Exists -eq $False) {
                # Добавляем созданную учетку в группу его класса
                $CurrentUser = Get-ADUser -Filter {SamAccountName -like $iin} -SearchBase "OU=Students, OU=Users, OU=ALM-FM, dc=nis, dc=edu, dc=kz"
                Add-ADGroupMember $Group -Members $CurrentUser
            }
            
        #}
}
# Сохраняем список уже существующих учеников в файл LOG.TXT
# С этого списка мы можем брать адреса учетных записей и давать их айтишникам других школ,
# чтобы они перекинули учетки в наш раздел ALM-FM.
# Затем мы можем назначать их в классы, запустив "6-students-import.ps1".
if ($ExistingUsers.Count -gt 0) {
    $ExistingUsers | Out-File -FilePath $LogFile -Encoding utf8
    Write-Output("Список уже существующих учеников сохранен в файле LOG.TXT")
}
Read-Host("Нажмите Enter...")
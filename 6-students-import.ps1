Import-Module ActiveDirectory
# Скрипт перемещает переведенных учеников в нужный класс.
# 
#
$ScriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$Filename = Read-Host("Имя файла")
$Filename = $ScriptPath + "\" + $Filename
$FileName = $FileName.ToLower()
$FileName_ = $FileName.Split(".")

if ($Filename_[$FileName_.Count-1] -ne "csv") {
    $FileName += ".csv"
}

# Пробуем импортировать CSV-файл
try {
    $users = Import-CSV -Path $Filename -Delimiter ";"
}
catch [System.IO.FileNotFoundException] {
	# Если не существует, то пишем об этом.
    $Err = "Файл " + $FileName + " не существует!"
    Write-Output($Err)
}

foreach ($user in $users){
    # Сначала переименовываем адрес с "name@***.nis.edu.kz" на "name@fmalm.nis.edu.kz", в описании пишем название класса
	$ClassName = $user.Grade
    $SamAccountName = $user.SamAccountName + "*"
    $u = Get-ADUser -Filter {SamAccountName -like $SamAccountName} -SearchBase "OU=ALM-FM, dc=nis, dc=edu, dc=kz"
    $OldMail = $u.UserPrincipalName
    $split = $OldMail.Split("@")
    $NewMail = $split[0].ToString() + "@fmalm.nis.edu.kz"
    Set-ADUser $u -UserPrincipalName $NewMail -EmailAddress $NewMail -Description $ClassName
	
	# добавляем в нужную группу
    $ClassName = $ClassName + "*"
	$DistributionGroup = Get-ADGroup -Filter {Name -like $ClassName} -SearchBase "OU=Students, OU=Distribution, OU=Groups, OU=ALM-FM, dc=nis, dc=edu, dc=kz"
	Add-ADGroupMember -Identity $DistributionGroup -Members $u

	# затем перемещаем в папку нужного класса.
    $OU = Get-ADOrganizationalUnit -Filter {Name -like $ClassName} -SearchBase "OU=Students, OU=Users, OU=ALM-FM, dc=nis, dc=edu, dc=kz" -SearchScope OneLevel
    Move-ADObject $u -TargetPath $OU.DistinguishedName
	# Показываем, где он находится теперь.
	Get-ADUser -Filter {SamAccountName -like $SamAccountName} -SearchBase "OU=Students, OU=Users, OU=ALM-FM, dc=nis, dc=edu, dc=kz) -Properties CanonicalName"
}
Read-Host("Нажмите Enter...")
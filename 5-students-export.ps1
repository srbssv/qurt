Import-Module ActiveDirectory

$ScriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$Filename = Read-Host("Имя файла: ")
$Filename = $ScriptPath + "\" + $Filename + ".csv"

$users = Import-CSV -Path $Filename -Delimiter ";"
foreach ($user in $users) {
    # тут надо перемещать студентов в папку Import, почистить группы, написать в Description, что они отчислены, переведены или ушли по собственному желанию
}
#Import Chocolatey Powershell cmdlets
Import-Module C:\ProgramData\chocolatey\helpers\chocolateyInstaller.psm1

# update $env:PATH with the recently installed Chocolatey packages.
Update-SessionEnvironment

#SSMS & Extensions
choco install sql-server-management-studio
<# Manual:
	*Configure to connect to (localdb)\MSSQLLocalDB
#>

#Pin SSMS Shortcut to Taskbar
Install-ChocolateyPinnedTaskBarItem -TargetFilePath "${env:ProgramFiles(x86)}\Microsoft SQL Server\140\Tools\Binn\ManagementStudio\Ssms.exe"

#dbForge SQL Complete, v5.7 Express
$packageName = 'SQLComplete57Exp'
$installerType = 'exe'
$url = 'https://www.devart.com/dbforge/sql/sqlcomplete/sqlcompletesql57exp.exe'
$silentArgs = '/verysilent /suppressmsgboxes"'
$checksum = '53A35442D0DD86BBEFECF0C5F5976F39'
$checksumType = 'md5'
$validExitCodes = @(0)
Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$url" -checksum "$checksum" -checksumType "$checksumType" -validExitCodes $validExitCodes

#SSMSBoost for SSMS
$packageName = 'SSMSBoost'
$installerType = 'msi'
$url = 'https://www.ssmsboost.com/InstallPackages/SSMSBoostInstaller_3.1.6458.msi'
$silentArgs = '/passive /qn"'
$checksum = 'DD8000ECEFBE33A97B99A1DE92ADEF86'
$checksumType = 'md5'
$validExitCodes = @(0)
Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$url" -checksum "$checksum" -checksumType "$checksumType" -validExitCodes $validExitCodes

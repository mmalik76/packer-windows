#Import Chocolatey Powershell cmdlets
Import-Module C:\ProgramData\chocolatey\helpers\chocolateyInstaller.psm1

# see https://www.visualstudio.com/vs/
# see https://docs.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio
# see https://docs.microsoft.com/en-us/visualstudio/install/command-line-parameter-examples
# see https://docs.microsoft.com/en-us/visualstudio/install/workload-and-component-ids
$archiveUrl = 'https://aka.ms/vs/15/release/vs_community.exe'
$archiveHash = '746992E8F20CD2B567A92BF30B370614869514EBBBA21E2F538187EFD12B4438'
$archiveName = Split-Path $archiveUrl -Leaf
$archivePath = "$env:TEMP\$archiveName"
Write-Host 'Downloading the Visual Studio Setup Bootstrapper...'
Invoke-WebRequest $archiveUrl -UseBasicParsing -OutFile $archivePath
$archiveActualHash = (Get-FileHash $archivePath -Algorithm SHA256).Hash
if ($archiveHash -ne $archiveActualHash) {
    throw "$archiveName downloaded from $archiveUrl to $archivePath has $archiveActualHash hash witch does not match the expected $archiveHash"
}
Write-Host 'Installing Visual Studio...'
for ($try = 1; ; ++$try) {
    &$archivePath `
        --add Microsoft.VisualStudio.Workload.CoreEditor `
        --add Microsoft.VisualStudio.Workload.NetCoreTools `
        --add Microsoft.VisualStudio.Workload.NetWeb `
		--add Microsoft.VisualStudio.Workload.Data `
        --norestart `
        --quiet `
        --wait `
        | Out-String -Stream
    if ($LASTEXITCODE) {
        if ($try -le 5) {
            Write-Host "Failed to install Visual Studio with Exit Code $LASTEXITCODE. Trying again (hopefully the error was transient)..."
            Start-Sleep -Seconds 10
            continue
        }
        throw "Failed to install Visual Studio with Exit Code $LASTEXITCODE"
    }
    break
}

# update $env:PATH with the recently installed Chocolatey packages.
Update-SessionEnvironment

#Pin Visual Studio Shortcut to Taskbar
Install-ChocolateyPinnedTaskBarItem -TargetFilePath "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2017\Community\Common7\IDE\devenv.exe"
<#
 Manual:
	*Update Visual Studio to always run as Administrator
	*Configure to use installed version of node & git?
#>

#Install Docker for Windows
choco install docker-for-windows
<# Manual:
	*Enable-WindowsOptionalFeature -Online -FeatureName:Microsoft-Hyper-V -All
	*Switch Docker to use Windows Containers?
	*Configure docker shared drive?
#>

#VS Extensions - does not work with VS 2017
#choco install ReSharper
#$name = 'Highlight all occurrences of selected word'
#$url = 'https://visualstudiogallery.msdn.microsoft.com/bb578ca2-eebc-4fa6-9db8-41b16036c962/file/265304/2/SelectionHighlight.vsix'
#Install-ChocolateyVsixPackage $name $url
#$name = 'Productivity Power Tools 2017'
#$url = 'https://visualstudiogallery.msdn.microsoft.com/bb578ca2-eebc-4fa6-9db8-41b16036c962/file/265304/2/SelectionHighlight.vsix'
#Install-ChocolateyVsixPackage $name $url
#$name = 'Visual Studio Spell Checker (VS2017 and Later)'
#$url = 'https://visualstudiogallery.msdn.microsoft.com/bb578ca2-eebc-4fa6-9db8-41b16036c962/file/265304/2/SelectionHighlight.vsix'
#Install-ChocolateyVsixPackage $name $url
#$name = 'Web Essentials 2017'
#$url = 'https://visualstudiogallery.msdn.microsoft.com/bb578ca2-eebc-4fa6-9db8-41b16036c962/file/265304/2/SelectionHighlight.vsix'
#Install-ChocolateyVsixPackage $name $url
#$name = 'Indent Guides'
#$url = 'https://visualstudiogallery.msdn.microsoft.com/bb578ca2-eebc-4fa6-9db8-41b16036c962/file/265304/2/SelectionHighlight.vsix'
#Install-ChocolateyVsixPackage $name $url
#$name = 'Markdown Editor'
#$url = 'https://visualstudiogallery.msdn.microsoft.com/bb578ca2-eebc-4fa6-9db8-41b16036c962/file/265304/2/SelectionHighlight.vsix'
#Install-ChocolateyVsixPackage $name $url

# define the Install-Application function that downloads and unzips an application.
Add-Type -AssemblyName System.IO.Compression.FileSystem
function Install-Application($name, $url, $expectedHash, $expectedHashAlgorithm = 'SHA256') {
    $localZipPath = "$env:TEMP\$name.zip"
    Invoke-WebRequest $url -OutFile $localZipPath
    $actualHash = (Get-FileHash $localZipPath -Algorithm $expectedHashAlgorithm).Hash
    if ($actualHash -ne $expectedHash) {
        throw "$name downloaded from $url to $localZipPath has $actualHash hash that does not match the expected $expectedHash"
    }
    $destinationPath = Join-Path $env:ProgramFiles $name
    [IO.Compression.ZipFile]::ExtractToDirectory($localZipPath, $destinationPath)
}

# set keyboard layout.
# NB you can get the name from the list:
#      [Globalization.CultureInfo]::GetCultures('InstalledWin32Cultures') | Out-GridView
#Set-WinUserLanguageList en-US -Force

# set the date format, number format, etc.
#Set-Culture en-US

# set the welcome screen culture and keyboard layout.
# NB the .DEFAULT key is for the local SYSTEM account (S-1-5-18).
#New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS | Out-Null
#'Control Panel\International','Keyboard Layout' | ForEach-Object {
#    Remove-Item -Path "HKU:.DEFAULT\$_" -Recurse -Force
#    Copy-Item -Path "HKCU:$_" -Destination "HKU:.DEFAULT\$_" -Recurse -Force
#}

# set the timezone.
# Get-TimeZone -ListAvailable #lists all available timezone ids
Set-TimeZone -Name "Central Standard Time"

# show window content while dragging.
Set-ItemProperty -Path 'HKCU:Control Panel\Desktop' -Name DragFullWindows -Value 1

# show hidden files.
Set-ItemProperty -Path HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name Hidden -Value 1

# show protected operating system files.
#Set-ItemProperty -Path HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowSuperHidden -Value 1

# show file extensions.
Set-ItemProperty -Path HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name HideFileExt -Value 0

# never combine the taskbar buttons.
#
# possibe values:
#   0: always combine and hide labels (default)
#   1: combine when taskbar is full
#   2: never combine
Set-ItemProperty -Path HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name TaskbarGlomLevel -Value 1

# display full path in the title bar.
New-Item -Path HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState -Force `
    | New-ItemProperty -Name FullPath -Value 1 -PropertyType DWORD `
    | Out-Null

# set desktop background.
Copy-Item C:\vagrant\vs.jpg C:\Windows\Web\Wallpaper\Windows -Force
Set-ItemProperty -Path 'HKCU:Control Panel\Desktop' -Name Wallpaper -Value C:\Windows\Web\Wallpaper\Windows\vs.jpg
Set-ItemProperty -Path 'HKCU:Control Panel\Desktop' -Name WallpaperStyle -Value 0
Set-ItemProperty -Path 'HKCU:Control Panel\Desktop' -Name TileWallpaper -Value 0
Set-ItemProperty -Path 'HKCU:Control Panel\Colors' -Name Background -Value '30 30 30'

# set lock screen background.
#Copy-Item C:\vagrant\vs.jpg C:\Windows\Web\Screen -Force
#New-Item -Path HKLM:Software\Policies\Microsoft\Windows\Personalization -Force `
#    | New-ItemProperty -Name LockScreenImage -Value C:\Windows\Web\Screen\vs.jpg `
#    | New-ItemProperty -Name PersonalColors_Background -Value '#1e1e1e' `
#    | New-ItemProperty -Name PersonalColors_Accent -Value '#007acc' `
#    | Out-Null

# set account picture.
#$accountSid = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
#$accountPictureBasePath = "C:\Users\Public\AccountPictures\$accountSid"
#$accountRegistryKeyPath = "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\AccountPicture\Users\$accountSid"
#mkdir $accountPictureBasePath | Out-Null
#New-Item $accountRegistryKeyPath | Out-Null
## NB we are resizing the same image for all the resolutions, but for better
##    results, you should use images with different resolutions.
#Add-Type -AssemblyName System.Drawing
#$accountImage = [System.Drawing.Image]::FromFile("c:\vagrant\vagrant.png")
#32,40,48,96,192,240,448 | ForEach-Object {
#    $p = "$accountPictureBasePath\Image$($_).jpg"
#    $i = New-Object System.Drawing.Bitmap($_, $_)
#    $g = [System.Drawing.Graphics]::FromImage($i)
#    $g.DrawImage($accountImage, 0, 0, $_, $_)
#    $i.Save($p)
#    New-ItemProperty -Path $accountRegistryKeyPath -Name "Image$_" -Value $p -Force | Out-Null
#}

# enable audio.
Set-Service Audiosrv -StartupType Automatic
Start-Service Audiosrv

#Import Chocolatey Powershell cmdlets
Import-Module C:\ProgramData\chocolatey\helpers\chocolateyInstaller.psm1

# config chocolatey to skip confirmation for each package
chocolatey feature enable -n allowGlobalConfirmation

# install classic shell.
#New-Item -Path HKCU:Software\IvoSoft\ClassicStartMenu -Force `
#    | New-ItemProperty -Name ShowedStyle2      -Value 1 -PropertyType DWORD `
#    | Out-Null
#New-Item -Path HKCU:Software\IvoSoft\ClassicStartMenu\Settings -Force `
#    | New-ItemProperty -Name EnableStartButton -Value 1 -PropertyType DWORD `
#    | New-ItemProperty -Name SkipMetro         -Value 1 -PropertyType DWORD `
#    | Out-Null
#choco install -y classic-shell -installArgs ADDLOCAL=ClassicStartMenu

# install Google Chrome.
# see https://www.chromium.org/administrators/configuring-other-preferences
choco install googlechrome
$chromeLocation = 'C:\Program Files (x86)\Google\Chrome\Application'
cp -Force GoogleChrome-external_extensions.json (Get-Item "$chromeLocation\*\default_apps\external_extensions.json").FullName
cp -Force GoogleChrome-master_preferences.json "$chromeLocation\master_preferences"
#cp -Force GoogleChrome-master_bookmarks.html "$chromeLocation\master_bookmarks.html"

#VSCode
choco install VisualStudioCode

# Essential applications
choco install 7zip
choco install adobereader
choco install chocolateygui
choco install ditto
#choco install evernote
#choco install javaruntime
choco install notepadplusplus #--x86
#choco install paint.net
<#
	Config Ditto 
		- Don't show in task bar
		- HotKey Ctrl+Shift+V
	Install Notepad++ Plugin Manager
	Install Notepad++ Plugins
		- JSON Viewer
		- XML Tools
#>

# Dev tools
choco install astrogrep
choco install dotpeek
choco install git --params '/GitOnlyOnPath /NoAutoCrlf /NoShellIntegration'
#choco install gitextensions
choco install nodejs
choco install papercut
choco install poshgit
choco install postman
#choco install ruby
choco install sourcetree
#choco install webpi
choco install winmerge
<#
	Run Papercut ClickOnce file
#>

#System Utils
choco install defraggler
choco install sdelete
choco install windirstat

# update $env:PATH with the recently installed Chocolatey packages.
Update-SessionEnvironment

# configure git.
# see http://stackoverflow.com/a/12492094/477532
git config --global user.name 'Matt Malik'
git config --global user.email 'matthew.d.malik@gmail.com'
git config --global push.default simple
git config --global core.autocrlf false
git config --global diff.tool winmerge
git config --global difftool.winmerge.name 'WinMerge'
git config --global difftool.winmerge.trustExitCode 'true'
git config --global difftool.winmerge.path 'C:/Program Files (x86)/WinMerge/WinMergeU.exe'

git config --global difftool.winmerge.cmd '\"C:/Program Files (x86)/WinMerge/WinMergeU.exe\" -u -e $LOCAL $REMOTE'
git config --global merge.tool winmerge
git config --global mergetool.winmerge.name 'WinMerge'
git config --global mergetool.winmerge.trustExitCode 'true'
git config --global mergetool.winmerge.path 'C:/Program Files (x86)/WinMerge/WinMergeU.exe'
git config --global mergetool.winmerge.cmd '\"C:/Program Files (x86)/WinMerge/WinMergeU.exe\" -u -e -dl \"Local\" -dr \"Remote\" $LOCAL $REMOTE $MERGED'
#git config --list --show-origin

#Update NPM
npm install -g npm-windows-upgrade
npm-windows-upgrade --npm-version latest

#Install global NPM packages
npm install -g npm-check-updates #Used to check for updates of installed packages, and for other package managers like bower
npm install -g rimraf #Used to delete folders that can't be deleted by windows explorer because the file names are too long
npm install -g bower #The browser package manager
npm install -g yarn #Fast, reliable, and secure dependency management

#Pin items to Taskbar
#Install-ChocolateyPinnedTaskBarItem -TargetFilePath "${env:windir}\explorer.exe"
Install-ChocolateyPinnedTaskBarItem -TargetFilePath "${env:ProgramFiles}\Notepad++\notepad++.exe"
Install-ChocolateyPinnedTaskBarItem -TargetFilePath "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"
Install-ChocolateyPinnedTaskBarItem -TargetFilePath "${env:ProgramFiles}\Microsoft VS Code\Code.exe"
	
# remove the default desktop shortcuts.
del C:\Users\Public\Desktop\*.lnk
del -Force C:\Users\Public\Desktop\*.ini

# add MSYS2 shortcut to the Desktop and Start Menu.
#Install-ChocolateyShortcut `
#  -ShortcutFilePath "$env:USERPROFILE\Desktop\MSYS2 Bash.lnk" `
#  -TargetPath 'C:\Program Files\ConEmu\ConEmu64.exe' `
#  -Arguments '-run {MSYS2} -icon C:\tools\msys64\msys2.ico' `
#  -IconLocation C:\tools\msys64\msys2.ico `
#  -WorkingDirectory '%USERPROFILE%'
#Install-ChocolateyShortcut `
#  -ShortcutFilePath "C:\Users\All Users\Microsoft\Windows\Start Menu\Programs\MSYS2 Bash.lnk" `
#  -TargetPath 'C:\Program Files\ConEmu\ConEmu64.exe' `
#  -Arguments '-run {MSYS2} -icon C:\tools\msys64\msys2.ico' `
#  -IconLocation C:\tools\msys64\msys2.ico `
#  -WorkingDirectory '%USERPROFILE%'

# add Services shortcut to the Desktop.
#Install-ChocolateyShortcut `
#  -ShortcutFilePath "$env:USERPROFILE\Desktop\Services.lnk" `
#  -TargetPath "$env:windir\system32\services.msc" `
#  -Description 'Windows Services'



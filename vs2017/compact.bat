rmdir /S /Q C:\Windows\Debug
mkdir C:\Windows\Debug
rmdir /S /Q C:\Windows\Logs
mkdir C:\Windows\Logs
rmdir /S /Q C:\Windows\Prefetch
mkdir C:\Windows\Prefetch
rmdir /S /Q C:\Windows\Temp
mkdir C:\Windows\Temp
rmdir /S /Q C:\Users\vagrant\AppData\Local\Temp
mkdir C:\Users\vagrant\AppData\Local\Temp

net stop wuauserv
rmdir /S /Q C:\Windows\SoftwareDistribution\Download
mkdir C:\Windows\SoftwareDistribution\Download
net start wuauserv

cmd /c "C:\Program Files\Defraggler\df.exe" C: /fsaf

cmd /c %SystemRoot%\System32\reg.exe ADD HKCU\Software\Sysinternals\SDelete /v EulaAccepted /t REG_DWORD /d 1 /f
cmd /c C:\ProgramData\chocolatey\lib\sdelete\tools\sdelete.exe -q -z C:

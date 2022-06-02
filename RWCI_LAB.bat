SET Version=Version 3.70
IF NOT EXIST C:\Apps MD C:\Apps
ECHO. >> C:\Apps\log.txt
ECHO %date% %time% >> C:\Apps\log.txt
ECHO %Version% >> C:\Apps\log.txt
ECHO %time% - Start >> C:\Apps\log.txt

CALL :UpdateTimeZone
CALL :SleepSettings
CALL :CheckInternet
CALL :UpdateMain
CALL :UpdateScreenConnect
CALL :WiFiPreload
CALL :DisableIPv6
CALL :Applications
CALL :FileAssociations
CALL :Recovery
CALL :CleanupVMwareDumpFiles
CALL :TruncateLog

IF EXIST C:\Recovery\AutoApply\Test GOTO test

ECHO %time% - Finish >> C:\Apps\log.txt
EXIT

:test
ECHO %time% - Test Started >> C:\Apps\log.txt

ECHO %time% - Test Finished >> C:\Apps\log.txt
ECHO %time% - Finish >> C:\Apps\log.txt
EXIT

::UpdateTimeZone--------------------------------------------------------------------
:UpdateTimeZone
ECHO %time% - UpdateTimeZone - Start >> C:\Apps\log.txt
tzutil /s "Eastern Standard Time"
ECHO %time% - UpdateTimeZone - Finish >> C:\Apps\log.txt
EXIT /b


::CheckInternet--------------------------------------------------------------------
:CheckInternet
ECHO %time% - CheckInternet - Start >> C:\Apps\log.txt
SET REPEAT=0
:REPEAT
IF %REPEAT%==5 ECHO %time% - CheckInternet - No Internet >> C:\Apps\log.txt & EXIT
SET /a REPEAT=%REPEAT%+1
ECHO %time% - CheckInternet - Attempt %REPEAT% >> C:\Apps\log.txt
PING google.com -n 1
IF %ERRORLEVEL%==1 TIMEOUT /T 20 & GOTO REPEAT
ECHO %time% - CheckInternet - Finish >> C:\Apps\log.txt
EXIT /b


::UpdateMain-----------------------------------------------------------------------
:UpdateMain
ECHO %time% - UpdateMain - Start >> C:\Apps\log.txt
SCHTASKS /query /TN RWCI_LAB_Main
IF %ERRORLEVEL%==1 SCHTASKS /CREATE /SC ONSTART /TN "RWCI_LAB_Main" /TR "C:\Apps\RWCI_LAB.bat" /RU SYSTEM /NP /V1 /F
IF %PROCESSOR_ARCHITECTURE%==AMD64 Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/RWCI_LAB_Laptops/main/RWCI_LAB.bat -O C:\Apps\RWCI_LAB.bat
FIND "%Version%" C:\Apps\RWCI_LAB.bat
IF %ERRORLEVEL%==0 ECHO %time% - UpdateMain - Updated >> C:\Apps\log.txt & EXIT /b
ECHO %time% - UpdateMain - OutDated - Relaunching >> C:\Apps\log.txt
CALL C:\apps\RWCI_LAB.bat
ECHO %time% - UpdateMain - Finish >> C:\Apps\log.txt
EXIT /b


::UpdateScreenConnect---------------------------------------------------------------
:UpdateScreenConnect
ECHO %time% - UpdateScreenConnect - Start >> C:\Apps\log.txt
IF NOT EXIST C:\Apps\ScreenConnect_21.13.5058.7951.msi Powershell Invoke-WebRequest https://github.com/Children-and-Family-Services-Center/CFSC_Laptops/raw/main/ScreenConnect_21.13.5058.7951.msi -O C:\Apps\ScreenConnect_21.13.5058.7951.msi & ECHO %time% - UpdateScreenConnect - Downloading >> C:\Apps\log.txt
MSIEXEC.exe /q /i C:\Apps\ScreenConnect_21.13.5058.7951.msi /norestart
ECHO %time% - UpdateScreenConnect - Finish >> C:\Apps\log.txt
EXIT /b

::WiFiPreload-----------------------------------------------------------------------
:WiFiPreload
ECHO %time% - WiFiPreload - Start >> C:\Apps\log.txt
Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/WiFi-CFSCPublicPW.xml -O C:\Apps\WiFi-CFSCPublicPW.xml
Powershell Invoke-WebRequest https://github.com/Children-and-Family-Services-Center/RWCI_LAB_Laptops/blob/main/RWCI_LAB_WiFi.xml -O C:\Apps\RWCI_LAB_WiFi.xml
netsh wlan show profiles | find "RWCI Guest"
IF %ERRORLEVEL%==0 ECHO %time% - WiFiPreload - WiFi Already Loaded >> C:\Apps\log.txt & EXIT /b
netsh wlan add profile filename="C:\Apps\WiFi-CFSCPublicPW.xml" interface="Wi-Fi" user=all
netsh wlan add profile filename="C:\Apps\RWCI_LAB_WiFi.xml" interface="Wi-Fi" user=all
ECHO %time% - WiFiPreload - WiFi Loaded >> C:\Apps\log.txt
DEL C:\Apps\WiFI-CFSCPublicPW.xml /F /Q
DEL C:\Apps\RWCI_LAB_WiFi.xml /F /Q
ECHO %time% - WiFiPreload - Finish >> C:\Apps\log.txt
EXIT /b

::CleanupVMwareDumpFiles------------------------------------------------------------
:CleanupVMwareDumpFiles
ECHO %time% - CleanupVMwareDumpFiles - Start >> C:\Apps\log.txt
RD C:\ProgramData\VMware\VDM /S /Q
RD "C:\Users\RWCI\AppData\Local\VMware\VDM" /S /Q
DEL %temp%\*.* /F /S /Q
DEL C:\WINDOWS\Temp\*.* /F /S /Q
DEL C:\Users\RWCI\Desktop\debug.log /F /Q
ECHO %time% - CleanupVMwareDumpFiles - Finish >> C:\Apps\log.txt
EXIT /b

::TruncateLog------------------------------------------------------------
:TruncateLog
ECHO %time% - TruncateLog - Start >> C:\Apps\log.txt
powershell "get-content -tail 100 C:\apps\log.txt" > %temp%\log.txt
MORE %temp%\log.txt > C:\Apps\Log.txt
ECHO %time% - TruncateLog - Finish >> C:\Apps\log.txt
EXIT /b

::DisableIPv6--------------------------------------------------
:DisableIPv6
ECHO %time% - DisableIPv6 - Start >> C:\Apps\log.txt
REG ADD HKLM\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters /T REG_DWORD /V DisabledComponents /D 0x11 /F
ECHO %time% - DisableIPv6 - Finish >> C:\Apps\log.txt
EXIT /b

::Applications---------------------------------------------------------
:Applications
ECHO %time% - Apps - Start >> C:\Apps\log.txt
::----------------Office 2021-------------------
ECHO %time% - Apps - Office Started... >> C:\Apps\log.txt
IF EXIST C:\Recovery\Office GOTO OfficeInstall
ECHO %time% - Apps - Office Downloading... >> C:\Apps\log.txt
ICACLS C:\Recovery /setowner SYSTEM /T /C /Q
ICACLS C:\Recovery /reset /T /C /Q
Powershell Invoke-WebRequest https://github.com/Children-and-Family-Services-Center/RWCI_LAB_Laptops/raw/main/setup.exe -O C:\Recovery\Setup.exe
Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/RWCI_LAB_Laptops/main/Office2021.xml -O C:\Recovery\Office2021.xml
C:\Recovery\setup.exe /download C:\Recovery\Office2021.xml
:OfficeInstall
ECHO %time% - Apps - Office Installing... >> C:\Apps\log.txt
C:\Recovery\setup.exe /configure C:\Recovery\Office2021.xml
ECHO %time% - Apps - Office Finished >> C:\Apps\log.txt
::----------------Google Chrome--------------------------------
ECHO %time% - Apps - Google Chrome Installing... >> C:\Apps\log.txt
choco upgrade googlechrome -y --install-if-not-installed
ECHO %time% - Apps - Google Chrome Finished >> C:\Apps\log.txt
::----------------FireFox--------------------------------------
ECHO %time% - Apps - FireFox Installing... >> C:\Apps\log.txt
choco upgrade firefox -y --install-if-not-installed
DEL "C:\Users\Public\Desktop\Firefox.lnk" /f /q
ECHO %time% - Apps - FireFox Finished >> C:\Apps\log.txt
::----------------VLC Media Player-----------------------------
ECHO %time% - Apps - VLC Installing... >> C:\Apps\log.txt
choco upgrade vlc -y --install-if-not-installed
DEL "C:\Users\Public\Desktop\VLC media player.lnk" /f /q
ECHO %time% - Apps - VLC Finished >> C:\Apps\log.txt
::----------------Zoom Client---------------------------------
ECHO %time% - Apps - Zoom Client Installing... >> C:\Apps\log.txt
choco upgrade Zoom -y --install-if-not-installed
ECHO %time% - Apps - Zoom Client Finished >> C:\Apps\log.txt
::----------------Adobe Reader--------------------------------
ECHO %time% - Apps - Adobe Reader Installing... >> C:\Apps\log.txt
choco upgrade adobereader -y --install-if-not-installed
ECHO %time% - Apps - Adobe Reader Finished >> C:\Apps\log.txt
::----------------App Configs---------------------------------
ECHO %time% - Apps - App Configs... >> C:\Apps\log.txt
REG ADD HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main /v PreventFirstRunPage /t REG_DWORD /d 1 /f
ECHO %time% - Apps - App Configs Finished >> C:\Apps\log.txt
ECHO %time% - Apps - Finish >> C:\Apps\log.txt
EXIT /b

::FileAssociations--------------------------------------------------------------------
:FileAssociations
ECHO %time% - FileAssociations - Start >> C:\Apps\log.txt
Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/RWCI_LAB_Laptops/main/AppAssoc.xml -O C:\Apps\AppAssoc.xml
DISM /Online /Export-DefaultAppAssociations:C:\Apps\AppAssoc.xml
ECHO %time% - FileAssociations - Finish >> C:\Apps\log.txt
EXIT /b

::SleepSettings--------------------------------------------------------------------
:SleepSettings
ECHO %time% - SleepSettings Started >> C:\Apps\log.txt
POWERCFG -Change -monitor-timeout-ac 45
POWERCFG -CHANGE -disk-timeout-ac 0
POWERCFG -CHANGE -standby-timeout-ac 0
POWERCFG -CHANGE -hibernate-timeout-ac 0
POWERCFG -CHANGE -monitor-timeout-dc 15
POWERCFG -CHANGE -disk-timeout-dc 0
POWERCFG -CHANGE -standby-timeout-dc 25
POWERCFG -CHANGE -hibernate-timeout-dc 0
ECHO %time% - SleepSettings Finished >> C:\Apps\log.txt
EXIT /b

::Recovery--------------------------------------------------------------------
:Recovery
ECHO %time% - Recovery Started >> C:\Apps\log.txt
ICACLS C:\Recovery /setowner SYSTEM /T /C /Q
ICACLS C:\Recovery /reset /T /C /Q
IF NOT EXIST C:\Recovery\AutoApply MD C:\Recovery\AutoApply
Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/RWCI_LAB_Laptops/main/unattend.xml -O C:\Recovery\AutoApply\unattend.xml
Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/RWCI_LAB_Laptops/main/WiFi-CFSCPublicPW.xml -O C:\Recovery\AutoApply\WiFi-CFSCPublicPW.xml
Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/RWCI_LAB_Laptops/main/RWCI_LAB_WiFi.xml -O C:\Recovery\AutoApply\RWCI_LAB_WiFi.xml
Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/RWCI_LAB_Laptops/main/Restore.bat -O C:\Recovery\AutoApply\Restore.bat
ECHO %time% - Recovery Finished >> C:\Apps\log.txt
EXIT /b


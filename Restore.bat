@ECHO OFF

CALL :CheckInternet
CALL :UpdateTimeZone
CALL :RenamePC
CALL :SetupUserAccounts
CALL :InstallChoco
CALL :ActivateMainScript
CALL :AutoLogon
CALL :AppCleanup

SHUTDOWN -r -t 5
EXIT

::CheckInternet--------------------------------------------------------------------
:CheckInternet
netsh wlan add profile filename="C:\Recovery\AutoApply\WiFi-CFSCPublicPW.xml" interface="Wi-Fi" user=all
netsh wlan add profile filename="C:\Recovery\AutoApply\RWCI_LAB_WiFi.xml" interface="Wi-Fi" user=all
SET REPEAT=0
:REPEAT
IF %REPEAT%==5 CLS & ECHO No Internet - Please Connect to Internet and press Enter & TIMEOUT /T 60 & SET REPEAT=0
SET /a REPEAT=%REPEAT%+1
PING google.com -n 1
CLS
IF %ERRORLEVEL%==1 ECHO Attempt %REPEAT% - No Internet... & TIMEOUT /T 5 & GOTO REPEAT
CLS
EXIT /b

::UpdateTimeZone--------------------------------------------------------------------
:UpdateTimeZone
tzutil /s "Eastern Standard Time"
EXIT /b

::RenamePC-----------------------------------------------------
:RenamePC
FOR /F "Tokens=*" %%I IN ('powershell "gwmi win32_bios | Select-Object -Expand SerialNumber"') do SET name=%%I
IF %COMPUTERNAME%==RWCI-LAB-%name:~-7% EXIT /b
WMIC computersystem where caption='%computername%' rename 'RWCI-LAB-%name:~-7%'
EXIT /b

::InstallChoco-----------------------------------------------------
:InstallChoco
POWERSHELL Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
EXIT /b

::ActivateMainScript-----------------------------------------------------
:ActivateMainScript
IF NOT EXIST C:\Apps MD C:\Apps
SCHTASKS /CREATE /SC ONSTART /TN "RWCI_LAB_Main" /TR "C:\Apps\RWCI_LAB.bat" /RU SYSTEM /NP /V1 /F
IF %PROCESSOR_ARCHITECTURE%==AMD64 Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/RWCI_LAB_Laptops/main/RWCI_LAB.bat -O C:\Apps\RWCI_LAB.bat
EXIT /b

::AutoLogon-----------------------------------------------------
:AutoLogon
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon" /T REG_SZ /V DefaultUserName /D RWCI /f
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon" /T REG_SZ /V AutoAdminLogon /D 1 /f
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon" /T REG_SZ /V DefaultPassword /f
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\OOBE" /T REG_DWORD /V DisablePrivacyExperience /D 1 /f
EXIT /b

::SetupUserAccounts-----------------------------------------------------
:SetupUserAccounts
NET USER Administrator /ACTIVE:YES
NET USER Administrator %password%
for /F "delims=" %%i in ( 'net localgroup Administrators' ) do ( net localgroup Administrators "%%i" /delete )
NET USER RWCI /ADD
NET LOCALGROUP Users RWCI /ADD
WMIC UserAccount WHERE "Name='RWCI'" SET PasswordExpires=FALSE
WMIC UserAccount WHERE "Name='RWCI'" SET PasswordChangeable=FALSE
EXIT /b

::AppCleanup-----------------------------------------------------------
:AppCleanup
Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/RWCI_LAB_Laptops/main/AppCleanup.ps1 -O C:\Recovery\AutoApply\AppCleanup.ps1
Powershell -executionpolicy unrestricted -File C:\Recovery\AutoApply\Appcleanup.ps1
EXIT /b

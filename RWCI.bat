set "psCommand=powershell -Command "$pword = read-host 'Administrator Password? ' -AsSecureString ; ^
    $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword); ^
        [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)""
for /f "usebackq delims=" %%p in (`%psCommand%`) do set password=%%p
CLS

::Activate Local Admin Account and Set Password
NET USER Administrator /ACTIVE:YES
NET USER Administrator %password%
for /F "delims=" %%i in ( 'net localgroup Administrators' ) do ( net localgroup Administrators "%%i" /delete )

::Add Local RWCI User
NET USER RWCI /ADD
NET LOCALGROUP Users RWCI /ADD
WMIC UserAccount WHERE "Name='RWCI'" SET PasswordExpires=FALSE
WMIC UserAccount WHERE "Name='RWCI'" SET PasswordChangeable=FALSE

:Auto Logon
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon" /T REG_SZ /V DefaultUserName /D RWCI /f
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon" /T REG_SZ /V AutoAdminLogon /D 1 /f
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon" /T REG_SZ /V DefaultPassword /f
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\OOBE" /T REG_DWORD /V DisablePrivacyExperience /D 1 /f

::Rename PC
FOR /F "Tokens=*" %%I IN ('powershell "gwmi win32_bios | Select-Object -Expand SerialNumber"') do SET name=%%I
WMIC computersystem where caption='%computername%' rename 'RWCI-LAB-%name:~-7%'

::Install Chocolatey
POWERSHELL Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))


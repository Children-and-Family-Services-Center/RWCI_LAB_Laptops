for /f "Tokens=*" %%I in ('powershell -command " & {get-localuser RWCI | select-object SID | format-table -hidetableheader}"') Do Set UserSID=%%I
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\%UserSID%" /f /va
RD C:\Users\RWCI /S /Q
RD C:\Users\RWCI.%computername% /S /Q
RD C:\$Recycle.bin /S /Q
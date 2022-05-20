MD C:\Recovery\AutoApply
Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/RWCI_LAB_Laptops/main/unattend.xml -O C:\Recovery\AutoApply\unattend.xml
Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/CFSC_Laptops/main/WiFi-CFSCPublicPW.xml -O C:\Recovery\AutoApply\WiFi-CFSCPublicPW.xml
Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/RWCI_LAB_Laptops/main/RWCI_LAB_WiFi.xml -O C:\Recovery\AutoApply\RWCI_LAB_WiFi.xml
Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/RWCI_LAB_Laptops/main/RWCI_LAB_FirstRun.bat -O C:\Recovery\AutoApply\RWCI_LAB_FirstRun.bat
Powershell Invoke-WebRequest https://raw.githubusercontent.com/Children-and-Family-Services-Center/RWCI_LAB_Laptops/main/Restore.bat -O C:\Recovery\AutoApply\Restore.bat
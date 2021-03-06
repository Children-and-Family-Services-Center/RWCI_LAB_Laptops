Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -NotLike "*Calculator*" -and $_.DisplayName -NotLike "*Alarms*" -and $_.DisplayName -NotLike "*Photo*" -and $_.DisplayName -NotLike "*Sticky*" -and $_.DisplayName -NotLike "*Edge*" -and $_.DisplayName -NotLike "*Paint*"} | Remove-AppXProvisionedPackage -Online
Get-AppxPackage -AllUsers | Where-Object { $_.IsFramework -Match 'False' -and $_.NonRemovable -Match 'False' -and $_.Name -NotLike "*Calculator*" -and $_.Name -NotLike "*Alarm*" -and $_.Name -NotLike "*Photo*" -and $_.Name -NotLike "*Sticky*" -and $_.Name -NotLike "*Edge*" -and $_.Name -NotLike "*Paint*"} | Remove-AppxPackage -AllUsers
# Test push
cls
C:
Remove-Module PCXLab.SCCM -Force
Remove-Module PCXLab.SCCM
Clear-Host
Import-Module .\src\Modules\PCXLab.SCCM
#Import-Module .\src\Modules\PCXLab.SCCM -Force

get-module -Name PCXLab.SCCM
Get-Command -Module PCXLab.SCCM

Get-ChildItem .\src\Modules\PCXLab.SCCM\1.0.2 -Recurse -Include *.ps1 |
Select-String "DefaultLimitingCollection"



Get-ChildItem C:\Projects\PCXLABCMAutomation -Recurse -Include *.ps1, *.psm1, *.psd1 |
Select-String -Pattern 'Perfect'


Get-ChildItem C:\Projects\PCXLABCMAutomation -Recurse -Include *.ps1, *.psm1, *.psd1 |
Select-String -Pattern 'LiteralPath'

Create-PCXCMPackage -Path "\\192.168.25.214\Package_Source\Applications\Igor Pavlov\7zip\7zip 27.121.3" -DistributionPointGroups "All Mangalore DPs" 


     
Get-CMPackage -Name "PKG Igor Pavlov 7zip 27.121.3" -Fast


Get-CMPackage -Name "PKG Igor Pavlov 7zip 27.121.3" -Fast |
Format-Table Name,PackageID

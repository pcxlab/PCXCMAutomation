# SCCM Automation Notes
cd C:\Projects\PCXCMAutomation

Import-Module .\Modules\PCXLab.Core\0.1.0\PCXLab.Core.psd1 -Force

Get-Command -Module PCXLab.Core

Write-PCXLog -Message "Core module test successful"

Import-Module .\Modules\PCXLab.SCCM\0.1.0\PCXLab.SCCM.psd1 -Force

Get-Command -Module PCXLab.SCCM

Connect-PCXCM
Get-PCXCMDevice
Get-PCXCMCollection
New-PCXCMCollection

#V 0.1.1

# SCCM Automation Notes
cd C:\Projects\PCXCMAutomation

#Import-Module .\Modules\PCXLab.Core\0.1.0\PCXLab.Core.psd1 -Force

Get-Command -Module PCXLab.Core

Write-PCXLog -Message "Core module test successful"

Remove-Module PCXLab.Core -Force
Import-Module .\src\Modules\PCXLab.Core -Force
Get-Module -Name "PCXLab.Core"
Get-Command -Module PCXLab.Core

Remove-Module PCXLab.SCCM -Force
Import-Module .\src\Modules\PCXLab.SCCM -Force
Get-Module -Name "PCXLab.SCCM"
Get-Command -Module PCXLab.SCCM

#(Get-Module -ListAvailable -Name "PCXLab.Core").Version
(Get-Module -Name "PCXLab.SCCM").Version

Get-Module -ListAvailable -Name "PCXLab.Core" |
Select-Object Name, Version | Sort-Object Version -Descending



Remove-Module PCXLab.SCCM -Force
Import-Module .\src\Modules\PCXLab.SCCM -Force
Get-Command -Module PCXLab.SCCM

Connect-PCXCMSite
New-PCXCMFolder "DeviceCollection\Training"



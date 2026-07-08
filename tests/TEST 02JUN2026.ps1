C:
Remove-Module PCXLab.SCCM -Force
Remove-Module PCXLab.SCCM
Clear-Host
Import-Module .\src\Modules\PCXLab.SCCM
#Import-Module .\src\Modules\PCXLab.SCCM -Force

Get-Command -Module PCXLab.SCCM

Connect-PCXCMSite

Reset-PCXCMConnection

Ensure-PCXCMConnection

Create-PCXCMApplication -Path "\\192.168.25.214\Package_Source\Applications\Igor Pavlov\7zip\7zip 26.0.2"
Create-PCXCMPackage -Path "\\192.168.25.214\Package_Source\Applications\Igor Pavlov\7zip\7zip 26.0.2"
#Create-PCXCMPackage -Path "\\192.168.25.214\Package_Source\Applications\Igor Pavlov\NO PATH\7zip\7zip 26.0.2"

Create-PCXCMApplication -Path "\\192.168.25.214\Package_source\Applications\Igor Pavlov\7zip\7zip 26.0.1"
Create-PCXCMPackage -Path "\\192.168.25.214\Package_source\Applications\Igor Pavlov\7zip\7zip 26.0.1"

#Cleanup
Remove-CMDeviceCollection -Name "APP Igor Pavlov 7zip 26.0.2 [INSTALL]" -Force
Remove-CMDeviceCollection -Name "APP Igor Pavlov 7zip 26.0.2 [EXCEPTION]" -Force
Remove-CMDeviceCollection -Name "APP Igor Pavlov 7zip 26.0.2 [UNINSTALL]" -Force
Remove-CMDeviceCollection -Name "APP Igor Pavlov 7zip 26.0.2 [AVAILABLE]" -Force
Remove-CMApplication -Name "APP Igor Pavlov 7zip 26.0.2" -Force

Remove-CMDeviceCollection -Name "PKG Igor Pavlov 7zip 26.0.2 [INSTALL]" -Force
Remove-CMDeviceCollection -Name "PKG Igor Pavlov 7zip 26.0.2 [EXCEPTION]" -Force
Remove-CMDeviceCollection -Name "PKG Igor Pavlov 7zip 26.0.2 [UNINSTALL]" -Force
Remove-CMDeviceCollection -Name "PKG Igor Pavlov 7zip 26.0.2 [AVAILABLE]" -Force
Remove-CMPackage -Name "PKG Igor Pavlov 7zip 26.0.2" -Force

Remove-CMDeviceCollection -Name "APP Igor Pavlov 7zip 26.0.1 [INSTALL]" -Force
Remove-CMDeviceCollection -Name "APP Igor Pavlov 7zip 26.0.1 [EXCEPTION]" -Force
Remove-CMDeviceCollection -Name "APP Igor Pavlov 7zip 26.0.1 [UNINSTALL]" -Force
Remove-CMDeviceCollection -Name "APP Igor Pavlov 7zip 26.0.1 [AVAILABLE]" -Force
Remove-CMApplication -Name "APP Igor Pavlov 7zip 26.0.1" -Force

Remove-CMDeviceCollection -Name "PKG Igor Pavlov 7zip 26.0.1 [INSTALL]" -Force
Remove-CMDeviceCollection -Name "PKG Igor Pavlov 7zip 26.0.1 [EXCEPTION]" -Force
Remove-CMDeviceCollection -Name "PKG Igor Pavlov 7zip 26.0.1 [UNINSTALL]" -Force
Remove-CMDeviceCollection -Name "PKG Igor Pavlov 7zip 26.0.1 [AVAILABLE]" -Force
Remove-CMPackage -Name "PKG Igor Pavlov 7zip 26.0.1" -Force

Remove-CMFolder -FolderPath "PS1:\DeviceCollection\PCXLab Application Deployment\Igor Pavlov\7zip\PKG Igor Pavlov 7zip 26.0.1" -Force 
Remove-CMFolder -FolderPath "PS1:\DeviceCollection\PCXLab Application Deployment\Igor Pavlov\7zip\APP Igor Pavlov 7zip 26.0.1" -Force 
Remove-CMFolder -FolderPath "PS1:\DeviceCollection\PCXLab Application Deployment\Igor Pavlov\7zip\PKG Igor Pavlov 7zip 26.0.2" -Force 
Remove-CMFolder -FolderPath "PS1:\DeviceCollection\PCXLab Application Deployment\Igor Pavlov\7zip\APP Igor Pavlov 7zip 26.0.2" -Force 

Remove-CMFolder -FolderPath "PS1:\DeviceCollection\PCXLab Application Deployment\Igor Pavlov\7zip" -Force 
Remove-CMFolder -FolderPath "PS1:\DeviceCollection\PCXLab Application Deployment" -Force 
Remove-CMFolder -FolderPath "PS1:\Application\Application Installation\Igor Pavlov\7zip" -Force
Remove-CMFolder -FolderPath "PS1:\Application\Application Installation\" -Force # End slash will not work and it will fail
Remove-CMFolder -FolderPath "PS1:\Application\Application Installation" -Force # without end slash it works
Remove-CMFolder -FolderPath "PS1:\Package\Application Installation" -Force # without end slash it works

#################################################

Get-ChildItem .\src\Modules\PCXLab.SCCM\0.11.0 -Recurse -Filter *.ps1 |
Select-String "NoNewline"

Remove-CMDeviceCollection -Name "PKG Igor Pavlov 7zip 26.0.1 [UNINSTALL]" -Force
New-CMDeviceCollection -Name "MyCol" -LimitingCollectionName "All Systems"

"PKG Igor Pavlov 7zip 26.0.1 [UNINSTALL]"

Get-CMSupportedPlatform -Fast | Select-Object -First 5

Get-Command Get-CMSupportedPlatform -All

Get-Module ConfigurationManager -All

Get-CMSupportedPlatform : The 'Get-CMSupportedPlatform' command was found in the module 'ConfigurationManager', but the module could not be loaded.


Get-CMSupportedPlatform -Fast

Get-CMSupportedPlatform

Get-PSProvider CMSite

Get-PSDrive -PSProvider CMSite

Get-Location

Connect-PCXCMSite
Get-Module

Get-PSProvider CMSite

Get-PSDrive -PSProvider CMSite

Get-Location

Get-Module


Get-ChildItem .\src\Modules\PCXLab.SCCM\0.11.0 -Recurse -Filter *.ps1 |
Select-String "InstallationFileLocation"

Get-ChildItem .\src\Modules\PCXLab.SCCM\0.11.0 -Recurse -Filter *.ps1 |
Select-String "ApplicationName"

Get-ChildItem .\src\Modules\PCXLab.SCCM\0.11.0 -Recurse -Filter *.ps1 |
Select-String "Add-CMScriptDeploymentType|Add-CMMsiDeploymentType"

Get-Content .\src\Modules\PCXLab.SCCM\0.11.0\Private\Logging\Initialize-PCXLogConfiguration.ps1

Get-ChildItem .\src\Modules\PCXLab.SCCM\0.11.0 -Recurse -Filter *.ps1 |
Select-String 'Write-PCXOperationStart'

Get-Content .\src\Modules\PCXLab.SCCM\0.11.0\Public\Applications\Create-PCXCMApplication.ps1

Get-ChildItem .\src\Modules\PCXLab.SCCM\0.11.0 -Recurse -Filter *.ps1 |
Select-String "Creating application deployment"

.\Start-PCXLabSCCMUI.ps1

"C:\Projects\PCXLABCMAutomation_ADDOSREQ\src\Modules\PCXLab.SCCM.UI\Start-PCXLabSCCMUI.ps1"
.\src\Modules\PCXLab.SCCM.UI\Start-PCXLabSCCMUI.ps1


git config --global user.name "PCXLab"
git config --global user.email "[EMAIL_ADDRESS]"
git config --list

# Test push



# Test push

C:
Remove-Module PCXLab.SCCM -Force
Remove-Module PCXLab.SCCM
Clear-Host
Import-Module .\src\Modules\PCXLab.SCCM
#Import-Module .\src\Modules\PCXLab.SCCM -Force

get-module -Name PCXLab.SCCM
Get-Command -Module PCXLab.SCCM

$script:PCXSettings | ConvertTo-Json -Depth 10

Create-PCXCMPackage -Path "\\192.168.25.214\Package_Source\Applications\Igor Pavlov\7zip\7zip 26.0.4"
Test-Path "\\192.168.25.214\Package_Source\Icons\Igor Pavlov7zip.png"
Get-Item "\\192.168.25.214\Package_Source\Icons\Igor Pavlov7zip.png"


Get-ChildItem .\src\Modules\PCXLab.SCCM\1.0.2 -Recurse -Include *.ps1 |
    Select-String -Pattern "PCXSettings|Settings.json|ConvertFrom-Json"

    Get-PCXCMSetting -Name "Package.DistributionSettings.Priority"

    Get-PCXCMPackageDistributionPriority


    Get-PCXCMSetting -Name "DefaultLimitingCollection"
Get-PCXCMSetting -Name "Package.DistributionSettings.Priority"
Get-PCXCMSetting -Name "IconSettings.SecondaryIconFolder"
Get-PCXCMSetting -Name "IconSettings.EnableSecondaryLookup"
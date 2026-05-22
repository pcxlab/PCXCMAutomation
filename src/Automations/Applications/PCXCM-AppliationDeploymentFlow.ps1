#New-PCXCMApplication

Set-Location "C:\Projects\PCXCMAutomation"

Import-Module .\src\Modules\PCXLab.Core -Force
Import-Module .\src\Modules\PCXLab.SCCM -Force

Get-Command -Module PCXLab.Core
Get-Command -Module PCXLab.SCCM

Connect-PCXCMSite

New-PCXCMApplication -Name "APS_7zip_26.0.1" -Description "New Application" -Publisher "Igor-Pavlov" -SoftwereVersion "26.00" -ReleaseDate "2/12/2026" -Iconlocationfile "\\192.168.25.214\Package_Source\Applications\Igor Pavlov\7zip\7zip 26.0.0\7ZipIcon.png"
#New-PCXCMApplication -Name "AP 7Zip 26.00 (64bit Edition) Automation" -Description "New Application" -Publisher "Igor-Pavlov" -SoftwereVersion "26.00" -ReleaseDate "2/12/2026" -Iconlocationfile "\\192.168.25.214\Package_Source\Applications\Igor_Pavlov\7Zip_msi\7zip_26.0.0\7ZipIcon.png"
New-PCXCMApplicationDeploymentType -name "APS_7zip_26.0.1" -InstallationFileLocation "\\192.168.25.214\Package_Source\Applications\Igor Pavlov\7zip\7zip 26.0.0\7z2600-x64.msi" 
#New-PCXCMApplicationDeploymentType  -name "AP 7Zip 26.00 (64bit Edition) Automation" -InstallationFileLocation "\\192.168.25.214\Package_Source\Applications\Igor_Pavlov\7Zip_msi\7zip_26.0.0\7z2600-x64.msi" 
Start-PCXCMContentDistributionForApplication -ApplicationName "APS_7zip_26.0.1" -DistributionPointGroup "All Mangalore Dps"
#Start-PCXCMContentDistributionForApplication -ApplicationName "AP 7Zip 26.00 (64bit Edition) Automation" -DistributionPointGroup "ALL Mangalore Group"
New-PCXCMDeviceCollection -CollectionName "APS_7zip_26.0.1"
#New-PCXCMCMDeviceCollection -CollectionName "AP 7Zip 26.00 (64bit Edition) Automation"
New-PCXCMApplicationDeployment -Name "APS_7zip_26.0.1" -AvailableDateTime "2026-04-21 00:00:00" -Collectionname 'APS_7zip_26.0.1' -DeadlineDateTime "2026-04-22 00:00:00" -Action "Install" -Purpose "Available"
#New-PCXCMApplicationDeployment -Name "AP 7Zip 26.00 (64bit Edition) Automation" -AvailableDateTime "2026-04-21 00:00:00" -Collectionname 'AP 7Zip 26.00 (64bit Edition) Automation' -DeadlineDateTime "2026-04-22 00:00:00" -Action "Install" -Purpose "Available"


New-PCXCMApplication -Name "APS_7zip_26.0.1" -Description "New Application" -Publisher "Igor-Pavlov" -SoftwereVersion "26.00" -ReleaseDate "2/12/2026" -Iconlocationfile "\\192.168.25.214\Package_Source\Applications\Igor Pavlov\7zip\7zip 26.0.0\7ZipIcon.png"
New-PCXCMApplicationDeploymentType -name "APS_7zip_26.0.1" -InstallationFileLocation "\\192.168.25.214\Package_Source\Applications\Igor Pavlov\7zip\7zip 26.0.0\7z2600-x64.msi" 
Start-PCXCMContentDistributionForApplication -ApplicationName "APS_7zip_26.0.1" -DistributionPointGroup "All Mangalore Dps"
New-PCXCMDeviceCollection -CollectionName "APS_7zip_26.0.1"
New-PCXCMApplicationDeployment -Name "APS_7zip_26.0.1" -AvailableDateTime "2026-04-21 00:00:00" -Collectionname 'APS_7zip_26.0.1' -DeadlineDateTime "2026-04-22 00:00:00" -Action "Install" -Purpose "Available"

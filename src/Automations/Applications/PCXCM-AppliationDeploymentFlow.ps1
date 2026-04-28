#New-PCXCMApplication

Set-Location "C:\Projects\PCXCMAutomation"

Import-Module .\src\Modules\PCXLab.Core -Force
Import-Module .\src\Modules\PCXLab.SCCM -Force

Connect-PCXCMSite

New-PCXCMApplication -Name "AP 7Zip 26.00 (64bit Edition) Automation" -Description "New Application" -Publisher "Igor-Pavlov" -SoftwereVersion "26.00" -ReleaseDate "2/12/2026" -Iconlocationfile "\\192.168.25.214\Package_Source\Applications\Igor_Pavlov\7Zip_msi\7zip_26.0.0\7ZipIcon.png"
New-PCXCMApplicationDeploymentType  -name "AP 7Zip 26.00 (64bit Edition) Automation" -InstallationFileLocation "\\192.168.25.214\Package_Source\Applications\Igor_Pavlov\7Zip_msi\7zip_26.0.0\7z2600-x64.msi" 
Start-PCXCMContentDistributionForApplication -ApplicationName "AP 7Zip 26.00 (64bit Edition) Automation" -DistributionPointGroup "ALL Mangalore Group"
New-PCXCMCMDeviceCollection -CollectionName "AP 7Zip 26.00 (64bit Edition) Automation"
New-PCXCMApplicationDeployment -Name "AP 7Zip 26.00 (64bit Edition) Automation" -AvailableDateTime "2026-04-21 00:00:00" -Collectionname 'AP 7Zip 26.00 (64bit Edition) Automation' -DeadlineDateTime "2026-04-22 00:00:00" -Action "Install" -Purpose "Available"



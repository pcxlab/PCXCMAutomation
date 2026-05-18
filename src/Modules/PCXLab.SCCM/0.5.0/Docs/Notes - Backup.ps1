cd C:\Projects\PCXCMTools

Remove-Module PCXCMTools -Force
Import-Module .\PCXCMTools.psm1 -Force

Import-Module .\PCXCMTools.psm1 -Force -Verbose

Get-Module PCXCMTools

Get-Command -Module PCXCMTools

Remove-Module PCXCMTools -Force
Import-Module .\PCXCMTools.psm1 -Force -Verbose
Get-Command -Module PCXCMTools
Get-Command -Module PCXCMTools | Select Verb,Noun,Name
Test-ModuleManifest .\PCXCMTools.psd1

Remove-Module PCXCMTools -Force

Import-Module .\PCXCMTools.psd1 -Force 
Import-Module .\PCXCMTools.psd1 -Force -Verbose


New-PCXCMCollectionInFolder -CollectionName "My Collection One Thow" -FolderPath "Devicecollection\TrialOneThow"

 Get-PCXCMSiteDrive

 Connect-PCXCMSite



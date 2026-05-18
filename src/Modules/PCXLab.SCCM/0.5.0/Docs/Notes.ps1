cd C:\Projects\PCXCMTools\0.1.0

Import-Module .\PCXCMTools.psd1 -Force 
Get-Module PCXCMTools
Get-Command -Module PCXCMTools

Remove-Module PCXCMTools -Force

Connect-PCXCMSite

New-PCXCMDeviceCollectionInFolder -CollectionName "My Trial Collection" -FolderPath "Devicecollection\MyTrialCollection"


Import-Module .\src\Modules\PCXLab.SCCM -Force
Get-Module PCXLab.SCCM
Get-Command -Module PCXLab.SCCM

Import-Module .\src\Modules\PCXLab.Core -Force
Get-Module PCXLab.Core
Get-Command -Module PCXLab.Core

Connect-PCXCMSite

New-PCXCMDeviceCollectionInFolder -CollectionName "MyCollection" -FolderPath "PS1:\DeviceCollection\MyFolder\FOlderTest\"



###########################################

#----------------------------------------------------------------------------------------
#category is pending
New-CMConfigurationItem
-CreationType <CICreationType>
-Name <String>
[-Category <String[]>]
[-Description <String>]
[-DisableWildcardHandling]
[-ForceWildcardHandling]
[-WhatIf]
[-Confirm]
[<CommonParameters>]


New-CMConfigurationItem -CreationType WindowsOS -Name "CI_Windows_Config" -Category "Windows"
#--------------------------------------------------------------------------------------------------------
https://learn.microsoft.com/en-us/powershell/module/configurationmanager/new-cmbaseline?view=sccm-ps

New-CMBaseline
[-AllowComanagedClients]
[-Category <String[]>]
[-Description <String>]
-Name <String>
[-DisableWildcardHandling]
[-ForceWildcardHandling]
[-WhatIf]
[-Confirm]
[<CommonParameters>]

New-CMBaseline -Name "Windows_Baseline" 

#------------------------------------------------------------------------------------------------------------------------
Set-CMBaseline
-Name <String>
[-AddBaseline <String[]>]
[-AddCategory <String[]>]
[-AddOptionalConfigurationItem <String[]>]
[-AddOSConfigurationItem <String[]>]
[-AddProhibitedConfigurationItem <String[]>]
[-AddRequiredConfigurationItem <String[]>]
[-AddSoftwareUpdate <String[]>]
[-AllowComanagedClients <Boolean>]
[-ClearBaseline]
[-ClearOptionalConfigurationItem]
[-ClearOSConfigurationItem]
[-ClearProhibitedConfigurationItem]
[-ClearRequiredConfigurationItem]
[-ClearSoftwareUpdate]
[-Description <String>]
[-DesiredConfigurationDigestPath <String>]
[-NewName <String>]
[-PassThru]
[-RemoveBaseline <String[]>]
[-RemoveCategory <String[]>]
[-RemoveOptionalConfigurationItem <String[]>]
[-RemoveOSConfigurationItem <String[]>]
[-RemoveProhibitedConfigurationItem <String[]>]
[-RemoveRequiredConfigurationItem <String[]>]
[-RemoveSoftwareUpdate <String[]>]
[-DisableWildcardHandling]
[-ForceWildcardHandling]
[-WhatIf]
[-Confirm]
[<CommonParameters>]
    
Set-CMBaseline -Name "CI_Windows_Config" -AddBaseline "Windows_Baseline"


Get-CMBaseline "Windows_Baseline"
Get-CMConfigurationItem -Name "CI_Windows_Config"
Set-CMBaseline -Name "Windows_Baseline" -AddOSConfigurationItems "CI_Windows_Config"
Set-CMBaseline -Name "Windows_Baseline" -AddRequiredConfigurationItem "CI_Windows_Config"


$ci = Get-CMConfigurationItem -Name "CI_Windows_Config" -Fast
Set-CMBaseline -Name "Windows_Baseline" -AddRequiredConfigurationItem $ci


$ci = Get-CMConfigurationItem -Name "CI_Windows_Config" -Fast
Set-CMBaseline -Name "Windows_Baseline" -AddRequiredConfigurationItem $ci.CI_ID

$ci = Get-CMConfigurationItem -Name "CI_Windows_Config" -Fast
Set-CMBaseline -Name "Windows_Baseline" -AddRequiredConfigurationItem $ci.CI_ID

$cis = Get-CMConfigurationItem -Name "CI_*" -Fast
Set-CMBaseline -Name "Windows_Baseline" -AddRequiredConfigurationItem ($cis | Select-Object -ExpandProperty CI_ID)


$ci = Get-CMConfigurationItem -Name "CI_Windows_Config"
Set-CMBaseline -Name "Windows_Baseline" -AddRequiredConfigurationItem $ci


Set-CMBaseline -Name "Windows_Baseline" -AddRequiredConfigurationItem (Get-CMConfigurationItem -Name "CI_Windows_Config").CI_ID


# Create a new Configuration Item
New-CMConfigurationItem `
    -Name "CI_Windows_Config1" `
    -Description "Checks Windows OS compliance" `
    -Category "Operating System" `
    -CreationType WindowsOS


# Create a new Baseline
New-CMBaseline `
    -Name "Windows_Baseline1" `
    -Description "Baseline for Windows compliance"


# Get the CI object
$ci = Get-CMConfigurationItem -Name "CI_Windows_Config1" -Fast

# Add the CI to the baseline using CI_ID
Set-CMBaseline -Name "Windows_Baseline1" -AddRequiredConfigurationItem $ci.CI_ID


# Step 1: Create a Configuration Item (example for Windows OS)
$ci = New-CMConfigurationItem `
    -Name "CI_Windows_Config" `
    -CreationType WindowsOS `
    -Description "Checks Windows OS compliance"

# Step 2: Create a Baseline
$baseline = New-CMBaseline `
    -Name "Windows_Baseline" `
    -Description "Baseline for Windows compliance"

# Step 2: Create a Baseline
$baseline = New-CMBaseline `
    -Name "Windows_Baseline_Trial" `
    -Description "Baseline for Windows compliance"

# Step 3: Add the CI to the Baseline
Set-CMBaseline -Name $baseline.LocalizedDisplayName -AddRequiredConfigurationItem $ci.CI_ID
Set-CMBaseline -Name "Windows_Baseline" -AddBaseline "Windows_Baseline_Trial"


$parent = Get-CMBaseline -Name "Windows_Baseline"
$child = Get-CMBaseline -Name "Windows_Baseline_Trial"

Set-CMBaseline -InputObject $parent -AddBaseline $child


# Step 4: Verify
(Get-CMBaseline -Name "Windows_Baseline").RequiredConfigurationItems


$ci = Get-CMConfigurationItem -Name "CI_Windows_Config" -Fast

$baseline = New-CMBaseline `
    -Name "Windows_Baseline" `
    -Description "Baseline for Windows compliance"

Set-CMBaseline `
    -Name "Windows_Baseline" `
    -AddRequiredConfigurationItem $ci.CI_ID

# Nested baseline (correct way)
$child = New-CMBaseline -Name "Windows_Baseline_Trial"

Set-CMBaseline `
    -InputObject (Get-CMBaseline -Name "Windows_Baseline") `
    -AddBaseline $child


$ci = Get-CMConfigurationItem -Name "CI_Windows_Config" -Fast
$ci.CI_ID

Set-CMBaseline -Name "Windows_Baseline" -AddRequiredConfigurationItem $ci.CI_ID


# Get parent baseline (single)
$parent = Get-CMBaseline -Name "Windows_Baseline" -Fast | Select-Object -First 1

# Get child baseline (single)
$child = Get-CMBaseline -Name "Windows_Baseline_Trial" -Fast | Select-Object -First 1

# Use CI_ID (THIS is the key fix)
Set-CMBaseline `
    -InputObject $parent `
    -AddBaseline $child.CI_ID





#####################################

# Step 2: Create a Baseline Parent
$baseline = New-CMBaseline `
    -Name "Windows_Baseline" `
    -Description "Baseline for Windows compliance"

# Step 2: Create a Baseline Child
$baseline = New-CMBaseline `
    -Name "Windows_Baseline_Trial" `
    -Description "Baseline for Windows compliance"


# Get parent baseline (single)
$parent = Get-CMBaseline -Name "Windows_Baseline" -Fast | Select-Object -First 1

# Get child baseline (single)
$child = Get-CMBaseline -Name "Windows_Baseline_Trial" -Fast | Select-Object -First 1

# Use CI_ID (THIS is the key fix)
Set-CMBaseline `
    -InputObject $parent `
    -AddBaseline $child.CI_ID
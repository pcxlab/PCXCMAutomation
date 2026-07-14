function New-PCXCMPackageProgramNames {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Company,

        [Parameter(Mandatory)]
        [string]$Product,

        [Parameter()]
        [string]$Version
    )

    return [PSCustomObject]@{
        Available = New-PCXCMProgramName -Company $Company -Product $Product -Version $Version -Type "Available"
        Install   = New-PCXCMProgramName -Company $Company -Product $Product -Version $Version -Type "Install"
        Uninstall = New-PCXCMProgramName -Company $Company -Product $Product -Version $Version -Type "Uninstall"
        Upgrade   = New-PCXCMProgramName -Company $Company -Product $Product -Version $Version -Type "Upgrade"
        Rollback  = New-PCXCMProgramName -Company $Company -Product $Product -Version $Version -Type "Rollback"
        Cleanup   = New-PCXCMProgramName -Company $Company -Product $Product -Version $Version -Type "Cleanup"
        Reinstall = New-PCXCMProgramName -Company $Company -Product $Product -Version $Version -Type "Reinstall"
        OSD       = New-PCXCMProgramName -Company $Company -Product $Product -Version $Version -Type "OSD"
    }
}
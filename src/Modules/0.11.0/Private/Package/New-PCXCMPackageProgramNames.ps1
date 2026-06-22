function New-PCXCMPackageProgramNames {
    param(
        [Parameter(Mandatory)]
        [string]$PackageName
    )

    return [PSCustomObject]@{
        Available = "$PackageName [AVAILABLE]"
        Install   = "$PackageName [INSTALL]"
        Uninstall = "$PackageName [UNINSTALL]"
        Upgrade   = "$PackageName [UPGRADE]"
        OSD       = "$PackageName [OSD]"
    }
}



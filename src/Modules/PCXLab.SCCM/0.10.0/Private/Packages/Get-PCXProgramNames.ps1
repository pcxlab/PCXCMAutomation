function Get-PCXProgramNames {
    param(
        [Parameter(Mandatory)]
        [string]$PackageName
    )

    return [PSCustomObject]@{
        Available = "$PackageName [AVAILABLE]"
        Install   = "$PackageName [INSTALL]"
        Uninstall = "$PackageName [UNINSTALL]"
        Upgrade   = "$PackageName [Upgrade]"
    }
}
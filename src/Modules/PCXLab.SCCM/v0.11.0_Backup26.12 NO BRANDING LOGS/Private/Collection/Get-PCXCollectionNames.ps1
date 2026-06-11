function Get-PCXCollectionNames {
    param(
        [Parameter(Mandatory)]
        [string]$PackageName
    )

    return [PSCustomObject]@{
        Available = "$PackageName [AVAILABLE]"
        Install   = "$PackageName [INSTALL]"
        Uninstall = "$PackageName [UNINSTALL]"
        Exception = "$PackageName [EXCLUDE]"
    }
}



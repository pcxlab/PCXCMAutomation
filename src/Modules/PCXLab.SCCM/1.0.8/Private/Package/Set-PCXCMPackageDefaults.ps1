function Set-PCXCMPackageDefaults {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Package
    )

    $Priority = Get-PCXCMPackageDistributionPriority

    Set-CMPackage `
        -InputObject $Package `
        -Priority $Priority `
        -ErrorAction Stop

    Write-PCXLog "Distribution Priority: $Priority"
}
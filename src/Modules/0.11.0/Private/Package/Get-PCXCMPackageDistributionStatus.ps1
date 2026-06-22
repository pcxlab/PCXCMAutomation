function Get-PCXCMPackageDistributionStatus {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Package,

        [Parameter(Mandatory)]
        $DistributionStatus
    )

    try {

        $ResultDistribution = $DistributionStatus |
            Where-Object {
                $_.PackageID -eq $Package.PackageID
            }

        if ($ResultDistribution) {
            return 'Distributed'
        }

        return 'Not Distributed'
    }
    catch {

        Write-PCXLog `
            -Message $_.Exception.Message `
            -Level ERROR

        throw
    }
}

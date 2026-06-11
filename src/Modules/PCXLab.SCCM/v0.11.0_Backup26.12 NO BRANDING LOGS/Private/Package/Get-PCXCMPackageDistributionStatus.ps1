function Get-PCXCMPackageDistributionStatus {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Package
    )

    try {

        $Distribution = Get-CMDistributionStatus `
            -Id $Package.PackageID `
            -ErrorAction SilentlyContinue

        if ($Distribution) {
            return 'Distributed'
        }

        return 'Not Distributed'
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}
function Get-PCXCMApplicationDistributionStatus {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Application
    )

    try {

        $DistributionStatus = Get-CMContentDistribution `
            -ApplicationName $Application.LocalizedDisplayName `
            -ErrorAction SilentlyContinue

        if (-not $DistributionStatus) {
            return 'Not Distributed'
        }

        return 'Distributed'
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}
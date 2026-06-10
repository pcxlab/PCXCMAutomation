function Get-PCXCMApplicationDistributionPointCount {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Application
    )

    try {

        $DistributionStatus = Get-CMContentDistribution `
            -ApplicationName $Application.LocalizedDisplayName `
            -ErrorAction SilentlyContinue

        return @($DistributionStatus).Count
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}
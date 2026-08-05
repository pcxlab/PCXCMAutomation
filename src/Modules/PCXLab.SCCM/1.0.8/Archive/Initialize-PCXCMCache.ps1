function Initialize-PCXCMCache {

    [CmdletBinding()]
    param(
        [switch]$IncludeCollections,
        [switch]$IncludeDeployments
    )

    if (-not $Global:PCXCMCache) {
        $Global:PCXCMCache = [ordered]@{}
    }

    if ($IncludeCollections -and -not $Global:PCXCMCache.Collections) {

        Write-PCXLog -Message "Loading Collection Cache"

        $Global:PCXCMCache.Collections = Get-CMDeviceCollection

        Write-PCXLog -Message "Cached $($Global:PCXCMCache.Collections.Count) Collection(s)"
    }

    if ($IncludeDeployments -and -not $Global:PCXCMCache.Deployments) {

        Write-PCXLog -Message "Loading Deployment Cache"

        $Global:PCXCMCache.Deployments = Get-CMDeployment

        Write-PCXLog -Message "Cached $($Global:PCXCMCache.Deployments.Count) Deployment(s)"
    }

    return $Global:PCXCMCache
}

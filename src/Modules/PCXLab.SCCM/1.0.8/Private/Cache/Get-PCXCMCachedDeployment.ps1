function Get-PCXCMCachedDeployment {

    [CmdletBinding()]
    param(
        [switch]$ForceRefresh,

        [int]$ExpiresHours = 24
    )

    Initialize-PCXCMRuntimeCache

if (
    -not $ForceRefresh -and
    $null -ne $Global:PCXCMRuntimeCache.Deployments
) {
    return $Global:PCXCMRuntimeCache.Deployments
}

$CacheName = 'Deployments'

if (
    -not $ForceRefresh -and
    (Test-PCXCMCacheExists -Name $CacheName) -and
    (-not (Test-PCXCMCacheExpired -Name $CacheName))
) {

    $CacheStatus = Get-PCXCMCacheStatus -Name $CacheName

    Write-PCXLog `
        -Message "Using cached deployments. Age=$($CacheStatus.AgeHours)h"

    $CachedData = Get-PCXCMCache -Name $CacheName

    $Global:PCXCMRuntimeCache.Deployments = $CachedData

    return $CachedData
}

Write-PCXLog -Message "Refreshing deployments cache"

Ensure-PCXCMConnection

$ResultDeployments = Get-CMDeployment

Save-PCXCMCache `
    -Name $CacheName `
    -Data $ResultDeployments `
    -ExpiresHours $ExpiresHours

$Global:PCXCMRuntimeCache.Deployments = $ResultDeployments

return $ResultDeployments
}

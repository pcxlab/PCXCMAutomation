function Get-PCXCMCachedApplication {

    [CmdletBinding()]
    param(
        [switch]$ForceRefresh,

        [int]$ExpiresHours = 24
    )

    Initialize-PCXCMRuntimeCache

if (
    -not $ForceRefresh -and
    $null -ne $Global:PCXCMRuntimeCache.Applications
) {
    return $Global:PCXCMRuntimeCache.Applications
}

$CacheName = 'Applications'

if (
    -not $ForceRefresh -and
    (Test-PCXCMCacheExists -Name $CacheName) -and
    (-not (Test-PCXCMCacheExpired -Name $CacheName))
) {

    $CacheStatus = Get-PCXCMCacheStatus -Name $CacheName

    Write-PCXLog `
        -Message "Using cached applications. Age=$($CacheStatus.AgeHours)h"

    $CachedData = Get-PCXCMCache -Name $CacheName

    $Global:PCXCMRuntimeCache.Applications = $CachedData

    return $CachedData
}

Write-PCXLog -Message "Refreshing applications cache"

Ensure-PCXCMConnection

$ResultApplications = Get-CMApplication -Fast

Save-PCXCMCache `
    -Name $CacheName `
    -Data $ResultApplications `
    -ExpiresHours $ExpiresHours

$Global:PCXCMRuntimeCache.Applications = $ResultApplications

return $ResultApplications
}

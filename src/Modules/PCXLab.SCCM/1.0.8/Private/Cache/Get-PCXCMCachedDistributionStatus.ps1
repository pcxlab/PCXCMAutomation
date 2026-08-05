function Get-PCXCMCachedDistributionStatus {

    [CmdletBinding()]
    param(
        [switch]$ForceRefresh,

        [int]$ExpiresHours = 24
    )

    Initialize-PCXCMRuntimeCache

if (
    -not $ForceRefresh -and
    $null -ne $Global:PCXCMRuntimeCache.DistributionStatus
) {
    return $Global:PCXCMRuntimeCache.DistributionStatus
}

$CacheName = 'DistributionStatus'

if (
    -not $ForceRefresh -and
    (Test-PCXCMCacheExists -Name $CacheName) -and
    (-not (Test-PCXCMCacheExpired -Name $CacheName))
) {

    $CacheStatus = Get-PCXCMCacheStatus -Name $CacheName

    Write-PCXLog `
        -Message "Using cached distribution status. Age=$($CacheStatus.AgeHours)h"

    $CachedData = Get-PCXCMCache -Name $CacheName

    $Global:PCXCMRuntimeCache.DistributionStatus = $CachedData

    return $CachedData
}

Write-PCXLog -Message "Refreshing distribution status cache"

Ensure-PCXCMConnection

$ResultDistributionStatus = Get-CMDistributionStatus

Save-PCXCMCache `
    -Name $CacheName `
    -Data $ResultDistributionStatus `
    -ExpiresHours $ExpiresHours

$Global:PCXCMRuntimeCache.DistributionStatus = $ResultDistributionStatus

return $ResultDistributionStatus
}

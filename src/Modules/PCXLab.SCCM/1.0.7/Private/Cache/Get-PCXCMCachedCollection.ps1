function Get-PCXCMCachedCollection {

    [CmdletBinding()]
    param(
        [switch]$ForceRefresh,

        [int]$ExpiresHours = 24
    )

    Initialize-PCXCMRuntimeCache

    if (
        -not $ForceRefresh -and
        $null -ne $Global:PCXCMRuntimeCache.Collections
    ) {

        return $Global:PCXCMRuntimeCache.Collections
    }

    $CacheName = 'Collections'

    if (
        -not $ForceRefresh -and
        (Test-PCXCMCacheExists -Name $CacheName) -and
        (-not (Test-PCXCMCacheExpired -Name $CacheName))
    ) {

        $CacheStatus = Get-PCXCMCacheStatus `
            -Name $CacheName

        Write-PCXLog `
            -Message "Using cached collections. Age=$($CacheStatus.AgeHours)h"

        $CachedData = Get-PCXCMCache `
            -Name $CacheName

        $Global:PCXCMRuntimeCache.Collections = $CachedData

        return $CachedData
    }

    Write-PCXLog `
        -Message "Refreshing collections cache"

    Ensure-PCXCMConnection

    $ResultCollections = Get-CMDeviceCollection

    Save-PCXCMCache `
        -Name $CacheName `
        -Data $ResultCollections `
        -ExpiresHours $ExpiresHours

    $Global:PCXCMRuntimeCache.Collections = $ResultCollections

    return $ResultCollections
}

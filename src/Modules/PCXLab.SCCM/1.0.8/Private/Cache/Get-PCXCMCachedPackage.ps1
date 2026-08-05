function Get-PCXCMCachedPackage {

    [CmdletBinding()]
    param(
        [switch]$ForceRefresh,

        [int]$ExpiresHours = 24
    )
Initialize-PCXCMRuntimeCache

if (
    -not $ForceRefresh -and
    $null -ne $Global:PCXCMRuntimeCache.Packages
) {
    return $Global:PCXCMRuntimeCache.Packages
}

$CacheName = 'Packages'

if (
    -not $ForceRefresh -and
    (Test-PCXCMCacheExists -Name $CacheName) -and
    (-not (Test-PCXCMCacheExpired -Name $CacheName))
) {

    $CacheStatus = Get-PCXCMCacheStatus -Name $CacheName

    Write-PCXLog `
        -Message "Using cached packages. Age=$($CacheStatus.AgeHours)h"

    $CachedData = Get-PCXCMCache -Name $CacheName

    $Global:PCXCMRuntimeCache.Packages = $CachedData

    return $CachedData
}

Write-PCXLog -Message "Refreshing packages cache"

Ensure-PCXCMConnection

$ResultPackages = Get-CMPackage -Fast

Save-PCXCMCache `
    -Name $CacheName `
    -Data $ResultPackages `
    -ExpiresHours $ExpiresHours

$Global:PCXCMRuntimeCache.Packages = $ResultPackages

return $ResultPackages
}

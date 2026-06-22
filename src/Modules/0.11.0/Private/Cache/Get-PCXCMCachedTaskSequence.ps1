function Get-PCXCMCachedTaskSequence {

    [CmdletBinding()]
    param(
        [switch]$ForceRefresh,

        [int]$ExpiresHours = 24
    )

    Initialize-PCXCMRuntimeCache

if (
    -not $ForceRefresh -and
    $null -ne $Global:PCXCMRuntimeCache.TaskSequences
) {
    return $Global:PCXCMRuntimeCache.TaskSequences
}

$CacheName = 'TaskSequences'

if (
    -not $ForceRefresh -and
    (Test-PCXCMCacheExists -Name $CacheName) -and
    (-not (Test-PCXCMCacheExpired -Name $CacheName))
) {

    $CacheStatus = Get-PCXCMCacheStatus -Name $CacheName

    Write-PCXLog `
        -Message "Using cached task sequences. Age=$($CacheStatus.AgeHours)h"

    $CachedData = Get-PCXCMCache -Name $CacheName

    $Global:PCXCMRuntimeCache.TaskSequences = $CachedData

    return $CachedData
}

Write-PCXLog -Message "Refreshing task sequences cache"

Ensure-PCXCMConnection

$ResultTaskSequences = @(Get-CMTaskSequence -Fast)

Save-PCXCMCache `
    -Name $CacheName `
    -Data $ResultTaskSequences `
    -ExpiresHours $ExpiresHours

$Global:PCXCMRuntimeCache.TaskSequences = $ResultTaskSequences

return $ResultTaskSequences
}

function Get-PCXCMCachedTaskSequenceDeployment {

    [CmdletBinding()]
    param(
        [switch]$ForceRefresh,

        [int]$ExpiresHours = 24
    )

    Initialize-PCXCMRuntimeCache

if (
    -not $ForceRefresh -and
    $null -ne $Global:PCXCMRuntimeCache.TaskSequenceDeployments
) {
    return $Global:PCXCMRuntimeCache.TaskSequenceDeployments
}

$CacheName = 'TaskSequenceDeployments'

if (
    -not $ForceRefresh -and
    (Test-PCXCMCacheExists -Name $CacheName) -and
    (-not (Test-PCXCMCacheExpired -Name $CacheName))
) {

    $CacheStatus = Get-PCXCMCacheStatus -Name $CacheName

    Write-PCXLog `
        -Message "Using cached task sequence deployments. Age=$($CacheStatus.AgeHours)h"

    $CachedData = Get-PCXCMCache -Name $CacheName

    $Global:PCXCMRuntimeCache.TaskSequenceDeployments = $CachedData

    return $CachedData
}

Write-PCXLog -Message "Refreshing task sequence deployments cache"

Ensure-PCXCMConnection

$ResultTaskSequenceDeployments = @(Get-CMTaskSequenceDeployment -Fast)

Save-PCXCMCache `
    -Name $CacheName `
    -Data $ResultTaskSequenceDeployments `
    -ExpiresHours $ExpiresHours

$Global:PCXCMRuntimeCache.TaskSequenceDeployments = $ResultTaskSequenceDeployments

return $ResultTaskSequenceDeployments
}

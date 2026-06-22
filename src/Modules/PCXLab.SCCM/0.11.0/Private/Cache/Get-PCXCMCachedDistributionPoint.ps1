function Get-PCXCMCachedDistributionPoint {

    [CmdletBinding()]
    param(
        [switch]$ForceRefresh,

        [int]$ExpiresHours = 24
    )

    Initialize-PCXCMRuntimeCache

    if (
        -not $ForceRefresh -and
        $null -ne $Global:PCXCMRuntimeCache.DistributionPoints
    ) {
        return $Global:PCXCMRuntimeCache.DistributionPoints
    }

    $CacheName = 'DistributionPoints'

    if (
        -not $ForceRefresh -and
        (Test-PCXCMCacheExists -Name $CacheName) -and
        (-not (Test-PCXCMCacheExpired -Name $CacheName))
    ) {

        $CacheStatus = Get-PCXCMCacheStatus -Name $CacheName

        Write-PCXLog -Message "Using cached distribution points. Age=$($CacheStatus.AgeHours)h"

        $CachedData = Get-PCXCMCache -Name $CacheName

        $Global:PCXCMRuntimeCache.DistributionPoints = $CachedData

        return $CachedData
    }

    Write-PCXLog -Message "Refreshing distribution points cache"

    Ensure-PCXCMConnection

    $ResultDistributionPoints = @(Get-CMDistributionPoint | Select-Object *, @{
        Name       = 'IsCloud'
        Expression = { $_.NALType -eq 'Windows Azure' }
    })

    Save-PCXCMCache -Name $CacheName -Data $ResultDistributionPoints -ExpiresHours $ExpiresHours

    $Global:PCXCMRuntimeCache.DistributionPoints = $ResultDistributionPoints

    return $ResultDistributionPoints
}
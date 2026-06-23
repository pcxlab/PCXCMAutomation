function Get-PCXCMCachedDistributionPointGroup {

    [CmdletBinding()]
    param(
        [switch]$ForceRefresh,

        [int]$ExpiresHours = 24
    )

    Initialize-PCXCMRuntimeCache

    if (
        -not $ForceRefresh -and
        $null -ne $Global:PCXCMRuntimeCache.DistributionPointGroups
    ) {
        return $Global:PCXCMRuntimeCache.DistributionPointGroups
    }

    $CacheName = 'DistributionPointGroups'

    if (
        -not $ForceRefresh -and
        (Test-PCXCMCacheExists -Name $CacheName) -and
        (-not (Test-PCXCMCacheExpired -Name $CacheName))
    ) {

        $CacheStatus = Get-PCXCMCacheStatus -Name $CacheName

        Write-PCXLog `
            -Message "Using cached distribution point groups. Age=$($CacheStatus.AgeHours)h"

        $CachedData = Get-PCXCMCache -Name $CacheName

        $Global:PCXCMRuntimeCache.DistributionPointGroups = $CachedData

        return $CachedData
    }

    Write-PCXLog -Message "Refreshing distribution point groups cache"

    Ensure-PCXCMConnection

    $ResultDistributionPointGroups = Get-CMDistributionPointGroup

    if ($null -eq $ResultDistributionPointGroups) {
        $ResultDistributionPointGroups = @()
    }

    if ($ResultDistributionPointGroups.Count -eq 0) {
        Write-PCXLog -Message "No Distribution Point Groups found in SCCM environment."
    }

    Save-PCXCMCache `
        -Name $CacheName `
        -Data $ResultDistributionPointGroups `
        -ExpiresHours $ExpiresHours

    $Global:PCXCMRuntimeCache.DistributionPointGroups = $ResultDistributionPointGroups

    return $ResultDistributionPointGroups
}
function Get-PCXCMCachedCloudManagementGateways {

    [CmdletBinding()]
    param(
        [switch]$ForceRefresh,

        [int]$ExpiresHours = 24
    ) 

    Initialize-PCXCMRuntimeCache

    if (
        -not $ForceRefresh -and
        $null -ne $Global:PCXCMRuntimeCache.CloudManagementGateways
    ) {
        return $Global:PCXCMRuntimeCache.CloudManagementGateways
    }

    $CacheName = 'CloudManagementGateways'

    if (
        -not $ForceRefresh -and
        (Test-PCXCMCacheExists -Name $CacheName) -and
        (-not (Test-PCXCMCacheExpired -Name $CacheName))
    ) {

        $CacheStatus = Get-PCXCMCacheStatus -Name $CacheName

        Write-PCXLog -Message "Using cached cloud management gateways. Age=$($CacheStatus.AgeHours)h"

        $CachedData = Get-PCXCMCache -Name $CacheName

        $Global:PCXCMRuntimeCache.CloudManagementGateways = $CachedData

        return $CachedData
    }

    Write-PCXLog -Message 'Refreshing cloud management gateways cache'

    if (-not (Get-Command Get-CMCloudManagementGateway -ErrorAction SilentlyContinue)) {

        Write-PCXLog -Message 'Get-CMCloudManagementGateway command not available' -Level Warning

        $ResultCloudManagementGateways = @()

        Save-PCXCMCache -Name $CacheName -Data $ResultCloudManagementGateways -ExpiresHours $ExpiresHours

        $Global:PCXCMRuntimeCache.CloudManagementGateways = $ResultCloudManagementGateways

        return $ResultCloudManagementGateways
    }

    try {

        Ensure-PCXCMConnection

        $ResultCloudManagementGateways = @(Get-CMCloudManagementGateway)

        if ($ResultCloudManagementGateways.Count -eq 0) {
            Write-PCXLog -Message 'No Cloud Management Gateways found in SCCM environment.'
        }

        Save-PCXCMCache -Name $CacheName -Data $ResultCloudManagementGateways -ExpiresHours $ExpiresHours

        $Global:PCXCMRuntimeCache.CloudManagementGateways = $ResultCloudManagementGateways

        return $ResultCloudManagementGateways
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level Warning

        $ResultCloudManagementGateways = @()

        Save-PCXCMCache -Name $CacheName -Data $ResultCloudManagementGateways -ExpiresHours $ExpiresHours

        $Global:PCXCMRuntimeCache.CloudManagementGateways = $ResultCloudManagementGateways

        return $ResultCloudManagementGateways
    }
}
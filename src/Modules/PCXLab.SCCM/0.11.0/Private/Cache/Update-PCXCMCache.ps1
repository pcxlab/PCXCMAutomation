function Update-PCXCMCache {

    [CmdletBinding()]
    param(
        [int]$ExpiresHours = 24
    )

    try {

        Write-PCXLog `
            -Message 'Starting cache refresh'

        $null = Get-PCXCMCachedCollection `
            -ForceRefresh `
            -ExpiresHours $ExpiresHours

        $null = Get-PCXCMCachedDeployment `
            -ForceRefresh `
            -ExpiresHours $ExpiresHours

        $null = Get-PCXCMCachedApplication `
            -ForceRefresh `
            -ExpiresHours $ExpiresHours

        $null = Get-PCXCMCachedPackage `
            -ForceRefresh `
            -ExpiresHours $ExpiresHours

        $null = Get-PCXCMCachedTaskSequence `
            -ForceRefresh `
            -ExpiresHours $ExpiresHours

        $null = Get-PCXCMCachedTaskSequenceDeployment `
            -ForceRefresh `
            -ExpiresHours $ExpiresHours

        $null = Get-PCXCMCachedDistributionStatus `
            -ForceRefresh `
            -ExpiresHours $ExpiresHours

        Write-PCXLog `
            -Message 'Cache refresh completed'

        Get-PCXCMCacheStatus
    }
    catch {

        Write-PCXLog `
            -Message $_.Exception.Message `
            -Level ERROR

        throw
    }
}

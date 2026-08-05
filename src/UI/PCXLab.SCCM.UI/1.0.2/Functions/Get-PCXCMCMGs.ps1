function Get-PCXCMCMGs {

    [CmdletBinding()]
    param(
        [switch]$ForceRefresh
    )

    try {

        $CMGData = @()

        if (Get-Command Get-PCXCMCachedCloudManagementGateways -ErrorAction SilentlyContinue) {

            $CMGData = @(Get-PCXCMCachedCloudManagementGateways -ForceRefresh:$ForceRefresh -ErrorAction SilentlyContinue)
        }

        if ($CMGData.Count -gt 0) {

            $Names = @()

            foreach ($CMG in $CMGData) {

                if ($CMG.ServiceCName) {
                    $Names += $CMG.ServiceCName
                }
                elseif ($CMG.Fqdn) {
                    $Names += $CMG.Fqdn
                }
                elseif ($CMG.Name) {
                    $Names += $CMG.Name
                }
            }

            if ($Names.Count -gt 0) {
                return $Names | Sort-Object -Unique
            }
        }
    }
    catch {
        Write-Warning "Failed to query CMGs: $($_.Exception.Message)"
    }

    $EnableFallback = Get-PCXCMSetting -Name EnableFallbackData

    if ($EnableFallback) {

        $FallbackCloudManagementGateways = @(Get-PCXCMSetting -Name FallbackCloudManagementGateways)

        if ($FallbackCloudManagementGateways.Count -gt 0) {

            Write-PCXLog -Message 'Using configured fallback Cloud Management Gateways' -Level Warning

            return $FallbackCloudManagementGateways
        }
    }

    return @()
}
function Get-PCXCMDPs {

    [CmdletBinding()]
    param(
        [switch]$ForceRefresh
    )

    try {

        $DPData = $null

        # Prefer cached module function
        if (Get-Command Get-PCXCMCachedDistributionPoint -ErrorAction SilentlyContinue) {
            $DPData = Get-PCXCMCachedDistributionPoint -ForceRefresh:$ForceRefresh -ErrorAction SilentlyContinue
        }

        # Fallback to direct SCCM query if cache is empty or function missing
        if (-not $DPData -and (Get-Module -Name "ConfigurationManager")) {
            $DPData = Get-CMDistributionPoint -ErrorAction SilentlyContinue
        }

        # Exclude Cloud Distribution Points (CMGs)
        <#
        if ($DPData) {
            $DPData = $DPData | Where-Object { -not $_.IsCloud }
        }
        #>

        # Exclude Cloud Distribution Points (CMGs) and MCC-enabled DPs
        if ($DPData) {
            $DPData = $DPData | Where-Object {
                -not $_.IsCloud -and
                (
                    -not $_.EmbeddedProperties.ContainsKey("DoincEnabled") -or
                    $_.EmbeddedProperties["DoincEnabled"].Value -ne 1
                )
            }
        }

        if ($DPData) {

            $Names = @()

            foreach ($DP in $DPData) {

                if ($DP.NetworkOSPath) {
                    $Names += $DP.NetworkOSPath.TrimStart('\')
                }
                elseif ($DP.NetworkName) {
                    $Names += $DP.NetworkName
                }
                elseif ($DP.ServerName) {
                    $Names += $DP.ServerName
                }
                elseif ($DP.Name) {
                    $Names += $DP.Name
                }
            }

            if ($Names.Count -gt 0) {
                return $Names | Sort-Object -Unique
            }
        }
    }
    catch {
        Write-Warning "Failed to query DPs: $($_.Exception.Message)"
    }

    $EnableFallback = Get-PCXCMSetting -Name EnableFallbackData

    if ($EnableFallback) {

        $FallbackDistributionPoints = @(Get-PCXCMSetting -Name FallbackDistributionPoints)

        if ($FallbackDistributionPoints.Count -gt 0) {

            Write-PCXLog -Message 'Using configured fallback Distribution Points' -Level Warning

            return $FallbackDistributionPoints
        }
    }

    return @()
}

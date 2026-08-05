class SCCMService {

    hidden [string[]] ResolveTargets(
        [string[]]$SCCMTargets,
        [string[]]$FallbackTargets,
        [string]$FallbackMode
    ) {
        # TODO:
        # Disabled
        # Automatic
        # Force
        # Merge

        return @()
    }

    [string[]] GetDistributionPoints([bool]$forceRefresh) {

        $dpData = $null

        if (Get-Command Get-PCXCMCachedDistributionPoint -ErrorAction SilentlyContinue) {
            $dpData = Get-PCXCMCachedDistributionPoint -ForceRefresh:$forceRefresh -ErrorAction SilentlyContinue
        }

        if (-not $dpData -and (Get-Module -Name "ConfigurationManager")) {
            $dpData = Get-CMDistributionPoint -ErrorAction SilentlyContinue
        }

        # Exclude Cloud Distribution Points (CMGs) and MCC-enabled DPs
        if ($dpData) {
            $dpData = $dpData | Where-Object {
                -not $_.IsCloud -and
                (
                    -not $_.EmbeddedProperties.ContainsKey("DoincEnabled") -or
                    $_.EmbeddedProperties["DoincEnabled"].Value -ne 1
                )
            }
        }

        $names = @()

        if ($dpData) {
            foreach ($dp in $dpData) {
                if ($dp.NetworkOSPath) {
                    $names += $dp.NetworkOSPath.TrimStart('\')
                }
                elseif ($dp.NetworkName) {
                    $names += $dp.NetworkName
                }
                elseif ($dp.ServerName) {
                    $names += $dp.ServerName
                }
                elseif ($dp.Name) {
                    $names += $dp.Name
                }
            }

            $names = $names | Sort-Object -Unique
        }

        $fallbackMode = [Settings]::GetFallbackMode("DistributionPoints")
        $fallbackTargets = [Settings]::GetFallbackTargets("DistributionPoints")

        return $this.ResolveTargets(
            $names,
            $fallbackTargets,
            $fallbackMode
        )
    }

    [string[]] GetDistributionPointGroups([bool]$forceRefresh) {

        $groupData = $null

        if (Get-Command Get-PCXCMCachedDistributionPointGroup -ErrorAction SilentlyContinue) {
            $groupData = Get-PCXCMCachedDistributionPointGroup -ForceRefresh:$forceRefresh -ErrorAction SilentlyContinue
        }

        if ($null -eq $groupData -and (Get-Module -Name "ConfigurationManager")) {
            $groupData = Get-CMDistributionPointGroup -ErrorAction SilentlyContinue
        }

        $names = @()

        if ($groupData) {
            foreach ($group in $groupData) {
                if ($group.Name) {
                    $names += $group.Name
                }
            }

            $names = $names | Sort-Object -Unique
        }

        $fallbackMode = [Settings]::GetFallbackMode("DistributionPointGroups")
        $fallbackTargets = [Settings]::GetFallbackTargets("DistributionPointGroups")

        return $this.ResolveTargets(
            $names,
            $fallbackTargets,
            $fallbackMode
        )
    }

    [string[]] GetCloudManagementGateways([bool]$forceRefresh) {

        $cmgData = @()

        if (Get-Command Get-PCXCMCachedCloudManagementGateways -ErrorAction SilentlyContinue) {
            $cmgData = @(Get-PCXCMCachedCloudManagementGateways -ForceRefresh:$forceRefresh -ErrorAction SilentlyContinue)
        }

        $names = @()

        if ($cmgData.Count -gt 0) {
            foreach ($cmg in $cmgData) {
                if ($cmg.ServiceCName) {
                    $names += $cmg.ServiceCName
                }
                elseif ($cmg.Fqdn) {
                    $names += $cmg.Fqdn
                }
                elseif ($cmg.Name) {
                    $names += $cmg.Name
                }
            }

            $names = $names | Sort-Object -Unique
        }

        $fallbackMode = [Settings]::GetFallbackMode("CloudManagementGateways")
        $fallbackTargets = [Settings]::GetFallbackTargets("CloudManagementGateways")

        return $this.ResolveTargets(
            $names,
            $fallbackTargets,
            $fallbackMode
        )
    }

    # CreateApplication()
    # CreatePackage()
    # (No changes required)
}
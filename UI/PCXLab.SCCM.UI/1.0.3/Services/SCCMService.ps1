class SCCMService {
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

        if ($dpData) {
            $names = @()
            foreach ($dp in $dpData) {
                if ($dp.NetworkOSPath) { $names += $dp.NetworkOSPath.TrimStart('\') }
                elseif ($dp.NetworkName) { $names += $dp.NetworkName }
                elseif ($dp.ServerName) { $names += $dp.ServerName }
                elseif ($dp.Name) { $names += $dp.Name }
            }
            if ($names.Count -gt 0) {
                return $names | Sort-Object -Unique
            }
        }

        if ([Settings]::EnableFallbackData()) {
            $fallback = @([Settings]::GetSetting("FallbackDistributionPoints"))
            if ($fallback.Count -gt 0) {
                [Logger]::Log("Using configured fallback Distribution Points", "WARNING")
                return $fallback
            }
        }

        return @()
    }

    [string[]] GetDistributionPointGroups([bool]$forceRefresh) {
        $groupData = $null
        if (Get-Command Get-PCXCMCachedDistributionPointGroup -ErrorAction SilentlyContinue) {
            $groupData = Get-PCXCMCachedDistributionPointGroup -ForceRefresh:$forceRefresh -ErrorAction SilentlyContinue
        }
        
        if ($null -eq $groupData -and (Get-Module -Name "ConfigurationManager")) {
            $groupData = Get-CMDistributionPointGroup -ErrorAction SilentlyContinue
        }

        if ($groupData) {
            $names = @()
            foreach ($group in $groupData) {
                if ($group.Name) { $names += $group.Name }
            }
            if ($names.Count -gt 0) {
                return $names | Sort-Object -Unique
            }
        }

        if ([Settings]::EnableFallbackData()) {
            $fallback = @([Settings]::GetSetting("FallbackDistributionPointGroups"))
            if ($fallback.Count -gt 0) {
                [Logger]::Log("Using configured fallback Distribution Point Groups", "WARNING")
                return $fallback
            }
        }

        return @()
    }

    [string[]] GetCloudManagementGateways([bool]$forceRefresh) {
        $cmgData = @()
        if (Get-Command Get-PCXCMCachedCloudManagementGateways -ErrorAction SilentlyContinue) {
            $cmgData = @(Get-PCXCMCachedCloudManagementGateways -ForceRefresh:$forceRefresh -ErrorAction SilentlyContinue)
        }

        if ($cmgData.Count -gt 0) {
            $names = @()
            foreach ($cmg in $cmgData) {
                if ($cmg.ServiceCName) { $names += $cmg.ServiceCName }
                elseif ($cmg.Fqdn) { $names += $cmg.Fqdn }
                elseif ($cmg.Name) { $names += $cmg.Name }
            }
            if ($names.Count -gt 0) {
                return $names | Sort-Object -Unique
            }
        }

        if ([Settings]::EnableFallbackData()) {
            $fallback = @([Settings]::GetSetting("FallbackCloudManagementGateways"))
            if ($fallback.Count -gt 0) {
                [Logger]::Log("Using configured fallback Cloud Management Gateways", "WARNING")
                return $fallback
            }
        }

        return @()
    }

    [void] CreateApplication([DeploymentRequest]$request) {
        $params = @{
            Path            = $request.Path
            ReferenceNumber = $request.ReferenceNumber
            ReviewerName    = $request.ReviewerName
            Comment         = $request.Comment
        }
        if ($request.DistributionPointGroups.Count -gt 0) {
            $params["DistributionPointGroups"] = $request.DistributionPointGroups
        }
        if ($request.DistributionPoints.Count -gt 0) {
            $params["DistributionPoints"] = $request.DistributionPoints
        }

        Create-PCXCMApplication @params
    }

    [void] CreatePackage([DeploymentRequest]$request) {
        $params = @{
            Path            = $request.Path
            ReferenceNumber = $request.ReferenceNumber
            ReviewerName    = $request.ReviewerName
            Comment         = $request.Comment
        }
        if ($request.DistributionPointGroups.Count -gt 0) {
            $params["DistributionPointGroups"] = $request.DistributionPointGroups
        }
        if ($request.DistributionPoints.Count -gt 0) {
            $params["DistributionPoints"] = $request.DistributionPoints
        }

        Create-PCXCMPackage @params
    }
}

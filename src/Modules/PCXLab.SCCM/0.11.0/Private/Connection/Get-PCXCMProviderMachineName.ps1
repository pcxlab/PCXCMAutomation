function Get-PCXCMProviderMachineName {
    [CmdletBinding()]
    param ()

    if ($script:PCXCMProviderMachineName) {
        return $script:PCXCMProviderMachineName
    }

    try {
        $namespace = "root\SMS"
        $siteClass = Get-CimInstance -Namespace $namespace -ClassName SMS_ProviderLocation -ErrorAction Stop |
                     Where-Object { $_.ProviderForLocalSite -eq $true }

        if ($null -eq $siteClass) {
            # Fallback to any provider if local not explicitly flagged
            $siteClass = Get-CimInstance -Namespace $namespace -ClassName SMS_ProviderLocation -ErrorAction Stop | Select-Object -First 1
        }

        if ($null -eq $siteClass) {
            Write-Error "Could not find an SCCM provider in WMI under namespace '$namespace'."
            return $null
        }

        $script:PCXCMProviderMachineName = $siteClass.Machine
        return $script:PCXCMProviderMachineName
    } catch {
        Write-Error "Error retrieving SCCM provider machine name: $($_.Exception.Message)"
        return $null
    }
}

function Test-PCXCMConnection {
<#
.SYNOPSIS
Tests if Configuration Manager PowerShell connection is available.
#>

    [CmdletBinding()]
    param()

    try {
        $null = Get-PSDrive -PSProvider CMSite -ErrorAction Stop

        return $true
    }
    catch {
        return $false
    }
}


function Resolve-PCXCMPath {
<#
.SYNOPSIS
Resolves a Configuration Manager path to provider format.

.EXAMPLE
Resolve-PCXCMPath -Path "\DeviceCollection\Test"

Returns:
ABC:\DeviceCollection\Test
#>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    try {
        $siteCode = Get-PCXCMSiteDrive

        $cleanPath = $Path.Trim()

        if ($cleanPath -match '^[^\\:]+:\\') {
            $cleanPath = $cleanPath.Substring($cleanPath.IndexOf('\') + 1)
        }

        $cleanPath = $cleanPath.TrimStart('\')

        return "$siteCode`:\$cleanPath"
    }
    catch {
        throw "Path resolution failed. $($_.Exception.Message)"
    }
}



function Get-PCXCMDeviceCollection {
<#
.SYNOPSIS
Gets a Configuration Manager device collection by name.

.DESCRIPTION
Returns the collection object if found.
Returns $null if not found.

.EXAMPLE
Get-PCXCMCollection -Name "All Systems"
#>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    try {
        if (-not (Test-PCXCMConnection)) {
            throw "No active Configuration Manager connection detected."
        }

        $collection = Get-CMDeviceCollection `
            -Name $Name `
            -ErrorAction SilentlyContinue

        if ($collection) {
            return $collection
        }

        return $null
    }
    catch {
        throw "Failed to get collection '$Name'. $($_.Exception.Message)"
    }
}
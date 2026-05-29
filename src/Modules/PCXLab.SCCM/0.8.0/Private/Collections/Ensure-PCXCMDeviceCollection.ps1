function Ensure-PCXCMDeviceCollection {
<#
.SYNOPSIS
Ensures a device collection exists.

.DESCRIPTION
If the collection exists, returns it.
If not, creates it and returns the new collection.

.EXAMPLE
Ensure-PCXCMDeviceCollection `
    -Name "PCX - Test" `
    -LimitingCollection "All Systems"
#>

    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$LimitingCollection = "All Systems"
    )

    try {
        if (-not (Test-PCXCMConnection)) {
            throw "No active Configuration Manager connection detected."
        }

        $existing = Get-PCXCMCollection -Name $Name

        if ($existing) {
            Write-PCXMessage `
                -Type Warning `
                -Message "Collection '$Name' already exists."

            return $existing
        }

        if ($PSCmdlet.ShouldProcess($Name, "Create device collection")) {

            New-CMDeviceCollection `
                -Name $Name `
                -LimitingCollectionName $LimitingCollection `
                -ErrorAction Stop | Out-Null

            Write-PCXMessage `
                -Type Success `
                -Message "Collection '$Name' created successfully."

            return Get-PCXCMCollection -Name $Name
        }
    }
    catch {
        throw "Failed to ensure collection '$Name'. $($_.Exception.Message)"
    }
}
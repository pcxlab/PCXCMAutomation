function Ensure-PCXCMDeviceCollection {
   
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
        Ensure-PCXCMConnection

        $existing = Get-PCXCMDeviceCollection -Name $Name

        if ($existing) {
            Write-PCXMessage -Type Warning -Message "Collection '$Name' already exists."
            return $existing
        }

        if ($PSCmdlet.ShouldProcess($Name, "Create device collection")) {
            $null = New-CMDeviceCollection -Name $Name -LimitingCollectionName $LimitingCollection -ErrorAction Stop
            Write-PCXMessage -Type Success -Message "Collection '$Name' created successfully."
            return Get-PCXCMDeviceCollection -Name $Name
        }
    }
    catch {
        throw "Failed to ensure collection '$Name'. $($_.Exception.Message)"
    }
}

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



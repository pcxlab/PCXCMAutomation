function Get-PCXCMDeviceCollection {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    begin {
        Write-PCXOperationStart
    }
    process {
        try {
            Ensure-PCXCMConnection
            $Collection = Get-PCXCMCachedCollection | Where-Object Name -eq $Name | Select-Object -First 1

            if ($Collection) {
                Write-PCXLog "Device collection found: $Name"
                return $Collection
            }
            Write-PCXLog "Device collection not found: $Name"
            return $null
        }
        catch {
            Write-PCXLog -Message "Failed to get device collection: $Name. $_" -Level ERROR
            throw
        }
    }
    end {
        Write-PCXOperationEnd -Status Success
    }
}

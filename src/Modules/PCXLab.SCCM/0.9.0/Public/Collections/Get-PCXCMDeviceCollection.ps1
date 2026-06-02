function Get-PCXCMDeviceCollection {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    begin {
        Write-PCXLog "BEGIN - PCXLab Automation"
    }
    process {
        try {
            if (-not (Test-PCXCMConnection)) {
                throw "No active Configuration Manager connection detected."
            }

            $Collection = Get-CMDeviceCollection -Name $Name -ErrorAction SilentlyContinue

            if ($Collection) {
                Write-PCXLog "Device collection found: $Name"
                return $Collection
            }
            Write-PCXLog "Device collection not found: $Name"
            return $null
        }
        catch {
            Write-PCXLog "Failed to get device collection: $Name. $_"
            throw
        }
        finally {
            Write-PCXLog "Get device collection operation completed: $Name"
        }
    }
    end {
        Write-PCXLog "END - www.pcxlab.com"
    }
}
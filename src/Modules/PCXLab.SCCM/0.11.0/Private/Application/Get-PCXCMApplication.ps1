function Get-PCXCMApplication {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ApplicationName
    )

    begin {
        Write-PCXOperationStart
    }
    process {
        try {
            Ensure-PCXCMConnection

            # -Fast - should not be used here. it fails to get xml beucase its part of lazy properties
            $Application = Get-CMApplication -Name $ApplicationName -ErrorAction Stop

            if (-not $Application) {
                throw "Application not found: $ApplicationName"
            }

            return $Application
        }
        catch {
            Write-PCXLog -Message "Failed to get application: $ApplicationName. $($_.Exception.Message)" -Level ERROR
            throw
        }
    }
    end {
        Write-PCXOperationEnd -Status Success
    }
}
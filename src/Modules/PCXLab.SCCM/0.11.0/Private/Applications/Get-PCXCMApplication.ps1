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
            $Application = Get-CMApplication -Name $ApplicationName -ErrorAction SilentlyContinue

            if (-not $Application) {
                throw "Application not found: $ApplicationName"
            }

            return $Application
        }
        catch {
            Write-PCXLog "Failed to get application: $ApplicationName. $($_.Exception.Message)" "ERROR"
            throw
        }
        
    }
    end {

        Write-PCXOperationEnd -Status Success
    }
}




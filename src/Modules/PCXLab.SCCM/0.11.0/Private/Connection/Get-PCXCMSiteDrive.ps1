function Get-PCXCMSiteDrive {
<#
.SYNOPSIS
Returns the active Configuration Manager site drive.
#>

    [CmdletBinding()]
    param()

    begin {
        Write-Verbose "PCXLab - Starting Get-PCXCMSiteDrive"
    }

    process {
        try {
            # Import module if needed
            if (-not (Get-Module ConfigurationManager)) {

                Write-Verbose "PCXLab - Importing ConfigurationManager module"

                Import-Module `
                    "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" `
                    -ErrorAction Stop
            }

            # Get CMSite drive
            $drive = Get-PSDrive `
                -PSProvider CMSite `
                -ErrorAction Stop |
                Select-Object -First 1

            if (-not $drive) {
                throw "No CMSite drive connected."
            }

            Write-Verbose "PCXLab - Site drive detected: $($drive.Name)"

            return $drive.Name
        }
        catch {
            throw "Unable to detect Configuration Manager site drive. $($_.Exception.Message)"
        }
        finally {
            Write-Verbose "PCXLab - Get-PCXCMSiteDrive process completed"
        }
    }

    end {
        Write-Verbose "PCXLab - Finished Get-PCXCMSiteDrive"
    }
}


function Connect-PCXCMSite {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$SiteCode = $(Get-PCXCMSiteCode),

        [Parameter(Mandatory = $false)]
        [string]$ProviderMachineName = $(Get-PCXCMProviderMachineName)
    )

    begin {
        Write-Verbose "PCXLab - Starting Connect-PCXCMSite"
    }

    process {
        try {
            # Import Configuration Manager module
            if (-not (Get-Module ConfigurationManager)) {

                Write-Verbose "PCXLab - Importing ConfigurationManager module"

                Import-Module `
                    "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" `
                    -ErrorAction Stop
            }

            # Create PSDrive if missing
            $existingDrive = Get-PSDrive `
                -Name $SiteCode `
                -PSProvider CMSite `
                -ErrorAction SilentlyContinue

            if (-not $existingDrive) {

                Write-Verbose "PCXLab - Creating CMSite drive $SiteCode"

                New-PSDrive `
                    -Name $SiteCode `
                    -PSProvider CMSite `
                    -Root $ProviderMachineName `
                    -ErrorAction Stop | Out-Null
            }

            # Set location to site drive
            Set-Location "${SiteCode}:\"

            Write-Verbose "PCXLab - Connected to site drive ${SiteCode}:"

            [pscustomobject]@{
                Success             = $true
                SiteCode            = $SiteCode
                ProviderMachineName = $ProviderMachineName
                Location            = "${SiteCode}:\"
                Timestamp           = Get-Date
            }
        }
        catch {
            throw "Failed to connect to Configuration Manager site. $($_.Exception.Message)"
        }
        finally {
            Write-Verbose "PCXLab - Connect-PCXCMSite process completed"
        }
    }

    end {
        Write-Verbose "PCXLab - Finished Connect-PCXCMSite"
    }
}

<#
.SYNOPSIS
Imports the Configuration Manager module, connects to the CMSite drive,
and sets the current location to the site drive.

.DESCRIPTION
This function loads the Microsoft Configuration Manager PowerShell module
(if not already loaded), creates the CMSite PSDrive if required, and
switches the current location into the site drive.

.PARAMETER SiteCode
Configuration Manager site code.
Example: ABC

.PARAMETER ProviderMachineName
Primary site server / SMS Provider machine name.

.EXAMPLE
Connect-PCXCMSite -SiteCode ABC -ProviderMachineName CM01

.NOTES
PCXLab Automation Framework
#>

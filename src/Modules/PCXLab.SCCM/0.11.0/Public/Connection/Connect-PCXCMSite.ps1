function Connect-PCXCMSite {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory = $false)]
        [string]$SiteCode = $(Get-PCXCMSiteCode),

        [Parameter(Mandatory = $false)]
        [string]$ProviderMachineName = $(Get-PCXCMProviderMachineName)
    )

    begin {

        $OperationSucceeded = $true

        Write-PCXOperationStart
    }

    process {

        try {

            # Import Configuration Manager module
            if (-not (Get-Module ConfigurationManager)) {

                Write-Verbose "PCXLab - Importing ConfigurationManager module"

                $CMModulePath = Join-Path `
                    (Split-Path $ENV:SMS_ADMIN_UI_PATH -Parent) `
                    "ConfigurationManager.psd1"

                Import-Module $CMModulePath -ErrorAction Stop
            }

            # Create PSDrive if missing
            $existingDrive = Get-PSDrive `
                -Name $SiteCode `
                -PSProvider CMSite `
                -ErrorAction SilentlyContinue

            if (-not $existingDrive) {

                Write-Verbose "PCXLab - Creating CMSite drive $SiteCode"

                $null = New-PSDrive `
                    -Name $SiteCode `
                    -PSProvider CMSite `
                    -Root $ProviderMachineName `
                    -ErrorAction Stop
            }

            # Set location to site drive
            Set-Location "${SiteCode}:\"

            Write-Verbose "PCXLab - Connected to site drive ${SiteCode}:"

            [PSCustomObject]@{
                Success             = $true
                SiteCode            = $SiteCode
                ProviderMachineName = $ProviderMachineName
                Location            = "${SiteCode}:\"
                Timestamp           = Get-Date
            }
        }
        catch {

            $OperationSucceeded = $false
Write-PCXLog "Failed to connect to Configuration Manager site. $($_.Exception.Message)" "ERROR"

            throw
        }
    }

    end {

        if ($OperationSucceeded) {

            Write-PCXOperationEnd -Status Success
        }
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




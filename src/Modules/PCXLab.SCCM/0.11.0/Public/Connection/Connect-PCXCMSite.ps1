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

            # Validate SCCM environment
            Initialize-PCXCMEnvironment

            # Verify CMSite provider
            if (-not (Get-PSProvider CMSite -ErrorAction SilentlyContinue)) {
                throw "CMSite provider failed to load."
            }

            # Create CMSite drive if missing
            $ExistingDrive = Get-PSDrive `
                -Name $SiteCode `
                -PSProvider CMSite `
                -ErrorAction SilentlyContinue

            if (-not $ExistingDrive) {

                Write-Verbose "PCXLab - Creating CMSite drive [$SiteCode]."

                $null = New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName -ErrorAction Stop
            }

            # Switch to site drive
            Set-Location "${SiteCode}:\"

            # Verify location change succeeded
            $CurrentLocation = (Get-Location).Path

            if ($CurrentLocation -notlike "$SiteCode*") {
                throw "Failed to switch to SCCM Site Drive."
            }

            # Verify SCCM connectivity
            try {

               $null = Get-CMApplication -Fast | Select-Object -First 1 
            }
            catch {

                throw "Connected to SCCM Site but SCCM query failed. $($_.Exception.Message)"
            }

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

            Write-PCXLog `
                -Message "Failed to connect to Configuration Manager site. $($_.Exception.Message)" `
                -Level ERROR

            throw
        }
    }

    end {

        if ($OperationSucceeded) {
            Write-PCXOperationEnd -Status Success
        }
    }
}
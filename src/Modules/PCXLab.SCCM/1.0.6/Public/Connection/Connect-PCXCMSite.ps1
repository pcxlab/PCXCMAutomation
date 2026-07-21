function Connect-PCXCMSite {

    [CmdletBinding()]
    param(
        [string]$SiteCode,
        [string]$ProviderMachineName
    )

    begin {

        $OperationSucceeded = $true

        Write-PCXOperationStart -OperationName "Connect-PCXCMSite"
    }

    process {

        try {

            #
            # Load Configuration Manager module
            #
            Initialize-PCXCMEnvironment

            #
            # Validate CMSite Provider
            #
            if (-not (Get-PSProvider CMSite -ErrorAction SilentlyContinue)) {
                throw "CMSite PowerShell provider is not available."
            }

            #
            # -----------------------------------------------------------------
            # STEP 1
            # Existing CMSite Drive
            # -----------------------------------------------------------------
            #

            <#
            $CMSiteDrive = Get-PSDrive `
                -PSProvider CMSite `
                -ErrorAction SilentlyContinue |
            Select-Object -First 1
            #>

            $CMSiteDrive = Get-PSDrive `
                -PSProvider CMSite `
                -ErrorAction SilentlyContinue |
            Sort-Object Name |
            Select-Object -First 1

            if ($CMSiteDrive) {

                Write-PCXLog `
                    -Message "Using existing CMSite drive [$($CMSiteDrive.Name)]."

                <#
                $script:PCXCMSiteCode            = $CMSiteDrive.Name
                $script:PCXCMProviderMachineName = $CMSiteDrive.Root
                #>

                Set-PCXCMConnection `
                    -SiteCode $CMSiteDrive.Name `
                    -ProviderMachineName $CMSiteDrive.Root `
                    -DriveName $CMSiteDrive.Name `
                    -DriveRoot $CMSiteDrive.Root `
                    -ConnectionMethod ExistingDrive

                Set-Location "$($CMSiteDrive.Name):\"

                return [PSCustomObject]@{
                    Success             = $true
                    SiteCode            = $CMSiteDrive.Name
                    ProviderMachineName = $CMSiteDrive.Root
                    ConnectionType      = "ExistingDrive"
                    Timestamp           = Get-Date
                }
            }

            #
            # -----------------------------------------------------------------
            # STEP 2
            # Configuration
            # -----------------------------------------------------------------
            #

            if (-not $SiteCode) {

                try {

                    $SiteCode = Get-PCXCMSetting -Name SiteCode

                }
                catch {}
            }

            if (-not $ProviderMachineName) {

                try {

                    $ProviderMachineName = Get-PCXCMSetting -Name ProviderMachineName

                }
                catch {}
            }

            #
            # -----------------------------------------------------------------
            # STEP 3
            # Local SMS Provider
            # Only when values are still unknown.
            # -----------------------------------------------------------------
            #

            if (-not $SiteCode -or -not $ProviderMachineName) {

                try {
                    <#
                    $Provider = Get-CimInstance `
                        -Namespace Root\SMS `
                        -Class SMS_ProviderLocation `
                        -ErrorAction Stop |
                    Where-Object ProviderForLocalSite |
                    Select-Object -First 1

                    if (-not $Provider) {

                        $Provider = Get-CimInstance `
                            -Namespace Root\SMS `
                            -Class SMS_ProviderLocation `
                            -ErrorAction Stop |
                        Select-Object -First 1
                    }
                    #>
                    $Providers = Get-CimInstance `
                        -Namespace Root\SMS `
                        -Class SMS_ProviderLocation `
                        -ErrorAction Stop

                    $Provider = $Providers |
                    Where-Object ProviderForLocalSite |
                    Select-Object -First 1

                    if (-not $Provider) {
                        $Provider = $Providers | Select-Object -First 1
                    }

                    if ($Provider) {

                        if (-not $SiteCode) {

                            $SiteCode = $Provider.SiteCode
                        }

                        if (-not $ProviderMachineName) {

                            $ProviderMachineName = $Provider.Machine
                        }
                    }

                }
                catch {

                    Write-PCXLog `
                        -Message "Local SMS Provider not available. Using configured connection." `
                        -Level Warning
                }
            }

            #
            # Validate
            #
            if (-not $SiteCode) {

                throw "Unable to determine SCCM Site Code."
            }

            if (-not $ProviderMachineName) {

                throw "Unable to determine SCCM Provider Machine."
            }

            #
            # -----------------------------------------------------------------
            # STEP 4
            # Create CMSite Drive
            # -----------------------------------------------------------------
            #

            $ExistingDrive = Get-PSDrive `
                -Name $SiteCode `
                -PSProvider CMSite `
                -ErrorAction SilentlyContinue

            if (-not $ExistingDrive) {

                Write-PCXLog `
                    -Message "Creating CMSite drive [$SiteCode] using provider [$ProviderMachineName]."

                $null = New-PSDrive `
                    -Name $SiteCode `
                    -PSProvider CMSite `
                    -Root $ProviderMachineName `
                    -ErrorAction Stop
            }

            Set-Location "$SiteCode`:\"

            if ((Get-Location).Drive.Name -ne $SiteCode) {
                throw "Failed to switch to CMSite drive [$SiteCode]."
            }


            #
            # Verify
            #
            $null = Get-CMSite `
                -SiteCode $SiteCode `
                -ErrorAction Stop

            #
            # Cache
            <#
            $script:PCXCMSiteCode = $SiteCode
            $script:PCXCMProviderMachineName = $ProviderMachineName
            #>

            Set-PCXCMConnection `
                -SiteCode $SiteCode `
                -ProviderMachineName $ProviderMachineName `
                -DriveName $SiteCode `
                -DriveRoot $ProviderMachineName `
                -ConnectionMethod NewConnection

            [PSCustomObject]@{

                Success             = $true
                SiteCode            = $SiteCode
                ProviderMachineName = $ProviderMachineName
                ConnectionType      = "NewConnection"
                Timestamp           = Get-Date
            }

        }
        catch {

            $OperationSucceeded = $false

            Write-PCXLog `
                -Message $_.Exception.Message `
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
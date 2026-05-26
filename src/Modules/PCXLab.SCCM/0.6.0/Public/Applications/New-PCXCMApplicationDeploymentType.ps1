function New-PCXCMApplicationDeploymentType {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$InstallationFileLocation
    )

    begin {

        Write-PCXLog "Starting deployment type creation"
    }

    process {

        try {

            # ==========================================================
            # VALIDATE INSTALLER
            # ==========================================================

            if (-not (Test-Path $InstallationFileLocation)) {

                throw "Installer file not found: $InstallationFileLocation"
            }

            # ==========================================================
            # DETECT INSTALLER TYPE
            # ==========================================================

            $extension = [System.IO.Path]::GetExtension(
                $InstallationFileLocation
            ).ToLower()

            $fileName = Split-Path `
                -Path $InstallationFileLocation `
                -Leaf

            $contentLocation = Split-Path `
                -Path $InstallationFileLocation `
                -Parent

            Write-PCXLog "Creating deployment type for: $Name"
            Write-PCXLog "Installer Type: $extension"
            Write-PCXLog "Installer File: $fileName"

            # ==========================================================
            # MSI DEPLOYMENT TYPE
            # ==========================================================

            switch ($extension) {

                ".msi" {

                    Add-CMMsiDeploymentType `
                        -ApplicationName $Name `
                        -DeploymentTypeName "$Name DT" `
                        -InstallationFileLocation $InstallationFileLocation `
                        -ForceForUnknownPublisher `
                        -ErrorAction Stop

                    Write-PCXLog "MSI Deployment Type created"
                }

                # ======================================================
                # EXE DEPLOYMENT TYPE
                # ======================================================

                ".exe" {

                    Add-CMScriptDeploymentType `
                        -ApplicationName $Name `
                        -DeploymentTypeName "$Name DT" `
                        -InstallCommand "$fileName /S" `
                        -ContentLocation $contentLocation `
                        -InstallationBehaviorType InstallForSystem `
                        -LogonRequirementType WhetherOrNotUserLoggedOn `
                        -RequireUserInteraction $false `
                        -ErrorAction Stop

                    Write-PCXLog "EXE Deployment Type created"
                }

                # ======================================================
                # UNSUPPORTED
                # ======================================================

                default {

                    throw "Unsupported installer type: $extension"
                }
            }

            # ==========================================================
            # SUCCESS RESULT
            # ==========================================================

            return [PSCustomObject]@{
                Success                  = $true
                ApplicationName          = $Name
                InstallerType            = $extension
                InstallationFileLocation = $InstallationFileLocation
            }
        }
        catch {

            Write-PCXLog `
                "Deployment type creation failed: $($_.Exception.Message)" `
                "ERROR"

            throw
        }
        finally {

            Write-PCXLog "Deployment type processing completed"
        }
    }

    end {

        Write-PCXLog "Deployment type function completed"
    }
}
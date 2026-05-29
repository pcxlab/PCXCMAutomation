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

            if (-not ([System.IO.File]::Exists($InstallationFileLocation))) {

                throw "Installer file not found: $InstallationFileLocation"
            }

            # ==========================================================
            # INSTALLER OBJECT
            # ==========================================================

            $installerObject = [System.IO.FileInfo]$InstallationFileLocation

            # ==========================================================
            # DETECT INSTALLER TYPE
            # ==========================================================

            $extension = $installerObject.Extension.ToLower()

            $fileName = $installerObject.Name

            $contentLocation = Split-Path `
                -Path $InstallationFileLocation `
                -Parent

            Write-PCXLog "Creating deployment type for: $Name"
            Write-PCXLog "Installer Type: $extension"
            Write-PCXLog "Installer File: $fileName"

            # ==========================================================
            # CREATE DETECTION CLAUSE
            # ==========================================================

            $detectionClause = New-PCXDetectionClause `
                -Installer $installerObject

            # ==========================================================
            # CREATE DEPLOYMENT TYPE
            # ==========================================================

            switch ($extension) {

                # ======================================================
                # MSI
                # ======================================================

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
                # EXE
                # ======================================================

                ".exe" {

                    Add-CMScriptDeploymentType `
                        -ApplicationName $Name `
                        -DeploymentTypeName "$Name DT" `
                        -InstallCommand "$fileName /S" `
                        -ContentLocation $contentLocation `
                        -AddDetectionClause $detectionClause `
                        -InstallationBehaviorType InstallForSystem `
                        -LogonRequirementType WhetherOrNotUserLoggedOn `
                        -ErrorAction Stop

                    Write-PCXLog "EXE Deployment Type created"
                }

                # ======================================================
                # BAT
                # ======================================================

                ".bat" {

                    Add-CMScriptDeploymentType `
                        -ApplicationName $Name `
                        -DeploymentTypeName "$Name DT" `
                        -InstallCommand "cmd.exe /c $fileName" `
                        -ContentLocation $contentLocation `
                        -AddDetectionClause $detectionClause `
                        -InstallationBehaviorType InstallForSystem `
                        -LogonRequirementType WhetherOrNotUserLoggedOn `
                        -ErrorAction Stop

                    Write-PCXLog "BAT Deployment Type created"
                }

                # ======================================================
                # CMD
                # ======================================================

                ".cmd" {

                    Add-CMScriptDeploymentType `
                        -ApplicationName $Name `
                        -DeploymentTypeName "$Name DT" `
                        -InstallCommand "cmd.exe /c $fileName" `
                        -ContentLocation $contentLocation `
                        -AddDetectionClause $detectionClause `
                        -InstallationBehaviorType InstallForSystem `
                        -LogonRequirementType WhetherOrNotUserLoggedOn `
                        -ErrorAction Stop

                    Write-PCXLog "CMD Deployment Type created"
                }

                # ======================================================
                # POWERSHELL
                # ======================================================

                ".ps1" {

                    Add-CMScriptDeploymentType `
                        -ApplicationName $Name `
                        -DeploymentTypeName "$Name DT" `
                        -InstallCommand "powershell.exe -ExecutionPolicy Bypass -File `"$fileName`"" `
                        -ContentLocation $contentLocation `
                        -AddDetectionClause $detectionClause `
                        -InstallationBehaviorType InstallForSystem `
                        -LogonRequirementType WhetherOrNotUserLoggedOn `
                        -ErrorAction Stop

                    Write-PCXLog "PowerShell Deployment Type created"
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
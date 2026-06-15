function New-PCXCMApplicationDeploymentType {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$InstallationFileLocation
    )

    begin {
        Write-PCXOperationStart
    }

    process {
        try {
            if (-not ([System.IO.File]::Exists($InstallationFileLocation))) {
                throw "Installer file not found: $InstallationFileLocation"
            }

            $installerObject = [System.IO.FileInfo]$InstallationFileLocation
            $extension = $installerObject.Extension.ToLowerInvariant()
            $fileName = $installerObject.Name
            $contentLocation = $installerObject.DirectoryName

            Write-PCXLog "Creating deployment type for: $Name"
            Write-PCXLog "Installer: $fileName ($extension)"

            $detectionClause = New-PCXCMApplicationDetectionClause -Installer $installerObject

            $CommonParams = @{
                ApplicationName    = $Name
                DeploymentTypeName = "$Name DT"
                ErrorAction        = "Stop"
            }

            switch ($extension) {
                ".msi" {
                    $null = Add-CMMsiDeploymentType @CommonParams `
                        -InstallationFileLocation $InstallationFileLocation `
                        -ForceForUnknownPublisher

                    Write-PCXLog "MSI deployment type created"
                }

                ".exe" {
                    $null = Add-CMScriptDeploymentType @CommonParams `
                        -InstallCommand "$fileName /S" `
                        -ContentLocation $contentLocation `
                        -AddDetectionClause $detectionClause `
                        -InstallationBehaviorType InstallForSystem `
                        -LogonRequirementType WhetherOrNotUserLoggedOn

                    Write-PCXLog "EXE deployment type created"
                }

                ".bat" {
                    $null = Add-CMScriptDeploymentType @CommonParams `
                        -InstallCommand "cmd.exe /c $fileName" `
                        -ContentLocation $contentLocation `
                        -AddDetectionClause $detectionClause `
                        -InstallationBehaviorType InstallForSystem `
                        -LogonRequirementType WhetherOrNotUserLoggedOn

                    Write-PCXLog "BAT deployment type created"
                }

                ".cmd" {
                    $null = Add-CMScriptDeploymentType @CommonParams `
                        -InstallCommand "cmd.exe /c $fileName" `
                        -ContentLocation $contentLocation `
                        -AddDetectionClause $detectionClause `
                        -InstallationBehaviorType InstallForSystem `
                        -LogonRequirementType WhetherOrNotUserLoggedOn

                    Write-PCXLog "CMD deployment type created"
                }

                ".ps1" {
                    $null = Add-CMScriptDeploymentType @CommonParams `
                        -InstallCommand "powershell.exe -ExecutionPolicy Bypass -File `"$fileName`"" `
                        -ContentLocation $contentLocation `
                        -AddDetectionClause $detectionClause `
                        -InstallationBehaviorType InstallForSystem `
                        -LogonRequirementType WhetherOrNotUserLoggedOn

                    Write-PCXLog "PowerShell deployment type created"
                }

                default {
                    throw "Unsupported installer type: $extension"
                }
            }

            return [PSCustomObject]@{
                Success                  = $true
                ApplicationName          = $Name
                InstallerType            = $extension
                InstallationFileLocation = $InstallationFileLocation
            }
        }
        catch {
            Write-PCXLog -Message "Deployment type creation failed for $Name. $($_.Exception.Message)" -Level ERROR
            throw
        }
    }
    end {
        Write-PCXOperationEnd
    }
}



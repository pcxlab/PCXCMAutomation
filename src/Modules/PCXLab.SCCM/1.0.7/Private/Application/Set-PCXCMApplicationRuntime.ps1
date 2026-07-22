function Set-PCXCMApplicationRuntime {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ApplicationName,

        [Parameter(Mandatory)]
        [ValidateRange(1, 1440)]
        [int]$EstimatedRuntimeMins,

        [Parameter(Mandatory)]
        [ValidateRange(1, 1440)]
        [int]$MaximumRuntimeMins
    )

    begin {
        Write-PCXOperationStart
    }

    process {

        try {

            Ensure-PCXCMConnection

            $DeploymentTypes = @(Get-CMDeploymentType -ApplicationName $ApplicationName)

            if (-not $DeploymentTypes) {
                throw "No deployment types found for application: $ApplicationName"
            }

            foreach ($DeploymentType in $DeploymentTypes) {

                $DTName = $DeploymentType.LocalizedDisplayName

                switch ($DeploymentType.Technology) {

                    "Script" {

                        Set-CMScriptDeploymentType `
                            -ApplicationName $ApplicationName `
                            -DeploymentTypeName $DTName `
                            -EstimatedRuntimeMins $EstimatedRuntimeMins `
                            -MaximumRuntimeMins $MaximumRuntimeMins `
                            -ErrorAction Stop

                        break
                    }

                    "MSI" {

                        Set-CMMsiDeploymentType `
                            -ApplicationName $ApplicationName `
                            -DeploymentTypeName $DTName `
                            -EstimatedRuntimeMins $EstimatedRuntimeMins `
                            -MaximumRuntimeMins $MaximumRuntimeMins `
                            -ErrorAction Stop

                        break
                    }

                    default {

                        Write-PCXLog "Skipping unsupported deployment type '$($DeploymentType.Technology)'." -Level WARNING

                    }
                }
            }

            Write-PCXLog "Deployment type runtime updated."

        }
        catch {

            Write-PCXLog -Message "Failed to update deployment type runtime. $($_.Exception.Message)" -Level ERROR
            throw

        }

    }

    end {
        Write-PCXOperationEnd
    }

}
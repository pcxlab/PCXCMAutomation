function Add-PCXCMApplicationOSRequirementToDeploymentType {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ApplicationName,

        [Parameter(Mandatory)]
        $RequirementRule
    )

    begin {
        Write-PCXOperationStart
    }
    process {
        try {
            $Application = Get-PCXCMApplication -ApplicationName $ApplicationName

            if (-not $Application) {
                throw "Application not found: $ApplicationName"
            }

            $DeploymentTypes = @(Get-CMDeploymentType -ApplicationName $ApplicationName)

            if (-not $DeploymentTypes) {
                throw "Deployment type not found for application: $ApplicationName"
            }

            foreach ($DeploymentType in $DeploymentTypes) {
                switch ($DeploymentType.Technology) {
                    'MSI' {
                        Set-CMMsiDeploymentType `
                            -ApplicationName $ApplicationName `
                            -DeploymentTypeName $DeploymentType.LocalizedDisplayName `
                            -AddRequirement $RequirementRule
                    }

                    'Script' {
                        Set-CMScriptDeploymentType `
                            -ApplicationName $ApplicationName `
                            -DeploymentTypeName $DeploymentType.LocalizedDisplayName `
                            -AddRequirement $RequirementRule
                    }
                }
            }
        }
        catch {
            Write-PCXLog -Message "Failed to add OS requirement: $ApplicationName. $($_.Exception.Message)" -Level ERROR
            throw
        }
    }
    end {
        Write-PCXOperationEnd -Status Success
    }
}





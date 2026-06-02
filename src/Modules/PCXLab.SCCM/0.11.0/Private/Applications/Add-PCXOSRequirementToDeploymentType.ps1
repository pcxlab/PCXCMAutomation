function Add-PCXOSRequirementToDeploymentType {

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
            $DeploymentType = Get-CMDeploymentType -ApplicationName $ApplicationName

            if (-not $DeploymentType) {
                throw "Deployment type not found for application: $ApplicationName"
            }

            Set-CMMsiDeploymentType `
                -ApplicationName $ApplicationName `
                -DeploymentTypeName $DeploymentType.LocalizedDisplayName `
                -AddRequirement $RequirementRule
        }
        catch {
            Write-PCXLog "Failed to add OS requirement: $ApplicationName. $($_.Exception.Message)" "ERROR"
            throw
        }
        
    }
    end {

        Write-PCXOperationEnd -Status Success
    }
}




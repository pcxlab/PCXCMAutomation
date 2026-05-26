function Add-PCXOSRequirementToDeploymentType {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ApplicationName,

        [Parameter(Mandatory)]
        $RequirementRule
    )

    try {

        $DeploymentType = Get-CMDeploymentType `
            -ApplicationName $ApplicationName

        if (-not $DeploymentType) {

            throw "Deployment type not found for application: $ApplicationName"
        }

        Set-CMMsiDeploymentType `
            -ApplicationName $ApplicationName `
            -DeploymentTypeName $DeploymentType.LocalizedDisplayName `
            -AddRequirement $RequirementRule

    }
    catch {

        throw $_
    }
}
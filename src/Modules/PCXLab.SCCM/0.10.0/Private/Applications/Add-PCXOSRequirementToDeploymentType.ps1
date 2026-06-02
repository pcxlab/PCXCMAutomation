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
        Write-PCXLog "BEGIN - PCXLab Automation"
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
        finally {
            Write-PCXLog "OS requirement operation completed: $ApplicationName"
        }
    }
    end {
        Write-PCXLog "END - www.pcxlab.com"
    }
}
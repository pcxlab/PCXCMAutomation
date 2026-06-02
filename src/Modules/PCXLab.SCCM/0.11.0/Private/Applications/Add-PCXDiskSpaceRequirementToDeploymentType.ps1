function Add-PCXDiskSpaceRequirementToDeploymentType {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ApplicationName,

        [Parameter(Mandatory)]
        [ValidateRange(1, 2147483647)]
        [int]$MinimumDiskSpaceMB
    )

    begin {

        Write-PCXOperationStart
    }
    process {
        try {
            # CONNECT TO SCCM
            Ensure-PCXCMConnection

            # GET APPLICATION
            $Application = Get-CMApplication -Name $ApplicationName

            if (-not $Application) {
                throw "Application not found: $ApplicationName"
            }

            # ==========================================================
            # GET DEPLOYMENT TYPES
            # ==========================================================

            $DeploymentTypes = Get-CMDeploymentType -ApplicationName $ApplicationName

            if (-not $DeploymentTypes) {
                throw "No deployment type found for application: $ApplicationName"
            }

            # ==========================================================
            # GET GLOBAL CONDITION
            # ==========================================================

            $GlobalCondition = Get-CMGlobalCondition -Name "Disk space"

            if (-not $GlobalCondition) {
                throw "Global condition not found: Disk space"
            }

            # ==========================================================
            # CREATE REQUIREMENT RULE
            # ==========================================================

            $RequirementRule = New-CMRequirementRuleFreeDiskSpaceValue `
                -InputObject $GlobalCondition `
                -PartitionOption System `
                -RuleOperator GreaterEquals `
                -Value1 $MinimumDiskSpaceMB

            # ==========================================================
            # APPLY REQUIREMENT
            # ==========================================================

            foreach ($DeploymentType in $DeploymentTypes) {

                $Technology = $DeploymentType.Technology

                switch ($Technology) {
                    "Script" {
                        Set-CMScriptDeploymentType `
                            -ApplicationName $ApplicationName `
                            -DeploymentTypeName $DeploymentType.LocalizedDisplayName `
                            -AddRequirement $RequirementRule
                    }
                    "MSI" {
                        Set-CMMsiDeploymentType `
                            -ApplicationName $ApplicationName `
                            -DeploymentTypeName $DeploymentType.LocalizedDisplayName `
                            -AddRequirement $RequirementRule
                    }
                    default {
                        throw "Unsupported deployment type technology: $Technology"
                    }
                }
            }

            # ==========================================================
            # RETURN RESULT
            # ==========================================================

            return [PSCustomObject]@{

                Success            = $true
                ApplicationName    = $ApplicationName
                RequirementType    = "DiskSpace"
                MinimumDiskSpaceMB = $MinimumDiskSpaceMB
                DeploymentTypes    = $DeploymentTypes.Count
            }
        }
        catch {
            Write-PCXLog "Failed to add disk space requirement. $($_.Exception.Message)" "ERROR"
throw
        }
    }
    end {
        Write-PCXOperationEnd -Status Success
    }
}




function Add-PCXMemoryRequirementToDeploymentType {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ApplicationName,

        [Parameter(Mandatory)]
        [ValidateRange(1,2147483647)]
        [int]$MinimumMemoryMB
    )

    try {

        # ==========================================================
        # CONNECT TO SCCM
        # ==========================================================

        Connect-PCXCMSite | Out-Null

        # ==========================================================
        # GET APPLICATION
        # ==========================================================

        $Application = Get-CMApplication `
            -Name $ApplicationName

        if (-not $Application) {

            throw "Application not found: $ApplicationName"
        }

        # ==========================================================
        # GET DEPLOYMENT TYPES
        # ==========================================================

        $DeploymentTypes = Get-CMDeploymentType `
            -ApplicationName $ApplicationName

        if (-not $DeploymentTypes) {

            throw "No deployment type found for application: $ApplicationName"
        }

        # ==========================================================
        # GET GLOBAL CONDITION
        # ==========================================================

        $GlobalCondition = Get-CMGlobalCondition `
            -Name "Total physical memory"

        if (-not $GlobalCondition) {

            throw "Global condition not found: Total physical memory"
        }

        # ==========================================================
        # CREATE REQUIREMENT RULE
        # ==========================================================

        $RequirementRule = New-CMRequirementRuleCommonValue `
            -InputObject $GlobalCondition `
            -RuleOperator GreaterEquals `
            -Value1 "$MinimumMemoryMB"

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
            RequirementType    = "Memory"
            MinimumMemoryMB    = $MinimumMemoryMB
            DeploymentTypes    = $DeploymentTypes.Count
        }
    }

    catch {

        throw "Failed to add memory requirement. $($_.Exception.Message)"
    }
}
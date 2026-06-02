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
        Write-PCXLog "BEGIN - PCXLab Automation"
    }
    process {
        try {
            # ==========================================================
            # CONNECT TO SCCM
            # ==========================================================

            $null = Connect-PCXCMSite

            # ==========================================================
            # GET APPLICATION
            # ==========================================================

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

            throw "Failed to add disk space requirement. $($_.Exception.Message)"
        }
        finally {
            Write-PCXLog "Disk space requirement operation completed: $ApplicationName"
        }
    }
    end {
        Write-PCXLog "END - www.pcxlab.com"
    }
}
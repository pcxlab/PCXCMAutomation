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
            Ensure-PCXCMConnection

            $Application = Get-CMApplication -Name $ApplicationName -Fast
            if (-not $Application) {
                throw "Application not found: $ApplicationName"
            }

            $DeploymentTypes = Get-CMDeploymentType -ApplicationName $ApplicationName
            if (-not $DeploymentTypes) {
                throw "No deployment type found for application: $ApplicationName"
            }

            $GlobalCondition = Get-CMGlobalCondition -Name "Disk space"
            if (-not $GlobalCondition) {
                throw "Global condition not found: Disk space"
            }

            $RequirementRule = New-CMRequirementRuleFreeDiskSpaceValue `
                -InputObject $GlobalCondition `
                -PartitionOption System `
                -RuleOperator GreaterEquals `
                -Value1 $MinimumDiskSpaceMB

            foreach ($DeploymentType in $DeploymentTypes) {
                $Technology = $DeploymentType.Technology
                $DTName = $DeploymentType.LocalizedDisplayName

                switch ($Technology) {
                    "Script" {
                        Set-CMScriptDeploymentType `
                            -ApplicationName $ApplicationName `
                            -DeploymentTypeName $DTName `
                            -AddRequirement $RequirementRule `
                            -ErrorAction Stop
                    }
                    "MSI" {
                        Set-CMMsiDeploymentType `
                            -ApplicationName $ApplicationName `
                            -DeploymentTypeName $DTName `
                            -AddRequirement $RequirementRule `
                            -ErrorAction Stop
                    }
                    default {
                        Write-PCXLog "Skipping unsupported DT technology: $Technology for $DTName" -Level WARNING
                    }
                }
            }

            return [PSCustomObject]@{
                Success            = $true
                ApplicationName    = $ApplicationName
                RequirementType    = "DiskSpace"
                MinimumDiskSpaceMB = $MinimumDiskSpaceMB
                DeploymentTypes    = $DeploymentTypes.Count
            }
        }
        catch {
            Write-PCXLog -Message "Failed to add disk space requirement. $($_.Exception.Message)" -Level ERROR
            throw
        }
    }
    end {
        Write-PCXOperationEnd
    }
}





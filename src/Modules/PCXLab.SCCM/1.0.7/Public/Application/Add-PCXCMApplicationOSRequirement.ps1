function Add-PCXCMApplicationOSRequirement {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ApplicationName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Requirement,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$OSValidateSetPath,

        [switch]$AllowRequirementCreation,

        [string]$ReportPath
    )
    begin {
        Write-PCXOperationStart
    }
    process {
        try {
            Ensure-PCXCMConnection
            
            # Resolve SCCM Application
            $Application = Get-PCXCMApplication -ApplicationName $ApplicationName

            # Deserialize XML
            $XML = Get-PCXCMApplicationXML -Application $Application

            # Detect existing OS requirement
            $ExistingOSRequirement = $false
            foreach ($dt in $XML.DeploymentTypes) {
                foreach ($requirementObj in $dt.Requirements) {
                    if ($requirementObj.Expression.GetType().Name -eq 'OperatingSystemExpression') {
                        $ExistingOSRequirement = $true
                        break
                    }
                }
                if ($ExistingOSRequirement) { break }
            }

            # ==========================================================
            # NO OS REQUIREMENT EXISTS
            # ==========================================================

            if (-not $ExistingOSRequirement) {
                if (-not $AllowRequirementCreation) {
                    Write-PCXLog "OS requirement creation not allowed for '$ApplicationName'. Skipping." -Level WARNING
                    return (Save-PCXOSRequirementReport -ReportPath $ReportPath -ApplicationName $ApplicationName -Requirement $Requirement -Status "Skipped" -Application $Application)
                }

                $Operand = Get-PCXCMApplicationOSRequirementOperand -Requirement $Requirement -CsvPath $OSValidateSetPath
                if (-not $Operand) {
                    throw "Requirement not found in OS validation set: $Requirement"
                }

                $RequirementRule = New-PCXCMApplicationOSRequirementRule -Operand $Operand

                Add-PCXCMApplicationOSRequirementToDeploymentType `
                    -ApplicationName $ApplicationName `
                    -RequirementRule $RequirementRule

                Write-PCXLog "New OS requirement added to '$ApplicationName'"
                return (Save-PCXOSRequirementReport -ReportPath $ReportPath -ApplicationName $ApplicationName -Requirement $Requirement -Status "Updated" -Application $Application)
            }

            # ==========================================================
            # EXISTING REQUIREMENT DETECTION
            # ==========================================================

            if (Test-PCXCMApplicationOSRequirementExists -Xml $XML -Requirement $Requirement) {
                Write-PCXLog "OS requirement '$Requirement' already exists for '$ApplicationName'."
                return (Save-PCXOSRequirementReport -ReportPath $ReportPath -ApplicationName $ApplicationName -Requirement $Requirement -Status "AlreadyExists" -Application $Application)
            }

            # ==========================================================
            # XML MERGE PATH
            # ==========================================================

            $Operand = Get-PCXCMApplicationOSRequirementOperand -Requirement $Requirement -CsvPath $OSValidateSetPath
            if (-not $Operand) {
                throw "Requirement not found in OS validation set: $Requirement"
            }

            $Updated = Add-PCXCMApplicationOSRequirementToXML `
                -Xml $XML `
                -Requirement $Requirement `
                -Operand $Operand

            if (-not $Updated) {
                Write-PCXLog "Failed to update XML for '$ApplicationName'. Skipping." -Level WARNING
                return (Save-PCXOSRequirementReport -ReportPath $ReportPath -ApplicationName $ApplicationName -Requirement $Requirement -Status "Skipped" -Application $Application)
            }

            Save-PCXCMApplicationXML -Application $Application -Xml $XML

            Write-PCXLog "OS requirement '$Requirement' merged into XML for '$ApplicationName'"
            return (Save-PCXOSRequirementReport -ReportPath $ReportPath -ApplicationName $ApplicationName -Requirement $Requirement -Status "Updated" -Application $Application)
        }
        catch {
            Write-PCXLog -Message "Failed OS requirement operation for application '$ApplicationName'. $($_.Exception.Message)" -Level ERROR
            throw
        }
    }
    end {
        Write-PCXOperationEnd
    }
}

# Private helper to avoid duplication
function Save-PCXOSRequirementReport {
    param($ReportPath, $ApplicationName, $Requirement, $Status, $Application)
    
    $Result = New-PCXReportObject `
        -ApplicationName $ApplicationName `
        -Requirement $Requirement `
        -Status $Status `
        -Application $Application

    if ($ReportPath) {
        $Result | Export-Csv -Path $ReportPath -NoTypeInformation -Encoding UTF8 -Append
    }
    return $Result
}

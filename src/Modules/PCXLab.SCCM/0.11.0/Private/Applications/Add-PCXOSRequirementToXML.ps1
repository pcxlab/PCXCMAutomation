function Add-PCXOSRequirementToXML {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        $Xml,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Requirement,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Operand
    )

    begin {

        Write-PCXOperationStart
    }
    process {
        try {

            foreach ($dt in $Xml.DeploymentTypes) {

                $OperatingSystemRequirementFound = $false

                foreach ($requirementObj in $dt.Requirements) {

                    if ($requirementObj.Expression.GetType().Name -eq 'OperatingSystemExpression') {

                        $OperatingSystemRequirementFound = $true

                        if ($requirementObj.Name -NotLike "*$Requirement*") {

                            $requirementObj.Expression.Operands.Add("$Operand")

                            $requirementObj.Name = [regex]::replace(
                                $requirementObj.Name,
                                '(?<=Operating system One of {)(.*)(?=})',
                                "`$1, $Requirement"
                            )

                            $null = $dt.Requirements.Remove($requirementObj)

                            $requirementObj.RuleId = "Rule_$([guid]::NewGuid())"

                            $null = $dt.Requirements.Add($requirementObj)

                            return $true
                        }

                        return $false
                    }
                }

                # Create first OS requirement if none exists
                if (-not $OperatingSystemRequirementFound) {

                    $NewRequirement = New-CMRequirementRuleOperatingSystemValue `
                        -RuleOperator OneOf `
                        -PlatformString $Operand

                    $NewRequirement.RuleId = "Rule_$([guid]::NewGuid())"

                    $null = $dt.Requirements.Add($NewRequirement)

                    return $true
                }
            }

            return $false
        }
        catch {
            Write-PCXLog "Failed to update OS requirement XML. $($_.Exception.Message)" "ERROR"
            throw
        }
        
    }
    end {

        Write-PCXOperationEnd -Status Success
    }
}




function New-PCXOSRequirementRule {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Operand
    )

    begin {
        Write-PCXLog "BEGIN - PCXLab Automation"
    }
    process {
        try {

            $OSGlobalCondition = Get-CMGlobalCondition -Name "Operating System" |
                Where-Object {
                    $_.PlatformType -eq 1
                } |
                Select-Object -First 1

            if (-not $OSGlobalCondition) {
                throw "Failed to find SCCM Operating System global condition."
            }

            $RequirementRule = $OSGlobalCondition |
                New-CMRequirementRuleOperatingSystemValue `
                    -RuleOperator OneOf `
                    -PlatformString $Operand

            return $RequirementRule
        }
        catch {
            Write-PCXLog "Failed to create OS requirement rule. $($_.Exception.Message)" "ERROR"
            throw
        }
        finally {
            Write-PCXLog "OS requirement rule operation completed"
        }
    }
    end {
        Write-PCXLog "END - www.pcxlab.com"
    }
}
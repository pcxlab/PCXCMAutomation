function New-PCXOSRequirementRule {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Operand
    )

    try {

        $OSGlobalCondition = Get-CMGlobalCondition `
            -Name "Operating System" |
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

        throw $_
    }
}
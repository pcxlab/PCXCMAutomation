function Test-PCXOSRequirementExists {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        $Xml,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Requirement
    )

    foreach ($dt in $Xml.DeploymentTypes) {

        foreach ($req in $dt.Requirements) {

            if ($req.Expression.GetType().Name -eq 'OperatingSystemExpression') {

                if ($req.Name -like "*$Requirement*") {

                    return $true
                }
            }
        }
    }

    return $false
}
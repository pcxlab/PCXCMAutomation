function Test-PCXCMApplicationOSRequirementExists {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        $Xml,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Requirement
    )

    begin {

        Write-PCXOperationStart
    }
    process {
        try {
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
        catch {
            Write-PCXLog -Message "Failed to test OS requirement existence: $Requirement. $($_.Exception.Message)" -Level ERROR
            throw
        }
        
    }
    end {

        Write-PCXOperationEnd -Status Success
    }
}





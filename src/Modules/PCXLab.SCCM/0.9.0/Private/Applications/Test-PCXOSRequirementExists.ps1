function Test-PCXOSRequirementExists {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        $Xml,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Requirement
    )

    begin {
        Write-PCXLog "BEGIN - PCXLab Automation"
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
            Write-PCXLog "Failed to test OS requirement existence: $Requirement. $($_.Exception.Message)" "ERROR"
            throw
        }
        finally {
            Write-PCXLog "Test OS requirement operation completed: $Requirement"
        }
    }
    end {
        Write-PCXLog "END - www.pcxlab.com"
    }
}
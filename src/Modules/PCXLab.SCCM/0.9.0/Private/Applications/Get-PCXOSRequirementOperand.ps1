function Get-PCXOSRequirementOperand {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Requirement,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$CsvPath
    )

    begin {
        Write-PCXLog "BEGIN - PCXLab Automation"
    }
    process {
        try {
            $NamedPairs = @{}

            Get-Content $CsvPath | ForEach-Object {

                $name = $_.Split(",")[0]
                $operand = $_.Split(",")[1]

                $NamedPairs[$name] = $operand
            }

            if (-not $NamedPairs.ContainsKey($Requirement)) {
                throw "Requirement not found: $Requirement"
            }

            return $NamedPairs[$Requirement]
        }
        catch {
            Write-PCXLog "Failed to get OS requirement operand: $Requirement. $($_.Exception.Message)" "ERROR"
            throw
        }
        finally {
            Write-PCXLog "Get OS requirement operand operation completed: $Requirement"
        }
    }
    end {
        Write-PCXLog "END - www.pcxlab.com"
    }
}
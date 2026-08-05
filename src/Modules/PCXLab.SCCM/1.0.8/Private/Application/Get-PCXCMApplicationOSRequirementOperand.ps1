function Get-PCXCMApplicationOSRequirementOperand {

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

        Write-PCXOperationStart
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
            Write-PCXLog -Message "Failed to get OS requirement operand: $Requirement. $($_.Exception.Message)" -Level ERROR
            throw
        }
        
    }
    end {

        Write-PCXOperationEnd -Status Success
    }
}





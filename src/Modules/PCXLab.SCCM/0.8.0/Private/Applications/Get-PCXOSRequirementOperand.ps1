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

    $NamedPairs = @{}

    Get-Content $CsvPath | ForEach-Object {

        $name = $_.Split(",")[0]
        $operand = $_.Split(",")[1]

        $NamedPairs[$name] = $operand
    }

    return $NamedPairs[$Requirement]
}
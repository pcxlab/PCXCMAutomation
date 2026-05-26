function Import-PCXApplicationList {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$CsvPath
    )

    if (-not (Test-Path $CsvPath)) {
        throw "CSV file not found: $CsvPath"
    }

    return Import-Csv $CsvPath |
        Select-Object -ExpandProperty "Application Name"
}
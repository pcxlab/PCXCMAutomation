function Import-PCXApplicationList {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$CsvPath
    )

    begin {
        Write-PCXLog "BEGIN - PCXLab Automation"
    }
    process {
        try {

            if (-not (Test-Path $CsvPath)) {
                throw "CSV file not found: $CsvPath"
            }

            return Import-Csv $CsvPath |
                Select-Object -ExpandProperty "Application Name"
        }
        catch {
            Write-PCXLog "Failed to import application list: $CsvPath. $($_.Exception.Message)" "ERROR"
            throw
        }
        finally {
            Write-PCXLog "Import application list operation completed: $CsvPath"
        }
    }
    end {
        Write-PCXLog "END - www.pcxlab.com"
    }
}
function Initialize-PCXLogging {

    [CmdletBinding()]
    param(

        [string]$LogDirectory = "C:\Temp"
    )

    # Ensure log directory exists
    if (-not (Test-Path $LogDirectory)) {

        New-Item `
            -Path $LogDirectory `
            -ItemType Directory `
            -Force | Out-Null
    }

    # Generate timestamp
    $Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

    # Operational log
    $Global:PCXLogFile = Join-Path `
        $LogDirectory `
        "PCX_$Timestamp.log"

    # Error log
    $Global:PCXErrorLogFile = Join-Path `
        $LogDirectory `
        "PCX_Error_$Timestamp.log"
}
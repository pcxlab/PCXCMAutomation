function Write-PCXLog {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet("INFO","WARNING","ERROR","DEBUG")]
        [string]$Level = "INFO"
    )

    # Auto initialize if needed
    if (-not $Global:PCXLogFile) {
        Initialize-PCXLogging
    }

    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Line = "$TimeStamp [$Level] $Message"

    # Console output
    switch ($Level) {
        "INFO"    { Write-Host $Line -ForegroundColor White }
        "WARNING" { Write-Host $Line -ForegroundColor Yellow }
        "ERROR"   { Write-Host $Line -ForegroundColor Red }
        "DEBUG"   { Write-Host $Line -ForegroundColor Cyan }
    }

    # Write to operational log
    Add-Content -Path $Global:PCXLogFile -Value $Line

    # Write errors to separate error log
    if ($Level -eq "ERROR") {
        Add-Content -Path $Global:PCXErrorLogFile -Value $Line
    }
}
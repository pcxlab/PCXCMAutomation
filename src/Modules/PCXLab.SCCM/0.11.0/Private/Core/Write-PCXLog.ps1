function Write-PCXLog {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet("INFO", "WARNING", "ERROR", "DEBUG")]
        [string]$Level = "INFO"
    )

    # Auto initialize if needed (minimally)
    if (-not $Global:PCXLogConfiguration) { Initialize-PCXLogConfiguration }
    if (-not $Global:PCXLogFile) { Initialize-PCXLogging }

    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    # Operation context
    $Operation = "GENERAL"
    if ($Global:PCXOperationStack -and $Global:PCXOperationStack.Count -gt 0) {
        $TopOperation = $Global:PCXOperationStack.Peek()
        if ($TopOperation -and $TopOperation.Name) { $Operation = $TopOperation.Name }
    }

    $Line = "$TimeStamp [$Operation] [$Level] $Message"

    # Determine console color
    $ForegroundColor = $null

    if ($Global:PCXLogConfiguration.TerminalAppearance.EnableCustomColors) {
        $StartPattern = "^$([Regex]::Escape($Global:PCXLogConfiguration.StartText))\b"
        
        if ($Message -match $StartPattern) {
            $ForegroundColor = $Global:PCXLogConfiguration.TerminalAppearance.StartColor
        }
        elseif ($Message -like 'COMPLETED (SUCCESS)*') {
            $ForegroundColor = $Global:PCXLogConfiguration.TerminalAppearance.SuccessColor
        }
        elseif ($Message -like 'COMPLETED (FAILED)*') {
            $ForegroundColor = $Global:PCXLogConfiguration.TerminalAppearance.FailedColor
        }
    }

    if (-not $ForegroundColor) {
        $colorMap = @{
            "INFO"    = $Global:PCXLogConfiguration.TerminalAppearance.InfoColor
            "WARNING" = $Global:PCXLogConfiguration.TerminalAppearance.WarningColor
            "ERROR"   = $Global:PCXLogConfiguration.TerminalAppearance.ErrorColor
            "DEBUG"   = $Global:PCXLogConfiguration.TerminalAppearance.DebugColor
        }
        $ForegroundColor = $colorMap[$Level]
    }

    # Ultimate safety fallback
    if (-not $ForegroundColor) { $ForegroundColor = "White" }

    # Console output
    Write-Host $Line -ForegroundColor $ForegroundColor

    # Write to operational log
    $Line | Add-Content -Path $Global:PCXLogFile -ErrorAction SilentlyContinue

    # Write errors to separate error log
    if ($Level -eq "ERROR") {
        $Line | Add-Content -Path $Global:PCXErrorLogFile -ErrorAction SilentlyContinue
    }
}



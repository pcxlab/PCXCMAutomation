function Write-PCXLog {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet("INFO", "WARNING", "ERROR", "DEBUG")]
        [string]$Level = "INFO"
    )

    # Auto initialize if needed
    if (-not $Global:PCXLogFile) {

        Initialize-PCXLogging
    }

    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    if (
        $Global:PCXOperationStack -and
        $Global:PCXOperationStack.Count -gt 0
    ) {

        $Operation = $Global:PCXOperationStack.Peek()

        $Line = "$TimeStamp [$Level] [$Operation] $Message"
    }
    else {

        $Line = "$TimeStamp [$Level] $Message"
    }

    # Determine console color
    $ForegroundColor = $null

    if (
        $Global:PCXLogConfiguration.TerminalAppearance.EnableCustomColors
    ) {

        switch -Regex ($Message) {

            '^START\b' {

                $ForegroundColor = $Global:PCXLogConfiguration.TerminalAppearance.StartColor
                break
            }

            '^COMPLETED \(SUCCESS\)' {

                $ForegroundColor = $Global:PCXLogConfiguration.TerminalAppearance.SuccessColor
                break
            }

            '^COMPLETED \(FAILED\)' {

                $ForegroundColor = $Global:PCXLogConfiguration.TerminalAppearance.FailedColor
                break
            }
        }
    }

    # Fall back to standard log level colors
    if (-not $ForegroundColor) {

        switch ($Level) {

            "INFO" {

                $ForegroundColor = $Global:PCXLogConfiguration.TerminalAppearance.InfoColor
            }

            "WARNING" {

                $ForegroundColor = $Global:PCXLogConfiguration.TerminalAppearance.WarningColor
            }

            "ERROR" {

                $ForegroundColor = $Global:PCXLogConfiguration.TerminalAppearance.ErrorColor
            }

            "DEBUG" {

                $ForegroundColor = $Global:PCXLogConfiguration.TerminalAppearance.DebugColor
            }
        }
    }

    # Console output
    Write-Host $Line -ForegroundColor $ForegroundColor

    # Write to operational log
    Add-Content `
        -Path $Global:PCXLogFile `
        -Value $Line

    # Write errors to separate error log
    if ($Level -eq "ERROR") {

        Add-Content `
            -Path $Global:PCXErrorLogFile `
            -Value $Line
    }
}
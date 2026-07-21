function Write-PCXOperationEnd {

    [CmdletBinding()]
    param(
        [ValidateSet("Success", "Failed", "Warning")]
        [string]$Status = "Success",

        [Parameter(Mandatory = $false)]
        [string]$Message
    )

    if (
        $Global:PCXOperationStack -and
        $Global:PCXOperationStack.Count -gt 0
    ) {
        $Operation = $Global:PCXOperationStack.Pop()

        $Operation.Stopwatch.Stop()

        $DurationText = Format-PCXDuration `
            -TotalSeconds $Operation.Stopwatch.Elapsed.TotalSeconds

        $StatusText = "COMPLETED ($($Status.ToUpper()))"

        $FinalMessage = if ($Message) {
            "$StatusText - $Message ($DurationText) - $($Global:PCXLogConfiguration.Website)"
        }
        else {
            "$StatusText ($DurationText) - $($Global:PCXLogConfiguration.Website)"
        }

        #$LogLevel = if ($Status -eq "Success") { "INFO" } else { "ERROR" }
        switch ($Status) {
            'Success' { $LogLevel = 'INFO' }
            'Warning' { $LogLevel = 'WARNING' }
            'Failed' { $LogLevel = 'ERROR' }
        }

        Write-PCXLog -Message $FinalMessage -Level $LogLevel
    }
    else {
        Write-PCXLog "COMPLETED ($($Status.ToUpper())) - Unknown Operation stack sync issue. - $($Global:PCXLogConfiguration.Website)" -Level WARNING
    }
}




function Write-PCXOperationEnd {

    [CmdletBinding()]
    param(
        [ValidateSet("Success", "Failed")]
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

        $Duration = [math]::Round(
            $Operation.Stopwatch.Elapsed.TotalSeconds,
            2
        )

        if ($Duration -lt 60) {
            $DurationText = "{0:N2} sec" -f $Duration
        }
        else {
            $Minutes = [math]::Floor($Duration / 60)
            $Seconds = $Duration % 60
            $DurationText = "{0} min {1:N2} sec" -f $Minutes, $Seconds
        }

        $StatusText = "COMPLETED ($($Status.ToUpper()))"
        #$FinalMessage = if ($Message) { "$StatusText - $Message ($DurationText)" } else { "$StatusText ($DurationText)" }

        $FinalMessage = if ($Message) {
            "$StatusText - $Message ($DurationText) - $($Global:PCXLogConfiguration.Website)"
        }
        else {
            "$StatusText ($DurationText) - $($Global:PCXLogConfiguration.Website)"
        }

        $LogLevel = if ($Status -eq "Success") { "INFO" } else { "ERROR" }

        Write-PCXLog -Message $FinalMessage -Level $LogLevel
    }
    else {
        # Write-PCXLog "COMPLETED ($($Status.ToUpper())) - Unknown Operation stack sync issue." -Level WARNING
        Write-PCXLog "COMPLETED ($($Status.ToUpper())) - Unknown Operation stack sync issue. - $($Global:PCXLogConfiguration.Website)" -Level WARNING
    }
}




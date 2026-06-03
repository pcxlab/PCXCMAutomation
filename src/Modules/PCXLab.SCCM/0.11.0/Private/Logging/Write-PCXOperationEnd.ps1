function Write-PCXOperationEnd {

    [CmdletBinding()]
    param(

        [ValidateSet("Success", "Failed")]
        [string]$Status = "Success"
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

        $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

        $Line = "$TimeStamp [$($Operation.Name)] [INFO] COMPLETED ($($Status.ToUpper())) - $DurationText - $($Global:PCXLogConfiguration.Website)"
        
        Write-Host $Line -ForegroundColor $Global:PCXLogConfiguration.TerminalAppearance.SuccessColor

        Add-Content -Path $Global:PCXLogFile -Value $Line
    }
    else {
        Write-PCXLog "COMPLETED ($($Status.ToUpper())) - Unknown Operation - $($Global:PCXLogConfiguration.Website)"
    }
}



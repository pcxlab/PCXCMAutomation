function Write-PCXOperationStart {

    [CmdletBinding()]
    param()

    $Operation = Get-PCXOperationName

    $OperationInfo = [PSCustomObject]@{
        Name      = $Operation
        StartTime = Get-Date
        Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    }

    $Global:PCXOperationStack.Push($OperationInfo)

    Write-PCXLog "$($Global:PCXLogConfiguration.StartText) - $($Global:PCXLogConfiguration.FrameworkName)"
}



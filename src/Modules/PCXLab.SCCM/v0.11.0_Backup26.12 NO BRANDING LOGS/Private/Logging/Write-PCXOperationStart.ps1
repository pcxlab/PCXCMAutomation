function Write-PCXOperationStart {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$OperationName
    )

    # Use provided name or discover it (expensive)
    $Operation = if ($OperationName) { 
        # Apply friendly name mapping if available
        if ($Global:PCXLogConfiguration.UseFriendlyNames -and $Global:PCXOperationNames.ContainsKey($OperationName)) {
            $Global:PCXOperationNames[$OperationName]
        } else {
            $OperationName
        }
    } else { 
        Get-PCXOperationName 
    }

    $OperationInfo = [PSCustomObject]@{
        Name      = $Operation
        StartTime = Get-Date
        Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    }

    $Global:PCXOperationStack.Push($OperationInfo)

    Write-PCXLog "$($Global:PCXLogConfiguration.StartText) - $Operation"
}



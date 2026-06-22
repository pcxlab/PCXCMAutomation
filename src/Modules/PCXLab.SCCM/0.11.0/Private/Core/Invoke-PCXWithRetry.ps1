function Invoke-PCXWithRetry {

    param(
        [Parameter(Mandatory)]
        [scriptblock]$ScriptBlock,

        [int]$RetryCount = 3,

        [int]$RetryDelay = 5
    )

    for ($i = 1; $i -le $RetryCount; $i++) {

        try {
            return & $ScriptBlock
        }
        catch {

            if ($i -eq $RetryCount) {
                throw $_
            }

            Start-Sleep -Seconds $RetryDelay
        }
    }
}



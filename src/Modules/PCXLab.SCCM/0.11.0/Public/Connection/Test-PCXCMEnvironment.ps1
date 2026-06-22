function Test-PCXCMEnvironment {

    [CmdletBinding()]
    param()

    $Results = [System.Collections.Generic.List[Object]]::new()

    try {

        $Results.Add([PSCustomObject]@{
            Check  = "SMS_ADMIN_UI_PATH"
            Status = if ($env:SMS_ADMIN_UI_PATH) { "PASS" } else { "FAIL" }
        })

        $Results.Add([PSCustomObject]@{
            Check  = "ConfigurationManager Module"
            Status = if (Get-Module ConfigurationManager) { "PASS" } else { "FAIL" }
        })

        $Results.Add([PSCustomObject]@{
            Check  = "New-CMCollection"
            Status = if (Get-Command New-CMCollection -ErrorAction SilentlyContinue) { "PASS" } else { "FAIL" }
        })

        $Results.Add([PSCustomObject]@{
            Check  = "New-CMApplication"
            Status = if (Get-Command New-CMApplication -ErrorAction SilentlyContinue) { "PASS" } else { "FAIL" }
        })

        $Results
    }
    catch {

        throw
    }
}

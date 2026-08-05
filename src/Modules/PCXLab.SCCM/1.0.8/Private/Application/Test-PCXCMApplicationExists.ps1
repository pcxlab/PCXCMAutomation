function Test-PCXCMApplicationExists {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ApplicationName
    )

    try {
        return $null -ne (Get-CMApplication -Name $ApplicationName -Fast -ErrorAction SilentlyContinue)
    }
    catch {

        Write-PCXLog `
            -Message $_.Exception.Message `
            -Level ERROR

        throw
    }
}

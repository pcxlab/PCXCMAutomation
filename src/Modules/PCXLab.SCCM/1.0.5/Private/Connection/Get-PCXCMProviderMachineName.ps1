function Get-PCXCMProviderMachineName {

    [CmdletBinding()]
    param()

    Initialize-PCXCMConnection | Out-Null

    if (-not $script:PCXCMConnection.Connected) {
        Ensure-PCXCMConnection
    }

    return $script:PCXCMConnection.ProviderMachineName
}
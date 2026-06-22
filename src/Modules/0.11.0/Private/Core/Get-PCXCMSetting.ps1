function Get-PCXCMSetting {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    try {

        $SettingsPath = Join-Path $PSScriptRoot '..\..\Config\Settings.json'

        if (-not (Test-Path $SettingsPath)) {
            return $null
        }

        $Settings = Get-Content $SettingsPath -Raw | ConvertFrom-Json

        return $Settings.$Name
    }
    catch {
        return $null
    }
}
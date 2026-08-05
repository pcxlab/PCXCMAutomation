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

        $Value = $Settings

        foreach ($Property in $Name.Split('.')) {

            if ($null -eq $Value) {
                return $null
            }

            $Value = $Value.$Property
        }

        return $Value
    }
    catch {
        return $null
    }
}
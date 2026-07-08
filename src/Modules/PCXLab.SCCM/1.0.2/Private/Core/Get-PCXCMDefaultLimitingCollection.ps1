function Get-PCXCMDefaultLimitingCollection {

    [CmdletBinding()]
    param()

    $ModuleRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent

    $SettingsPath = Join-Path $ModuleRoot 'Config\Settings.json'

    if (-not (Test-Path $SettingsPath)) {

        Write-PCXLog -Message "Settings.json not found. Using 'All Systems' as default limiting collection." -Level Warning

        return 'All Systems'
    }

    try {

        $Settings = Get-Content -Path $SettingsPath -Raw -ErrorAction Stop | ConvertFrom-Json

        $CollectionName = $Settings.DefaultLimitingCollection
    }
    catch {

        Write-PCXLog -Message "Failed to read Settings.json. Using 'All Systems' as default limiting collection." -Level Warning

        return 'All Systems'
    }

    if ([string]::IsNullOrWhiteSpace($CollectionName)) {

        Write-PCXLog -Message "DefaultLimitingCollection not configured. Using 'All Systems'." -Level Warning

        return 'All Systems'
    }

    if ($CollectionName -eq 'All Systems') {

        Write-PCXLog -Message "Default limiting collection is configured as 'All Systems'. Consider changing this to an environment-specific limiting collection." -Level Warning
    }

    return $CollectionName
}
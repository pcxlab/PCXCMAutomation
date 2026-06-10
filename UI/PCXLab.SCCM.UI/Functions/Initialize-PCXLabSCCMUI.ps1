function Initialize-PCXLabSCCMUI {
    [CmdletBinding()]
    param()

    $LoadedModule = Import-PCXLabSCCMModule

    $RequiredCommands = @("Create-PCXCMPackage", "Create-PCXCMApplication")
    foreach ($Cmd in $RequiredCommands) {
        if (-not (Get-Command $Cmd -ErrorAction SilentlyContinue)) {
            throw "Required command '$Cmd' not found in loaded module."
        }
    }

    Write-Host "Loaded Module : $($LoadedModule.Name) v$($LoadedModule.Version)" -ForegroundColor Green
    return $true
}
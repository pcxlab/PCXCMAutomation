function Initialize-PCXLabSCCMUI {

    [CmdletBinding()]
    param()

    $LoadedModule = Import-PCXLabSCCMModule

    if (-not (Get-Command Create-PCXCMPackage -ErrorAction SilentlyContinue)) {
        throw "Create-PCXCMPackage function not found."
    }

    $CreatePackageFile = (Get-Command Create-PCXCMPackage).ScriptBlock.File

    Write-Host "Loaded Module Version : $($LoadedModule.Version)" -ForegroundColor Green
    Write-Host "Loaded Module Path    : $($LoadedModule.Path)" -ForegroundColor Green
    Write-Host "Create-PCXCMPackage   : $CreatePackageFile" -ForegroundColor Cyan

    return $true
}
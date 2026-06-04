function Initialize-PCXLabSCCMUI {

    [CmdletBinding()]
    param()

    $LoadedModule = Import-PCXLabSCCMModule

    if (-not (Get-Command Create-PCXCMPackage -ErrorAction SilentlyContinue)) {
        throw "Create-Package function not found."
    }

    if (-not (Get-Command Create-PCXCMApplication -ErrorAction SilentlyContinue)) {
        throw "Create-Application function not found."
    }

    #$CreatePackageFile = (Get-Command Create-PCXCMPackage).ScriptBlock.File
    #$CreateApplicationFile = (Get-Command Create-PCXCMApplication).ScriptBlock.File

    Write-Host "Loaded Module Version : $($LoadedModule.Version)" -ForegroundColor Green
    Write-Host "Loaded Module Path    : $($LoadedModule.Path)" -ForegroundColor Green
    #Write-Host "Create-PCXCMPackage   : $CreatePackageFile" -ForegroundColor Cyan

    return $true
}
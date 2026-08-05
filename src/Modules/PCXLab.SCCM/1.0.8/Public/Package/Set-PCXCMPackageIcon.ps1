function Set-PCXCMPackageIcon {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$PackageName,

        [Parameter(Mandatory)]
        [string]$IconPath
    )

    try {

        Ensure-PCXCMConnection

        <#
        if (-not (Test-Path $IconPath)) {
            throw "Icon file not found: $IconPath"
        }
        
        #>

        if (-not (Test-Path -LiteralPath ("FileSystem::$IconPath") -PathType Leaf)) {
            throw "Icon file not found: $IconPath"
        }

        Write-PCXLog "Setting package icon..."
        Write-PCXLog "Package : $PackageName"
        Write-PCXLog "Icon    : $IconPath"

        Set-CMPackage `
            -Name $PackageName `
            -IconLocationFile $IconPath

        Write-PCXLog "Package icon updated successfully."

        return $true
    }
    catch {
        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}
function Get-PCXCMPackageSize {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Package
    )

    try {

        return [int64]$Package.PackageSize
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}

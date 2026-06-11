function Get-PCXCMPackageSourceVersion {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Package
    )

    try {

        return [int]$Package.SourceVersion
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}
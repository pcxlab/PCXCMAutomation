function Get-PCXCMPackageAge {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Package
    )

    try {

        return [int]((Get-Date) - $Package.SourceDate).TotalDays
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}
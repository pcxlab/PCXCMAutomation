function Get-PCXCMPackageLastModifiedAge {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Package
    )

    try {

        if (-not $Package.SourceDate) {
            return 0
        }

        return [int](
            (Get-Date) -
            ([datetime]$Package.SourceDate)
        ).TotalDays
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}

function Get-PCXCMApplicationLastModifiedAge {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Application
    )

    try {

        if (-not $Application.DateLastModified) {
            return $null
        }

        return [math]::Floor(
            ((Get-Date) - $Application.DateLastModified).TotalDays
        )
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}

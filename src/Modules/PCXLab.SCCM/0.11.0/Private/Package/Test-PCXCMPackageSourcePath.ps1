function Test-PCXCMPackageSourcePath {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    try {

        if ([string]::IsNullOrWhiteSpace($Path)) {
            return 'Missing'
        }

        try {

            $null = Get-Item `
                -Path $Path `
                -ErrorAction Stop

            return 'Exists'
        }
        catch [System.UnauthorizedAccessException] {

            return 'Access Denied'
        }
        catch {

            return 'Missing'
        }
    }
    catch {

        Write-PCXLog `
            -Message $_.Exception.Message `
            -Level ERROR

        throw
    }
}

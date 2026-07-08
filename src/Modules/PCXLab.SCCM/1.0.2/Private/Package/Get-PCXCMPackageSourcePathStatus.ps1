function Get-PCXCMPackageSourcePathStatus {

    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$SourcePath
    )

    try {

        if ([string]::IsNullOrWhiteSpace($SourcePath)) {
            return 'Missing'
        }

        if (Test-PCXCMPackageSourcePath -Path $SourcePath) {
            return 'Valid'
        }

        return 'Invalid'
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}

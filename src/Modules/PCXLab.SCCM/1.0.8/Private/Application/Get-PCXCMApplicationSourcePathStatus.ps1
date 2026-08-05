function Get-PCXCMApplicationSourcePathStatus {

    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$SourcePath
    )

    try {

        if ([string]::IsNullOrWhiteSpace($SourcePath)) {
            return 'Missing'
        }

        if (Test-PCXCMApplicationSourcePath -Path $SourcePath) {
            return 'Valid'
        }

        return 'Invalid'
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}

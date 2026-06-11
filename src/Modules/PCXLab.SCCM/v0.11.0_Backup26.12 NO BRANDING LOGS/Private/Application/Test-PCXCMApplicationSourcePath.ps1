function Test-PCXCMApplicationSourcePath {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    try {

        if ([string]::IsNullOrWhiteSpace($Path)) {
            return $false
        }

        return (Test-Path -Path $Path)
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}
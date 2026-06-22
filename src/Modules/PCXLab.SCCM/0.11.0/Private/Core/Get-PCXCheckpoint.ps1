function Get-PCXCheckpoint {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    try {

        if (-not (Test-Path -Path $Path)) {
            return $null
        }

        return (Get-Content -Path $Path -ErrorAction Stop | Select-Object -First 1)
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}

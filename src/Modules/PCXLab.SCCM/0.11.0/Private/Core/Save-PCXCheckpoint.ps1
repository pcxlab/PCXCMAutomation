function Save-PCXCheckpoint {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$Value
    )

    try {

        $ParentPath = Split-Path -Path $Path -Parent

        if (-not (Test-Path -Path $ParentPath)) {
            New-Item -Path $ParentPath -ItemType Directory -Force | Out-Null
        }

        Set-Content -Path $Path -Value $Value -Force
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}

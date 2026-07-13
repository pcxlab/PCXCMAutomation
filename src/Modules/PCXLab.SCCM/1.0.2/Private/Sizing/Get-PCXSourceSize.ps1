function Get-PCXSourceSize {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    try {

        $FileSystemPath = "FileSystem::$Path"

        Write-PCXLog "Get-PCXSourceSize() - Path           : $Path"
        Write-PCXLog "Get-PCXSourceSize() - FileSystemPath : $FileSystemPath"

        if (-not (Test-Path -LiteralPath $FileSystemPath -PathType Container)) {
            throw "Path '$Path' does not exist."
        }

        $Bytes = (
            Get-ChildItem -LiteralPath $FileSystemPath -File -Recurse -Force |
            Measure-Object -Property Length -Sum
        ).Sum

        if (-not $Bytes) {
            $Bytes = 0
        }

        Write-PCXLog "Get-PCXSourceSize() completed successfully."

        [PSCustomObject]@{
            Bytes = [int64]$Bytes
            MB    = [math]::Round($Bytes / 1MB, 2)
            GB    = [math]::Round($Bytes / 1GB, 2)
        }

    }
    catch {
        throw
    }
}
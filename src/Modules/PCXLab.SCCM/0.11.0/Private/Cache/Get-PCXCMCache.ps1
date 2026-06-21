function Get-PCXCMCache {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    $CacheRoot = 'C:\ProgramData\PCXLab\SCCMCache'

    $CacheFile = Join-Path $CacheRoot "$Name.clixml"

    if (-not (Test-Path $CacheFile)) {
        return $null
    }

    Write-PCXLog -Message "Loaded cache: $Name"

    return Import-Clixml -Path $CacheFile
}

function Test-PCXCMCacheExists {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    $CacheRoot = 'C:\ProgramData\PCXLab\SCCMCache'

    $CacheFile = Join-Path `
        $CacheRoot `
        "$Name.clixml"

    return (Test-Path $CacheFile)
}

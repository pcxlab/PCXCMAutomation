function Get-PCXCMCachePath {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    $CacheDirectory = Join-Path `
        $env:TEMP `
        'PCXLab.SCCM.Cache'

    return Join-Path `
        $CacheDirectory `
        "$Name.clixml"
}

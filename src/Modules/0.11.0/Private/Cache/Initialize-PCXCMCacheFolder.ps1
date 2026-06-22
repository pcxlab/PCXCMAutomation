function Initialize-PCXCMCacheFolder {

    $CacheRoot = 'C:\ProgramData\PCXLab\SCCMCache'

    if (-not (Test-Path $CacheRoot)) {
        New-Item -Path $CacheRoot -ItemType Directory -Force | Out-Null
    }

    return $CacheRoot
}
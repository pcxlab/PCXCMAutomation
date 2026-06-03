function Test-PCXHasUpgrade {
    param([string]$Path)

    Test-Path (Join-Path $Path "upgrade.bat")
}



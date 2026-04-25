function Start-PCXLogSession {
    param([Parameter(Mandatory)][string]$LogFolder)

    if (-not (Test-Path $LogFolder)) {
        New-Item -Path $LogFolder -ItemType Directory -Force | Out-Null
    }

    $Stamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $global:PCXLabLogFile = Join-Path $LogFolder "Run_$Stamp.log"

    New-Item -Path $global:PCXLabLogFile -ItemType File -Force | Out-Null
    Write-Host "Logging started: $global:PCXLabLogFile"
}

function Write-PCXLog {
    param(
        [Parameter(Mandatory)][string]$Message,
        [string]$Level = "INFO"
    )

    if (-not $global:PCXLabLogFile) {
        throw "Use Start-PCXLogSession first."
    }

    $Time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Line = "$Time [$Level] $Message"

    Add-Content -Path $global:PCXLabLogFile -Value $Line
    Write-Host $Line
}

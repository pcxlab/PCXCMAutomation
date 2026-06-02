function Import-PCXConfiguration {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ConfigPath
    )

    if (-not (Test-Path $ConfigPath)) {
        throw "Configuration file not found: $ConfigPath"
    }

    [xml]$config = Get-Content $ConfigPath

    [PSCustomObject]@{
        SiteCode   = $config.Configuration.SiteCode
        SiteServer = $config.Configuration.SiteServer
        Requirement = $config.Configuration.Requirement
    }
}
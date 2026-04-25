function New-PCXCMCollection {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    if ($PSCmdlet.ShouldProcess($Name,"Create Collection")) {
        Write-Host "Created collection: $Name"
    }
}

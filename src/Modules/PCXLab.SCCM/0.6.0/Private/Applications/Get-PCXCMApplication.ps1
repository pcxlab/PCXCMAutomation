function Get-PCXCMApplication {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ApplicationName
    )

    $Application = Get-CMApplication `
        -Name $ApplicationName

    if (-not $Application) {
        throw "Application not found: $ApplicationName"
    }

    return $Application
}
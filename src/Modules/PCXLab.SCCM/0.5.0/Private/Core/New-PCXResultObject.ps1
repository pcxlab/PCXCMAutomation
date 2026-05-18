function New-PCXResultObject {
<#
.SYNOPSIS
Creates a standardized PCXLab result object.
#>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [bool]$Success,

        [string]$Action,

        [string]$Name,

        [string]$Path,

        [string]$Message,

        [string]$Error
    )

    [pscustomobject]@{
        Success   = $Success
        Action    = $Action
        Name      = $Name
        Path      = $Path
        Message   = $Message
        Error     = $Error
        Timestamp = Get-Date
    }
}
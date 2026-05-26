function New-PCXResultObject {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [bool]$Success,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Action,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [string]$Error
    )

    [PSCustomObject]@{
        Success  = $Success
        Action   = $Action
        Name     = $Name
        Path     = $Path
        Message  = $Message
        Error    = $Error
        Timestamp = Get-Date
    }
}
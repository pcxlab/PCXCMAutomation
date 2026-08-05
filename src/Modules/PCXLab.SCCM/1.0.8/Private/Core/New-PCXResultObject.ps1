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

        [Parameter()]
        [string]$Path,

        [Parameter()]
        [string]$Message,

        [Parameter()]
        [string]$ErrorMessage,

        [Parameter()]
        [datetime]$StartTime,

        [Parameter()]
        [datetime]$EndTime,

        [Parameter()]
        [double]$DurationSec
    )

    [PSCustomObject]@{

        Success     = $Success
        Action      = $Action
        Name        = $Name
        Path        = $Path
        Message     = $Message
        Error       = $ErrorMessage

        StartTime   = $StartTime
        EndTime     = $EndTime
        DurationSec = $DurationSec

        CreatedOn   = Get-Date
    }
}



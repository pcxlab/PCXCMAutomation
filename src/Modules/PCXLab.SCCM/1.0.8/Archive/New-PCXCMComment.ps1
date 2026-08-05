function New-PCXCMComment {
    <#
    .SYNOPSIS
        Creates a standardized SCCM comment.

    .DESCRIPTION
        Generates a standardized multi-line comment for SCCM objects such as
        Packages, Applications, Collections, Task Sequences, and other
        Configuration Manager objects.

        Format:

        CRT:<Creator>
        REV:<Reviewer>
        REQ:<RequestNumber>
        DT:<ddMMyyyy-HHmm>
        CMT:<Comment>

        Empty fields are automatically omitted unless
        -IncludeEmptyFields is specified.

    .PARAMETER Creator
        Creator name.
        Defaults to the currently logged-on user.

    .PARAMETER Reviewer
        Reviewer name.

    .PARAMETER RequestNumber
        Request, Incident, Change or Ticket number.

    .PARAMETER Comment
        Free text comment.

    .PARAMETER IncludeEmptyFields
        Includes empty fields in the output.

    .EXAMPLE
        New-PCXCMComment `
            -Reviewer "David" `
            -RequestNumber "INC123456" `
            -Comment "Google Chrome package"

    .OUTPUTS
        System.String
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param(
        [string]$Creator = $env:USERNAME,

        [string]$Reviewer,

        [string]$RequestNumber,

        [string]$Comment,

        [switch]$IncludeEmptyFields
    )

    # Trim values
    $Creator       = $Creator.Trim()
    $Reviewer      = $Reviewer.Trim()
    $RequestNumber = $RequestNumber.Trim()

    if ($null -ne $Comment) {
        $Comment = $Comment.Trim()
        $Comment = $Comment -replace '\r?\n', ' '
    }

    # Generate timestamp
    $DateTime = Get-Date -Format 'ddMMyyyy-HHmm'

    # Build comment
    $Lines = [System.Collections.Generic.List[string]]::new()

    if ($IncludeEmptyFields -or $Creator) {
        $Lines.Add("CRT:$Creator")
    }

    if ($IncludeEmptyFields -or $Reviewer) {
        $Lines.Add("REV:$Reviewer")
    }

    if ($IncludeEmptyFields -or $RequestNumber) {
        $Lines.Add("REQ:$RequestNumber")
    }

    # Always include timestamp
    $Lines.Add("DT:$DateTime")

    if ($IncludeEmptyFields -or $Comment) {
        $Lines.Add("CMT:$Comment")
    }

    $Result = $Lines -join [Environment]::NewLine

    return $Result
}
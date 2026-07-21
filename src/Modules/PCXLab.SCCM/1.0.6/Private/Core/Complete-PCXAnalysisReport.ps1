function Complete-PCXAnalysisReport {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    return (Get-Item -Path $Path)
}

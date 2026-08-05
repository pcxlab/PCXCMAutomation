function Initialize-PCXAnalysisReport {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    $ParentPath = Split-Path `
        -Path $Path `
        -Parent

    if (-not (Test-Path -Path $ParentPath)) {

        New-Item `
            -Path $ParentPath `
            -ItemType Directory `
            -Force | Out-Null
    }

    return $Path
}

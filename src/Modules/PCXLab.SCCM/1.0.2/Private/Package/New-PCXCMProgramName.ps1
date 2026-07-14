function New-PCXCMProgramName {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Company,

        [Parameter(Mandatory)]
        [string]$Product,

        [Parameter()]
        [string]$Version,

        [Parameter(Mandatory)]
        [string]$Type
    )

    $MaxLength = 50

    $Candidates = @()

    # Try full name
    $Candidates += "PKG $Company $Product $Version [$Type]"

    # Remove PKG prefix
    $Candidates += "$Company $Product $Version [$Type]"

    # Remove company
    $Candidates += "$Product $Version [$Type]"

    # Remove version
    $Candidates += "$Product [$Type]"

    # Last resort
    $Candidates += "[$Type]"

    foreach ($Candidate in $Candidates) {

        # Remove duplicate spaces (e.g. empty version)
        $Candidate = ($Candidate -replace '\s+', ' ').Trim()

        if ($Candidate.Length -le $MaxLength) {
            return $Candidate
        }
    }

    # Should never happen, but keep a safe fallback
    return "[$Type]"
}
function Get-PCXSourceMetadata {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SourcePath
    )

    $clean = $SourcePath.TrimEnd("\")
    $parts = $clean -split "\\"
    if ($parts.Count -lt 3) { throw "Invalid path structure. Path must be like ...\Company\Product\Package" }

    $company = $parts[-3]
    $raw = $parts[-1]

    $versionMatch = [regex]::Match($raw, '\d+(\.\d+)+')
    $version = if ($versionMatch.Success) { $versionMatch.Value } else { "1.0" }

    $product = $raw -replace [regex]::Escape($version), ""
    $product = $product -replace '[\.\-_]', ' '
    $product = ($product -replace '\s+', ' ').Trim()
    $product = $product -replace [regex]::Escape($company), ""
    $product = ($product -replace '\s+', ' ').Trim()

    $name = "$company $product $version"

    return @{
        Name    = $name
        Company = $company
        Product = $product
        Version = $version
    }
}
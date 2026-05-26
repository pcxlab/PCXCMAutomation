function Get-PCXMetadataFromPath {
    param([string]$Path)

    $clean = $Path.TrimEnd("\")

    $parts = $clean -split "\\"

    $company = $parts[-3]

    $raw = $parts[-1]

    $versionMatch = [regex]::Match($raw, '\d+(\.\d+)+')

    $version = if ($versionMatch.Success) {
        $versionMatch.Value
    }
    else {
        "1.0"
    }

    $product = $raw -replace [regex]::Escape($version), ""

    $product = $product -replace '[\.\-_]', ' '

    $product = ($product -replace '\s+', ' ').Trim()

    $product = $product -replace [regex]::Escape($company), ""

    $product = ($product -replace '\s+', ' ').Trim()

    $name = "$company $product $version"

    #$packagename = "APP $name"

    return @{
        Name        = $name
        Company     = $company
        Product     = $product
        Version     = $version
    }
}
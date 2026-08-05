function Get-PCXMetadataFromPath {
    param([string]$Path)

    $parts = $Path.TrimEnd('\') -split '\\'

    $company = $parts[-3]
    $product = $parts[-2]
    $raw     = $parts[-1]

    $versionMatch = [regex]::Match($raw, '\d+(\.\d+)+')

    $version = if ($versionMatch.Success) {
        $versionMatch.Value
    }
    else {
        '1.0'
    }

    return @{
        Name     = "$company $product $version"
        Company  = $company
        Product  = $product
        Version  = $version
    }
}
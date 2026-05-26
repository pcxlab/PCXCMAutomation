function Get-PCXPackageInfoFromPathClassic {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    # Normalize path
    # $resolvedPath = (Resolve-Path -Path $Path -ErrorAction Stop).Path
    $resolvedPath = (Resolve-Path -Path $Path -ErrorAction Stop).ProviderPath

    # Split path
    $pathSplit = $resolvedPath -split "\\"

    $packageName = $pathSplit[-1]
    $product     = $pathSplit[-2]
    $company     = $pathSplit[-3]

    # Extract version
    $versionSplit = $packageName -split "_"

    if ($versionSplit.Count -gt 1) {
        $version = $versionSplit[-1]
    } else {
        $version = $null
    }

    $PackageInfo = [PSCustomObject]@{
        PackageName = $packageName
        Company     = $company
        Product     = $product
        Version     = $version
        FullPath    = $resolvedPath
    }

    return $PackageInfo
}

<#
Usage Example
$result = Get-PCXPackageInfoFromPathClassic -Path "\\192.168.25.214\Package_Source\Applications\Igor_Pavlov\7Zip\7Zip_26.0.0.0"

$result
$result.Company
#>

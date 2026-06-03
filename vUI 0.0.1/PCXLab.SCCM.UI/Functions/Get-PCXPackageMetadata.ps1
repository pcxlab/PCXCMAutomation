function Get-PCXPackageMetadata {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [string]$PackagePath
    )

    $PathParts =
        $PackagePath.Split(
            [System.IO.Path]::DirectorySeparatorChar
        )

    if ($PathParts.Count -lt 3) {

        throw "Unable to determine Company, Product and Version from path."
    }

    $Version =
        $PathParts[-1]

    $Product =
        $PathParts[-2]

    $Company =
        $PathParts[-3]

    $PackageName =
        "PKG $Company $Product $Version"

    return [PSCustomObject]@{

        Company     = $Company
        Product     = $Product
        Version     = $Version
        PackageName = $PackageName
    }
}
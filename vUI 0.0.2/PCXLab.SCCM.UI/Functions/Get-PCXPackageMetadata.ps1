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

    $Company =
        $PathParts[-3]

    $Product =
        $PathParts[-2]

    $PackageFolder =
        $PathParts[-1]

    #
    # Example:
    # Folder  = "7zip 26.0.2"
    # Product = "7zip"
    # Version = "26.0.2"
    #

    $Version =
        $PackageFolder.Replace(
            "$Product ",
            ""
        )

    $PackageName =
        "PKG $Company $Product $Version"

    [PSCustomObject]@{

        Company     = $Company
        Product     = $Product
        Version     = $Version
        PackageName = $PackageName
    }
}
function Get-PCXApplicationMetadata {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [string]$ApplicationPath
    )

    $PathParts =
        $ApplicationPath.Split(
            [System.IO.Path]::DirectorySeparatorChar
        )

    if ($PathParts.Count -lt 3) {

        throw "Unable to determine Company, Product and Version from path."
    }

    $Company = $PathParts[-3]

    $Product = $PathParts[-2]

    $ApplicationFolder = $PathParts[-1]

    #
    # Example:
    # Folder  = "7zip 26.0.2"
    # Product = "7zip"
    # Version = "26.0.2"
    #

    $Version =
        $ApplicationFolder.Replace(
            "$Product ",
            ""
        )

    $ApplicationName =
        "APP $Company $Product $Version"

    [PSCustomObject]@{
        
        Company     = $Company
        Product     = $Product
        Version     = $Version
        ApplicationName = $ApplicationName
    }
}
function Move-PCXCMPackageToFolder {

    param(
        [Parameter(Mandatory)]
        [pscustomobject]$meta
    )

    $PackageName = "PKG $($meta.Name)"

    $folder = "\Package\Application Installation\$($meta.Company)\$($meta.Product)"

    New-PCXCMFolder -Path $folder

    $packageObject = Get-CMPackage `
        -Name $PackageName `
        -Fast

    Move-PCXCMObject `
        -InputObject $packageObject `
        -FolderPath $folder

    Write-PCXLog "Moved Package: $PackageName"
}
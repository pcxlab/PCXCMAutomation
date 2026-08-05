function Move-PCXCMPackageToFolder {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [pscustomobject]$meta
    )

    begin {
        Write-PCXOperationStart
    }

    process {
        try {

            $PackageName = "PKG $($meta.Name)"

            $folder = "\Package\Application Installation\$($meta.Company)\$($meta.Product)"

            $null = New-PCXCMFolder -Path $folder

            #$PackageObject = Get-CMPackage -Name $PackageName -ErrorAction SilentlyContinue
            $PackageObject = Get-CMPackage -Name $PackageName -Fast -ErrorAction SilentlyContinue

            if (-not $PackageObject) {
                throw "Package not found: $PackageName"
            }

            Move-PCXCMObject -InputObject $PackageObject -FolderPath $folder

            Write-PCXLog "Moved Package: $PackageName"
        }
        catch {
            Write-PCXLog -Message "Failed to move package: $PackageName. $($_.Exception.Message)" -Level ERROR
            throw
        }
    }

    end {
        Write-PCXOperationEnd -Status Success
    }
}

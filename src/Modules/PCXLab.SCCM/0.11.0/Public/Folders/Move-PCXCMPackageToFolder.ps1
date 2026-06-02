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

            $packageObject = Get-CMPackage -Name $PackageName -Fast

            Move-PCXCMObject -InputObject $packageObject -FolderPath $folder

            Write-PCXLog "Moved Package: $PackageName"
        }
        catch {
            Write-PCXLog "Failed to move package: $PackageName. $($_.Exception.Message)" "ERROR"

            throw
        }
        
    }
    end {

        Write-PCXOperationEnd -Status Success
    }
}




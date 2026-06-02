function Move-PCXCMPackageToFolder {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [pscustomobject]$meta
    )

    begin {
        Write-PCXLog "BEGIN - PCXLab Automation"
    }
    process {
        try {
            $PackageName = "PKG $($meta.Name)"

            $folder = "\Package\Application Installation\$($meta.Company)\$($meta.Product)"

            New-PCXCMFolder -Path $folder

            $packageObject = Get-CMPackage -Name $PackageName -Fast

            Move-PCXCMObject -InputObject $packageObject -FolderPath $folder

            Write-PCXLog "Moved Package: $PackageName"
        }
        catch {
            Write-PCXLog "Failed to move package: $PackageName. $($_.Exception.Message)" "ERROR"
            throw
        }
        finally {
            Write-PCXLog "Move package operation completed: $PackageName"
        }
    }
    end {
        Write-PCXLog "END - www.pcxlab.com"
    }
}
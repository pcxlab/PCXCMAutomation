function Get-PCXCMPackageCleanupInfo {

    [CmdletBinding(DefaultParameterSetName = 'PackageName')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'PackageName')]
        [string]$PackageName,

        [Parameter(Mandatory, ParameterSetName = 'PackagePath')]
        [string]$PackagePath
    )

    begin {
        Write-PCXOperationStart
    }
    process {
        try {

            Ensure-PCXCMConnection

            $AllPackages = Get-PCXCMCachedPackage

            if ($PSCmdlet.ParameterSetName -eq 'PackageName') {
                $Package = $AllPackages | Where-Object { $_.Name -eq $PackageName } | Select-Object -First 1
            }
            else {
                $Package = $AllPackages | Where-Object { $_.PkgSourcePath -eq $PackagePath } | Select-Object -First 1
            }

            if (-not $Package) {
                throw "Package not found. (Name: $PackageName / Path: $PackagePath)"
            }

            if (@($Package).Count -gt 1) {
                throw "Multiple packages found for the given criteria."
            }

            $Package = $Package | Select-Object -First 1
            Write-PCXLog -Message "Resolved Package: $($Package.Name) [$($Package.PackageID)]"

            # Collections - use -Fast for performance # Fast will not work
            $Collections = Get-PCXCMCachedCollection |
            Where-Object {
                $_.Name -like "$($Package.Name)*"
            } |
            Sort-Object {
                switch -Regex ($_.Name) {
                    '\[INSTALL\]'   { 1; break }
                    '\[EXCLUDE\]'   { 2; break }
                    '\[UNINSTALL\]' { 3; break }
                    '\[AVAILABLE\]' { 4; break }
                    default         { 99 }
                }
            }

            Write-PCXLog -Message "Found $(@($Collections).Count) Collection(s)"

            # Collection Folder - use -Fast
            $CollectionFolder = Get-PCXCMCollectionFolder -Name $Package.Name

            if ($CollectionFolder) {
                Write-PCXLog -Message "Found Collection Folder: $($CollectionFolder.Name)"
            }
            else {
                Write-PCXLog -Message 'Collection Folder Not Found' -Level WARNING
            }

            return [PSCustomObject]@{
                Package            = $Package
                PackageID          = $Package.PackageID
                Collections        = $Collections
                CollectionFolder   = $CollectionFolder
                CollectionFolderID = if ($CollectionFolder) { $CollectionFolder.ContainerNodeID }
            }
        }
        catch {
            Write-PCXLog -Message "Failed to retrieve cleanup info: $($_.Exception.Message)" -Level ERROR
            throw
        }
    }
    end {
        Write-PCXOperationEnd
    }
}

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

            # Resolve Package
            if ($PSCmdlet.ParameterSetName -eq 'PackageName') {
                $Package = Get-CMPackage -Name $PackageName -Fast -ErrorAction Stop
            }
            else {
                $Package = Get-CMPackage -Fast |
                Where-Object {
                    $_.PkgSourcePath -eq $PackagePath
                }
            }

            if (-not $Package) {
                throw 'Package not found.'
            }

            if (@($Package).Count -gt 1) {
                throw 'Multiple packages found.'
            }

            Write-PCXLog -Message "Resolved Package: $($Package.Name)"

            # Collections
            #$Collections = Get-CMDeviceCollection -Name "$($Package.Name)*"
            $Collections = Get-CMDeviceCollection -Name "$($Package.Name)*" |
            Sort-Object {
                switch -Regex ($_.Name) {
                    '\[INSTALL\]' { 1; break }
                    '\[EXCLUDE\]' { 2; break }
                    '\[UNINSTALL\]' { 3; break }
                    '\[AVAILABLE\]' { 4; break }
                    default { 99 }
                }
            }

            Write-PCXLog -Message "Found $(@($Collections).Count) Collection(s)"

            # Collection Folder
            $CollectionFolder = Get-CMFolder -Name $Package.Name |
            Where-Object {
                $_.ObjectTypeName -eq 'SMS_Collection_Device'
            }

            if (@($CollectionFolder).Count -gt 1) {
                throw 'Multiple collection folders found.'
            }

            if ($CollectionFolder) {
                Write-PCXLog -Message "Found Collection Folder: $($CollectionFolder.Name)"
            }
            else {
                Write-PCXLog -Message 'Collection Folder Not Found' -Level WARNING
            }

            $CleanupInfo = [PSCustomObject]@{
                Package            = $Package
                PackageID          = $Package.PackageID
                Collections        = $Collections
                CollectionFolder   = $CollectionFolder
                CollectionFolderID = if ($CollectionFolder) { $CollectionFolder.ContainerNodeID }
            }

            return $CleanupInfo
        }
        catch {
            Write-PCXLog -Message $_.Exception.Message -Level ERROR
            throw
        }
    }
    end {
        Write-PCXOperationEnd
    }
}
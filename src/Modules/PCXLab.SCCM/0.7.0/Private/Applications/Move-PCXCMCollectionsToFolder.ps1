function Move-PCXCMCollectionsToFolder {

    param(

        [Parameter(Mandatory)]
        [pscustomobject]$Collections,

        [Parameter(Mandatory)]
        [pscustomobject]$meta,

        [Parameter(Mandatory)]
        [string]$ObjectName
    )

    $folder = "\DeviceCollection\Mphasis Application Deployment\$($meta.Company)\$($meta.Product)\$ObjectName"

    New-PCXCMFolder -Path $folder

    $collectionList = @(
        $Collections.Available,
        $Collections.Install,
        $Collections.Uninstall,
        $Collections.Exception
    )

    foreach ($collection in $collectionList) {

        if (-not $collection) {
            continue
        }

        $collectionObject = Get-CMDeviceCollection `
            -Name $collection

        Move-PCXCMObject `
            -InputObject $collectionObject `
            -FolderPath $folder

        Write-PCXLog "Moved Collection: $collection"
    }
}
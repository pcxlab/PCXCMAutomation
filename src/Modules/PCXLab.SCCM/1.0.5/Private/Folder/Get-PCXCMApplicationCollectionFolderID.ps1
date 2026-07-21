function Get-PCXCMApplicationCollectionFolderID {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $CollectionFolder
    )

    if (-not $CollectionFolder) {
        return $null
    }

    return $CollectionFolder.ContainerNodeID
}

function Get-PCXCMApplicationCollectionFolder {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Application
    )

    return Get-PCXCMCollectionFolder -Name $Application.LocalizedDisplayName
}

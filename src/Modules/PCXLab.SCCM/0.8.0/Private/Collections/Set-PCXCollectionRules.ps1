function Set-PCXCollectionRules {
    param(
        [Parameter(Mandatory)]
        [pscustomobject]$Collections
    )

    Add-CMDeviceCollectionIncludeMembershipRule `
        -CollectionName $Collections.Exception `
        -IncludeCollectionName $Collections.Uninstall

    Add-CMDeviceCollectionExcludeMembershipRule `
        -CollectionName $Collections.Install `
        -ExcludeCollectionName $Collections.Exception

    Write-PCXLog "Collection membership rules configured"
}

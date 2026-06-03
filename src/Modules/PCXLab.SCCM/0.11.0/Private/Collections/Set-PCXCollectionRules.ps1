function Set-PCXCollectionRules {
    param(
        [Parameter(Mandatory)]
        [pscustomobject]$Collections
    )
    
    $null = Add-CMDeviceCollectionIncludeMembershipRule -CollectionName $Collections.Exception -IncludeCollectionName $Collections.Uninstall
    $null = Add-CMDeviceCollectionExcludeMembershipRule -CollectionName $Collections.Install -ExcludeCollectionName $Collections.Exception
    Write-PCXLog "Collection membership rules configured"
}




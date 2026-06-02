function New-PCXCollections {

    param(
        [Parameter(Mandatory)]
        [pscustomobject]$Collections,

        [Parameter(Mandatory)]
        [string]$LimitingCollectionName
    )

    New-CMDeviceCollection -Name $Collections.Available -LimitingCollectionName $LimitingCollectionName
    New-CMDeviceCollection -Name $Collections.Install -LimitingCollectionName $LimitingCollectionName
    New-CMDeviceCollection -Name $Collections.Uninstall -LimitingCollectionName $LimitingCollectionName
    New-CMDeviceCollection -Name $Collections.Exception -LimitingCollectionName $LimitingCollectionName
    Write-PCXLog "Collections created"
}
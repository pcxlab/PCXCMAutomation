function New-PCXCollections {

    param(
        [Parameter(Mandatory)]
        [pscustomobject]$Collections,

        [Parameter(Mandatory)]
        [string]$LimitingCollectionName
    )

    begin {
        Write-PCXOperationStart
    }

    process {
        try {
            $null = New-CMDeviceCollection -Name $Collections.Available -LimitingCollectionName $LimitingCollectionName
            $null = New-CMDeviceCollection -Name $Collections.Install -LimitingCollectionName $LimitingCollectionName
            $null = New-CMDeviceCollection -Name $Collections.Uninstall -LimitingCollectionName $LimitingCollectionName
            $null = New-CMDeviceCollection -Name $Collections.Exception -LimitingCollectionName $LimitingCollectionName
            
            Write-PCXLog "Collections created"
        }
        catch {
            Write-PCXLog -Message "Failed to create collections. $($_.Exception.Message)" -Level ERROR
            throw
        }
    }

    end {
        Write-PCXOperationEnd
    }
}



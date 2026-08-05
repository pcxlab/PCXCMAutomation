function New-PCXCMDeploymentDeviceCollections {

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

            $null = Ensure-PCXCMConnection

            $CollectionNames = @(
                $Collections.Available,
                $Collections.Install,
                $Collections.Uninstall,
                $Collections.Exception
            )

            foreach ($CollectionName in $CollectionNames) {

                if (Test-PCXCMCollectionExists -CollectionName $CollectionName) {
                    Write-PCXLog -Message "Collection already exists: $CollectionName" -Level WARNING
                    continue
                }

                Write-PCXLog "Creating collection: $CollectionName"

                $null = New-CMDeviceCollection -Name $CollectionName -LimitingCollectionName $LimitingCollectionName
                Write-PCXLog "Collection created: $CollectionName"

                $null = Set-PCXCMCollectionRefreshType -CollectionName $CollectionName -RefreshType Manual
                Write-PCXLog "Refresh type set to Manual for collection: $CollectionName"
                
            }

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
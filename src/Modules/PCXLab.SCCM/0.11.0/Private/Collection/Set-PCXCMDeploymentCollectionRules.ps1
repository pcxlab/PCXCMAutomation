function Set-PCXCMDeploymentCollectionRules {
    param(
        [Parameter(Mandatory)]
        [pscustomobject]$Collections
    )

    begin {
        Write-PCXOperationStart
    }

    process {
        try {
            $null = Add-CMDeviceCollectionIncludeMembershipRule -CollectionName $Collections.Exception -IncludeCollectionName $Collections.Uninstall
            $null = Add-CMDeviceCollectionExcludeMembershipRule -CollectionName $Collections.Install -ExcludeCollectionName $Collections.Exception
            Write-PCXLog "Collection membership rules configured"
        }
        catch {
            Write-PCXLog -Message "Failed to configure collection rules. $($_.Exception.Message)" -Level ERROR
            throw
        }
    }

    end {
        Write-PCXOperationEnd
    }
}




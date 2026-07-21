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

            if (Test-PCXCMDefaultTestMachinesMembershipEnabled) {

                $CollectionName = Get-PCXCMDefaultTestMachinesCollection
            
                if (-not [string]::IsNullOrWhiteSpace($CollectionName)) {
            
                    Write-PCXLog "Adding default test machines collection '$CollectionName' to AVAILABLE collection."
            
                    $null = Add-CMDeviceCollectionIncludeMembershipRule `
                        -CollectionName $Collections.Available `
                        -IncludeCollectionName $CollectionName
                }
                else {
                    Write-PCXLog "Default Test Machines Collection is enabled but no collection name is configured." -Level Warning
                }
            }

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




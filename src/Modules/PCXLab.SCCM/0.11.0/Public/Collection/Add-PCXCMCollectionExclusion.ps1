function Add-PCXCMCollectionExclusion {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$SelectCollectionName,

        [Parameter(Mandatory = $true)]
        [string[]]$ExcludeCollectionNames
    )

    begin {

        Write-PCXOperationStart
    }

    process {

        try {

            $CollectionLookup = @{}

            Get-PCXCMCachedCollection | ForEach-Object {
                $CollectionLookup[$_.Name] = $_
            }

            $TargetCollection = $CollectionLookup[$SelectCollectionName]

            if (-not $TargetCollection) {
                throw "Collection not found: $SelectCollectionName"
            }

            foreach ($ExcludeCollectionName in $ExcludeCollectionNames) {

                try {

                    $ExcludeCollection = $CollectionLookup[$ExcludeCollectionName]

                    if ($ExcludeCollection) {

                        Write-PCXLog "Adding exclusion collection '$ExcludeCollectionName' to '$SelectCollectionName'"

                        $null = Add-CMDeviceCollectionExcludeMembershipRule `
                            -CollectionId $TargetCollection.CollectionId `
                            -ExcludeCollectionId $ExcludeCollection.CollectionId

                        Write-PCXLog "Exclusion collection added: $ExcludeCollectionName"
                    }
                    else {

                        Write-PCXLog "Exclude collection not found: $ExcludeCollectionName"
                    }
                }
                catch {

                    Write-PCXLog -Message "Failed to add exclusion collection '$ExcludeCollectionName' to '$SelectCollectionName'. $_" -Level ERROR
                }
            }
        }
        catch {
Write-PCXLog -Message "Failed to process exclusion collections for '$SelectCollectionName'. $_" -Level ERROR

            throw
        }
    }

    end {

        Write-PCXOperationEnd -Status Success
    }
}

<#
MS-Document :
https://learn.microsoft.com/en-us/powershell/module/configurationmanager/add-cmdevicecollectionexcludemembershiprule

Direct Command :
Add-CMDeviceCollectionExcludeMembershipRule -CollectionId $TargetCollection.CollectionId -ExcludeCollectionId $ExcludeCollection.CollectionId

Usage Example :
Add-PCXCMCollectionExclusion -SelectCollectionName "APP Igor Pavlov 7zip 26.0.2 [INSTALL]" -ExcludeCollectionNames "APP Igor Pavlov 7zip 26.0.2 [EXCEPTION]"

Usage Example (Multiple Collections) :
Add-PCXCMCollectionExclusion -SelectCollectionName "APP Igor Pavlov 7zip 26.0.2 [INSTALL]" -ExcludeCollectionNames @("CollectionA","CollectionB","CollectionC")
#>




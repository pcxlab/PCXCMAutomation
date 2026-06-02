function Add-PCXCMCollectionInclusion {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$SelectCollectionName,

        [Parameter(Mandatory = $true)]
        [string[]]$IncludeCollectionNames
    )

    begin {

        Write-PCXOperationStart
    }

    process {

        try {

            $TargetCollection = Get-CMDeviceCollection `
                -Name $SelectCollectionName `
                -ErrorAction SilentlyContinue

            if (-not $TargetCollection) {

                throw "Collection not found: $SelectCollectionName"
            }

            foreach ($IncludeCollectionName in $IncludeCollectionNames) {

                $IncludeCollection = Get-CMDeviceCollection `
                    -Name $IncludeCollectionName `
                    -ErrorAction SilentlyContinue

                if (-not $IncludeCollection) {

                    Write-PCXLog "Include collection not found: $IncludeCollectionName"
                    continue
                }

                Write-PCXLog "Adding inclusion collection '$IncludeCollectionName' to '$SelectCollectionName'"

                $null = Add-CMDeviceCollectionIncludeMembershipRule `
                    -CollectionId $TargetCollection.CollectionId `
                    -IncludeCollectionId $IncludeCollection.CollectionId

                Write-PCXLog "Inclusion collection added: $IncludeCollectionName"
            }
        }
        catch {
Write-PCXLog "Failed to add inclusion collections to '$SelectCollectionName'. $_" "ERROR"

            throw
        }
    }

    end {

        Write-PCXOperationEnd -Status Success
    }
}

<#
MS-Document :
https://learn.microsoft.com/en-us/powershell/module/configurationmanager/add-cmdevicecollectionincludemembershiprule

Direct Command :
Add-CMDeviceCollectionIncludeMembershipRule -CollectionId $TargetCollection.CollectionId -IncludeCollectionId $IncludeCollection.CollectionId

Usage Example :
Add-PCXCMCollectionInclusion -SelectCollectionName "APP Igor Pavlov 7zip 26.0.2 [INSTALL]" -IncludeCollectionNames "APP Igor Pavlov 7zip 26.0.2 [AVAILABLE]"

Usage Example (Multiple Collections) :
Add-PCXCMCollectionInclusion -SelectCollectionName "APP Igor Pavlov 7zip 26.0.2 [INSTALL]" -IncludeCollectionNames @("CollectionA","CollectionB","CollectionC")
#>



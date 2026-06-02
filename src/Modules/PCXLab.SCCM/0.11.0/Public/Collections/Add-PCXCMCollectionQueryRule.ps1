function Add-PCXCMCollectionQueryRule {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$CollectionName,

        [Parameter(Mandatory = $true)]
        [string]$QueryExpression,

        [Parameter(Mandatory = $true)]
        [string]$RuleName
    )

    begin {

        Write-PCXOperationStart
    }

    process {

        try {

            $ExistingCollection = Get-CMDeviceCollection `
                -Name $CollectionName `
                -ErrorAction SilentlyContinue

            if (-not $ExistingCollection) {

                throw "Collection not found: $CollectionName"
            }

            Write-PCXLog "Adding query rule '$RuleName' to collection: $CollectionName"

            $null = Add-CMDeviceCollectionQueryMembershipRule `
                -CollectionName $CollectionName `
                -QueryExpression $QueryExpression `
                -RuleName $RuleName

            Write-PCXLog "Query rule added: $RuleName"
        }
        catch {
Write-PCXLog "Failed to add query rule '$RuleName' to collection '$CollectionName'. $_" "ERROR"

            throw
        }
    }

    end {

        Write-PCXOperationEnd -Status Success
    }
}

<#
MS-Document :
https://learn.microsoft.com/en-us/powershell/module/configurationmanager/add-cmdevicecollectionquerymembershiprule

Direct Command :
Add-CMDeviceCollectionQueryMembershipRule -CollectionName $CollectionName -QueryExpression $QueryExpression -RuleName $RuleName

Usage Example :
Add-PCXCMCollectionQueryRule -CollectionName "APP Igor Pavlov 7zip 26.0.2 [INSTALL]" -RuleName "Installed Devices" -QueryExpression "select SMS_R_SYSTEM.ResourceID from SMS_R_System"
#>



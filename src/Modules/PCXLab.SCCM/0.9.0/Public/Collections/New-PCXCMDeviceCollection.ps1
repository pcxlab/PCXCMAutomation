function New-PCXCMDeviceCollection {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$CollectionName,            

        [parameter(Mandatory = $false, Position = 1)]
        [string]$LimitingCollection = "All Systems"
    )
    
    begin {
        Write-PCXLog "BEGIN - PCXLab Automation"
    }

    process {
        try {

            $existingCollection = Get-CMDeviceCollection -Name $CollectionName -ErrorAction SilentlyContinue     

            if ($existingCollection) {
                throw "Device collection already exists: $CollectionName"
            }

            Write-PCXLog "Creating device collection: $CollectionName"
           
            $null = New-CMDeviceCollection `
                -Name $CollectionName `
                -LimitingCollectionName $LimitingCollection
    
            Write-PCXLog "Device collection created: $CollectionName"
        }
        catch {
            Write-PCXLog "Failed to create device collection: $CollectionName. $_"
            throw
        }

        finally {
            Write-PCXLog "Device collection operation completed: $CollectionName"
        }
    }

    end {
        Write-PCXLog "END - www.pcxlab.com"
    }
}  

<# 
MS-Document : 
 https://learn.microsoft.com/en-us/powershell/module/configurationmanager/new-cmdevicecollection?view=sccm-ps

 Direct Command :
New-CMDeviceCollection -Name "PKG_7zip_2.0.0_01[Install]" -LimitingCollectionName "All Systems"

Usage example :
New-PCXCMDeviceCollection -CollectionName "PKG_7zip_2.0.0_01[Install]"
New-PCXCMDeviceCollection -CollectionName "PKG_7zip_2.0.0_01[Available]"
New-PCXCMDeviceCollection -CollectionName "PKG_7zip_2.0.0_01[UnInstall]"
New-PCXCMDeviceCollection -CollectionName "PKG_7zip_2.0.0_01[Exception]"
 #>

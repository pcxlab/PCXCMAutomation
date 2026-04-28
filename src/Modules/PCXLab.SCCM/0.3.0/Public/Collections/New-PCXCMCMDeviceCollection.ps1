function New-PCXCMCMDeviceCollection{
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$CollectionName,            

        [parameter(Mandatory=$false, Position=1)]
        [string]$LimitingCollection = "All Systems"
    )
    
    begin {
        Write-Host "Welcome to PCXLab automation" -ForegroundColor Yellow
    }

    process {
                try {
                    Write-Host "Now we are going to create collection $CollectionName" -ForegroundColor Yellow
                    New-CMDeviceCollection -Name $CollectionName -LimitingCollectionName $LimitingCollection
                    Write-Host "Collection $CollectionName is created." -ForegroundColor Green
                    Write-Host "We tried and successfuly Created................."  -ForegroundColor Magenta
                }
                catch {
                    Write-Host $_ -ForegroundColor Red
                }

                finally {
                    <#Do this after the try block regardless of whether an exception occurred or not#>
                    Write-Host "This is finaly block runs even for success and even for failure" -ForegroundColor Cyan
                }
    }

    end {
        Write-Host "Thank you - www.pcxlab.com " -ForegroundColor Yellow

    }
}  

<# 
MS-Document : 
 https://learn.microsoft.com/en-us/powershell/module/configurationmanager/new-cmdevicecollection?view=sccm-ps

 Direct Command :
New-CMDeviceCollection -Name "PKG_7zip_2.0.0_01[Install]" -LimitingCollectionName "All Systems"

Usage example :
 New-CMDeviceCollection -CollectionName "PKG_7zip_2.0.0_01[Install]" 
 New-CMDeviceCollection -CollectionName "PKG_7zip_2.0.0_01[Available]" 
 New-CMDeviceCollection -CollectionName "PKG_7zip_2.0.0_01[UnInstall]" 
 New-CMDeviceCollection -CollectionName "PKG_7zip_2.0.0_01[Exception]" 
 #>

function New-PCXCMApplicationDeploymentType {
    param(
        [parameter(mandatory=$true, Position=0)] 
        [string] $Name,

        [parameter(mandatory=$true, Position=1)]
         [string] $InstallationFileLocation   
    )
    begin {
        Write-Host "Welcome to PCXLab automation" -ForegroundColor Yellow
    }

    process {
                try {
                    Write-Host "We are adding new DeploymentType : $Name " -ForegroundColor Yellow
                    Add-CMMsiDeploymentType -ApplicationName "$Name" -InstallationFileLocation $InstallationFileLocation -ForceForUnknownPublisher  
                    Write-Host "DeploymentType is created." -ForegroundColor Green
                    Write-Host "We tried and successfuly created................."  -ForegroundColor Magenta
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
https://learn.microsoft.com/en-us/powershell/module/configurationmanager/add-cmdeploymenttype?view=sccm-ps

Direct Command :
Add-CMMsiDeploymentType -ApplicationName "APS_7zip_26.0.1" -InstallationFileLocation "\\192.168.25.214\Package_Source\Applications\Igor_Pavlov\7zip_msi\7zip_26.0.0\7z2600-x64.msi" -ForceForUnknownPublisher

Usage example :
New-PCXCMApplicationDeploymentType  -name "APS_7zip_26.0.1" -InstallationFileLocation "\\192.168.25.214\Package_Source\Applications\Igor_Pavlov\7Zip_msi\7zip_26.0.0\7z2600-x64.msi" 
New-PCXCMApplicationDeploymentType  -name "APS_7zip_26.0.1" -InstallationFileLocation "\\192.168.25.214\Package_Source\Applications\Igor_Pavlov\7Zip_msi\7zip_26.0.0\7z2600-x64.msi" 
#>













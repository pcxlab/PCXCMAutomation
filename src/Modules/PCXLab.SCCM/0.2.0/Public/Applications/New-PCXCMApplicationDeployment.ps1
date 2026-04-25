function New-PCXCMApplicationDeployment{
    param (
        [parameter(mandatory=$true, Position=0)]
        [string]$Name,

        [parameter(Mandatory=$true, Position=1)] 
        [DateTime]$Availabledatetime,

        [parameter(Mandatory=$true, Position=2)]
        [string]$Collectionname,

        [parameter(Mandatory=$true, Position=3)] 
        [DateTime]$Deadlinedatetime,

        [parameter(Mandatory=$true, Position=4)] 
        [string]$Action,

        [parameter(Mandatory=$true, Position=5)] 
        [string]$Purpose
    )
    begin {
        Write-Host "Welcome to PCXLab automation" -ForegroundColor Yellow
    }

    process {
                try {
                    Write-Host "We are creating new Application Deployment : $Name " -ForegroundColor Yellow
                    New-CMApplicationDeployment -Name "$Name" -AvailableDateTime "$Availabledatetime" -CollectionName $Collectionname  -DeadlineDateTime $Deadlinedatetime -DeployAction $Action -DeployPurpose $Purpose
                    Write-Host "Application Deployment $Name is created." -ForegroundColor Green
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
https://learn.microsoft.com/en-us/powershell/module/configurationmanager/new-cmapplicationdeployment?view=sccm-ps

Direct Command :
New-CMApplicationDeployment -Name "$Name" -AvailableDateTime "$Availabledatetime" -CollectionName $Collectionname  -DeadlineDateTime $Deadlinedatetime -DeployAction $Action -DeployPurpose $Purpose
New-CMApplicationDeployment -Name "APS_7zip_26.0.1" -AvailableDateTime "23/04/2026 00:00:00" -CollectionName "PKG_7zip_2.0.0_01[Available]"  -DeadlineDateTime "23/04/2026 00:00:00" -DeployAction "Install" -DeployPurpose "Available"
New-CMApplicationDeployment -Name "APS_7zip_26.0.1" -CollectionName "PKG_7zip_2.0.0_01[Available]" -AvailableDateTime (Get-Date "2026-04-23 00:00:00") -DeadlineDateTime (Get-Date "2026-04-23 00:00:00") -DeployAction Install -DeployPurpose Required

Usage example : 
New-PCXCMApplicationDeployment -Name "APS_7zip_26.0.1" -AvailableDateTime '21/04/2026 00:00:00' -Collectionname 'PKG_7zip_2.0.0_01[Available]' -DeadlineDateTime '22/04/2026 00:00:00' -Action "Install" -Purpose "Available"
New-PCXCMApplicationDeployment -Name "APS_7zip_26.0.1" -AvailableDateTime '21/04/2026 00:00:00' -Collectionname 'PKG_7zip_2.0.0_01[Install]' -DeadlineDateTime '22/04/2026 00:00:00' -Action "Install" -Purpose "Required"
New-PCXCMApplicationDeployment -Name "APS_7zip_26.0.1" -AvailableDateTime '21/04/2026 00:00:00' -Collectionname 'PKG_7zip_2.0.0_01[UnInstall]' -DeadlineDateTime '22/04/2026 00:00:00' -Action "Uninstall" -Purpose "Required"
#>


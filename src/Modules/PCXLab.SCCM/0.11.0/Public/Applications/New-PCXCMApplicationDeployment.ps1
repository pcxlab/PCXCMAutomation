function New-PCXCMApplicationDeployment {
    param (
        [parameter(mandatory = $true, Position = 0)]
        [string]$Name,

        [parameter(Mandatory = $true, Position = 1)] 
        [DateTime]$AvailableDateTime,

        [parameter(Mandatory = $true, Position = 2)]
        [string]$CollectionName,

        [parameter(Mandatory = $true, Position = 3)] 
        [DateTime]$DeadlineDateTime,

        [Parameter(Mandatory = $true, Position = 4)]
        [ValidateSet("Install", "Uninstall")]
        [string]$Action,

        [Parameter(Mandatory = $true, Position = 5)]
        [ValidateSet("Available", "Required")]
        [string]$Purpose
    )
    begin {

        Write-PCXOperationStart
    }

    process {
        try {

            Write-PCXLog "Creating application deployment: $Name"
            Write-PCXLog "Collection : $CollectionName"
            Write-PCXLog "Purpose : $Purpose"
            Write-PCXLog "Action : $Action"

            if ($Purpose -eq "Available") {

                $null = New-CMApplicationDeployment `
                    -Name $Name `
                    -AvailableDateTime $AvailableDateTime `
                    -CollectionName $CollectionName `
                    -DeployAction $Action `
                    -DeployPurpose $Purpose
            }
            else {

                $null = New-CMApplicationDeployment `
                    -Name $Name `
                    -AvailableDateTime $AvailableDateTime `
                    -CollectionName $CollectionName `
                    -DeadlineDateTime $DeadlineDateTime `
                    -DeployAction $Action `
                    -DeployPurpose $Purpose
            }

            Write-PCXLog "Application deployment created: $Name"
        }
        catch {
            Write-PCXLog -Message "Failed to create application deployment: $Name. $($_.Exception.Message)" -Level ERROR
            throw
        }
    }
    end {
        Write-PCXOperationEnd -Status Success
    }
}

<#
MS-Document :
https://learn.microsoft.com/en-us/powershell/module/configurationmanager/new-cmapplicationdeployment?view=sccm-ps

Direct Command :

New-CMApplicationDeployment -Name $Name -AvailableDateTime $AvailableDateTime -CollectionName $CollectionName -DeadlineDateTime $DeadlineDateTime -DeployAction $Action -DeployPurpose $Purpose
New-CMApplicationDeployment -Name "APS_7zip_26.0.1" -AvailableDateTime "2026-04-23 00:00:00" -CollectionName "PKG_7zip_2.0.0_01[Available]" -DeadlineDateTime "2026-04-23 00:00:00" -DeployAction Install -DeployPurpose Available
New-CMApplicationDeployment -Name "APS_7zip_26.0.1" -CollectionName "PKG_7zip_2.0.0_01[Available]" -AvailableDateTime (Get-Date "2026-04-23 00:00:00") -DeadlineDateTime (Get-Date "2026-04-23 00:00:00") -DeployAction Install -DeployPurpose Required

Usage Examples :
New-PCXCMApplicationDeployment -Name "APS_7zip_26.0.1" -AvailableDateTime "2026-04-21 00:00:00" -CollectionName "APS_7zip_26.0.1" -DeadlineDateTime "2026-04-22 00:00:00" -Action Install -Purpose Available
New-PCXCMApplicationDeployment -Name "APS_7zip_26.0.1" -AvailableDateTime "2026-04-21 00:00:00" -CollectionName "PKG_7zip_2.0.0_01[Available]" -DeadlineDateTime "2026-04-22 00:00:00" -Action Install -Purpose Available
New-PCXCMApplicationDeployment -Name "APS_7zip_26.0.1" -AvailableDateTime "2026-04-21 00:00:00" -CollectionName "PKG_7zip_2.0.0_01[Install]" -DeadlineDateTime "2026-04-22 00:00:00" -Action Install -Purpose Required
New-PCXCMApplicationDeployment -Name "APS_7zip_26.0.1" -AvailableDateTime "2026-04-21 00:00:00" -CollectionName "PKG_7zip_2.0.0_01[UnInstall]" -DeadlineDateTime "2026-04-22 00:00:00" -Action Uninstall -Purpose Required
#>









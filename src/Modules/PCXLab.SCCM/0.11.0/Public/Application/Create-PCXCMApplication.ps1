function Create-PCXCMApplication {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Path,
        [string]$Language = "EN-US",
        [string]$DPGroup = "All Mangalore Dps",
        [string]$LimitingCollectionName = "ALL Systems",
        [string]$AvailableDateTime = (Get-Date -Format 'yyyy-MM-dd 00:00:00'),
        [string]$DeadlineDateTime = ((Get-Date).AddDays(1).ToString('yyyy-MM-dd 00:00:00'))
    )

    begin {
        Write-PCXOperationStart
    }
    process {
        $OriginalLocation = Get-Location
        try {
            Ensure-PCXCMConnection
        
            # Validate source path and enumerate files
            $files = Test-PCXPackagePath $Path
            $installer = Get-PCXInstaller $files
            $meta = Get-PCXMetadataFromPath $Path

            $ApplicationName = "APP $($meta.Name)"
            $Collections = Get-PCXCollectionNames -PackageName $ApplicationName
        
            Write-PCXLog "Application: $ApplicationName"
            Write-PCXLog "Publisher  : $($meta.Company)"
            Write-PCXLog "Version    : $($meta.Version)"
            Write-PCXLog "Installer  : $($installer.Name)"

            # Step 1 - Collections
            New-PCXCollections -Collections $Collections -LimitingCollectionName $LimitingCollectionName

            # Step 2 - Icon Detection
            $IconFile = $files | Where-Object { $_.Extension -match '\.(png|ico|jpg|jpeg)$' } | Select-Object -First 1

            if (-not $IconFile) {
                Write-PCXLog -Message "No icon file found. Proceeding without icon." -Level WARNING
            }

            # Step 3 - Create Application
            New-PCXCMApplication `
                -Name $ApplicationName `
                -Description "New Application" `
                -Publisher $meta.Company `
                -SoftwareVersion $meta.Version `
                -ReleaseDate (Get-Date) `
                -Iconlocationfile $(if ($IconFile) { $IconFile.FullName })

            # Step 4 - Create Deployment Type
            $null = New-PCXCMApplicationDeploymentType -Name $ApplicationName -InstallationFileLocation $installer.FullName

            # Step 5 - Requirements
            $OSValidateSetPath = Join-Path $PSScriptRoot "..\..\Config\OSValidateSet.csv"
            if (Test-Path $OSValidateSetPath) {
                $null = Add-PCXCMApplicationOSRequirement `
                    -ApplicationName $ApplicationName `
                    -Requirement "All Windows 11 (64-bit)" `
                    -OSValidateSetPath $OSValidateSetPath `
                    -AllowRequirementCreation
            }
            else {
                Write-PCXLog "OS validation set not found. Skipping OS requirement." -Level WARNING
            }

            $null = Add-PCXDiskSpaceRequirementToDeploymentType -ApplicationName $ApplicationName -MinimumDiskSpaceMB 5120
            $null = Add-PCXMemoryRequirementToDeploymentType -ApplicationName $ApplicationName -MinimumMemoryMB 4096

            # Step 6 - Content Distribution
            $null = Start-PCXCMContentDistribution -ApplicationName $ApplicationName -DistributionPointGroupName $DPGroup

            # Step 7 - Deployments
            $DeploymentParams = @{
                Name              = $ApplicationName
                AvailableDateTime = $AvailableDateTime
                DeadlineDateTime  = $DeadlineDateTime
            }

            New-PCXCMApplicationDeployment @DeploymentParams -CollectionName $Collections.Available -Action Install -Purpose Available
            New-PCXCMApplicationDeployment @DeploymentParams -CollectionName $Collections.Install -Action Install -Purpose Required
            New-PCXCMApplicationDeployment @DeploymentParams -CollectionName $Collections.Uninstall -Action Uninstall -Purpose Required

            # Step 8 - Finalize
            Set-PCXCollectionRules -Collections $Collections
            $null = Move-PCXCMCollectionsToFolder -Collections $Collections -meta $meta -ObjectName $ApplicationName
            $null = Move-PCXCMApplicationToFolder -meta $meta

            Write-PCXLog "SUCCESS: $ApplicationName"
        }
        catch {
            Write-PCXLog -Message "FAILED: $($_.Exception.Message)" -Level ERROR
            throw
        }
        finally {
            try { Set-Location $OriginalLocation } catch { }
        }
    }
    end {
        Write-PCXOperationEnd
    }
}

#
#Create-PCXApplication -Path "\\192.168.25.214\Package_Source\Applications\Igor Pavlov\7zip\7zip 26.0.0"
#Create-PCXApplication -Path "\\192.168.25.214\Package_Source\Applications\Igor Pavlov\7zip\7zip 26.0.2"
#Create-PCXApplication -Path "\\192.168.25.214\Package_Source\Applications\Google\Chrome\Google Chrome 145.0.7632.46"

<# Reproduce case

Remove-CMApplicationDeployment -Name "APP Igor Pavlov 7zip 26.0.0" -Force
Remove-CMDeviceCollection -Name "APP Igor Pavlov 7zip 26.0.0" -Force

Remove-CMDeviceCollection -Name "APP Igor Pavlov 7zip 26.0.0 [AVAILABLE]" -Force   
Remove-CMDeviceCollection -Name "APP Igor Pavlov 7zip 26.0.0 [INSTALL]" -Force   
Remove-CMDeviceCollection -Name "APP Igor Pavlov 7zip 26.0.0 [UNINSTALL]" -Force   
Remove-CMDeviceCollection -Name "APP Igor Pavlov 7zip 26.0.0 [EXCEPTION]" -Force  

Remove-CMApplicationDeployment -Name "APP Igor Pavlov 7zip 26.0.0" -Force
Remove-CMDeviceCollection -Name "APP Igor Pavlov 7zip 26.0.0" -Force

Remove-CMDeviceCollection -Name "APP Igor Pavlov 7zip 26.0.0 [AVAILABLE]" -Force   
Remove-CMDeviceCollection -Name "APP Igor Pavlov 7zip 26.0.0 [INSTALL]" -Force   
Remove-CMDeviceCollection -Name "APP Igor Pavlov 7zip 26.0.0 [UNINSTALL]" -Force   
Remove-CMDeviceCollection -Name "APP Igor Pavlov 7zip 26.0.0 [EXCEPTION]" -Force  


Remove-CMApplicationDeployment -Name "APP Igor Pavlov 7zip 26.0.0" -Force

If you get below error delete the deployment first.
PS PS1:\> Remove-CMApplication -Name "APP Igor Pavlov 7zip 26.0.0" -Force
Remove-CMApplication : Configuration Manager cannot delete this application because other 
applications or task sequences reference it or it is configured as a deployment.
        Details:
        Number of dependent applications: 0
        Number of active deployments: 1
        Number of dependent task sequences: 0 
        Number of virtual environments:0
        To view the dependent applications, open the application properties and then click the 
References tab from the console. 
        To view the active deployments, select the application and then select the Deployments 
tab from the console.
At line:1 char:1
+ Remove-CMApplication -Name "APP Igor Pavlov 7zip 26.0.0" -Force
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidResult: (Microsoft.Confi...moveApplication:RemoveApplicati 
   on) [Remove-CMApplication], InvalidOperationException
    + FullyQualifiedErrorId : UnableToDeleteApplication,Microsoft.ConfigurationManagement.Power 
   Shell.Cmdlets.AppMan.RemoveApplication


Remove-CMApplication -Name "APP Igor Pavlov 7zip 26.0.0" -Force   

If you get below error wait for 120minue and close console if opened if still nto working you amy need to try reboot wiln ot how

Remove-CMApplication : ConfigMgr Error Object:
instance of SMS_ExtendedStatus
{
        Description = "User PCXLAB\\Administrator is not able to get the lock at this time. Error: 
0x40480732";
        ErrorCode = 1078462258;
        File = "F:\\dbs\\sh\\cmgm\\0326_183130\\cmd\\d\\src\\SiteServer\\SDK_Provider\\SMSProv\\ssputil
ity.cpp";
        Line = 3355;
        ObjectInfo = "CObjectLock";
        Operation = "ExecMethod";
        ParameterInfo = "SMS_Application.CI_ID=16777600";
        ProviderName = "WinMgmt";
        StatusCode = 2147749889;
};
At line:1 char:1
+ Remove-CMApplication -Name "APP Igor Pavlov 7zip 26.0.0" -Force
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (Microsoft.Confi...moveApplication:RemoveApplicatio 
   n) [Remove-CMApplication], WqlQueryException
    + FullyQualifiedErrorId : UnhandledException,Microsoft.ConfigurationManagement.PowerShell.C 
   mdlets.AppMan.RemoveApplication

#>



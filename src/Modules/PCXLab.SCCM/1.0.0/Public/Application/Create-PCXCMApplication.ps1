function Create-PCXCMApplication {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Path,
        [string]$Language = "EN-US",
        [string[]]$DistributionPointGroups, # Array Difined
        [string[]]$DistributionPoints, # Array Difined
        [string]$LimitingCollectionName = (Get-PCXCMDefaultLimitingCollection),
        [string]$AvailableDateTime = (Get-Date -Format 'yyyy-MM-dd 00:00:00'),
        [string]$DeadlineDateTime = ((Get-Date).AddDays(1).ToString('yyyy-MM-dd 00:00:00')),
        [string]$ReferenceNumber,
        [string]$ReviewerName,
        [string]$Comments
    )

    begin {
        Write-PCXOperationStart
    }
    process {
        $OriginalLocation = Get-Location
        try {
            Ensure-PCXCMConnection
        
            # Validate source path and enumerate files
            $Files = Test-PCXPackagePath $Path
            $Installer = Get-PCXCMPackageInstaller $Files
            $Meta = Get-PCXMetadataFromPath $Path

            $ApplicationName = "APP $($Meta.Name)"
            $Collections = New-PCXCMDeploymentCollectionNames -ObjectName $ApplicationName
        
            Write-PCXLog "Application: $ApplicationName"
            Write-PCXLog "Publisher  : $($Meta.Company)"
            Write-PCXLog "Version    : $($Meta.Version)"
            Write-PCXLog "Installer  : $($Installer.Name)"
            
            Write-PCXLog "Ticket Reference Number is : $ReferenceNumber"
            Write-PCXLog "Reviewer Name is : $ReviewerName"
            Write-PCXLog "Comments is : $Comments"

            # Icon Detection
            $IconFile = $Files | Where-Object { $_.Extension -match '\.(png|ico|jpg|jpeg)$' } | Select-Object -First 1

            if (-not $IconFile) {
                Write-PCXLog -Message "No icon file found. Proceeding without icon." -Level WARNING
            }

            # Step 1 - Create Application
            #$Application = New-PCXCMApplication -ApplicationName $ApplicationName -Description $ApplicationName -Publisher $Meta.Company -SoftwareVersion $Meta.Version -ReleaseDate (Get-Date) -Iconlocationfile $(if ($IconFile) { $IconFile.FullName })
            $null = New-PCXCMApplication -ApplicationName $ApplicationName -Description $ApplicationName -Publisher $Meta.Company -SoftwareVersion $Meta.Version -ReleaseDate (Get-Date) -Iconlocationfile $(if ($IconFile) { $IconFile.FullName })

            # Step 2 - Add Deployment Type
            New-PCXCMApplicationDeploymentType -Name $ApplicationName -InstallationFileLocation $Installer.FullName

            # Step 3 - Content Distribution
            $null = Start-PCXCMContentDistribution `
                -ApplicationName $ApplicationName `
                -DistributionPointGroups $DistributionPointGroups `
                -DistributionPoints $DistributionPoints

            # Step 4 - Add Requirements to the Deployment Type
            $OSValidateSetPath = Join-Path $PSScriptRoot "..\..\Config\OSValidateSet.csv"
            if (Test-Path $OSValidateSetPath) {
                $null = Add-PCXCMApplicationOSRequirement -ApplicationName $ApplicationName -Requirement "All Windows 11 (64-bit)" -OSValidateSetPath $OSValidateSetPath -AllowRequirementCreation
            }
            else {
                Write-PCXLog "OS validation set not found. Skipping OS requirement." -Level WARNING
            }

            $null = Add-PCXCMApplicationDiskSpaceRequirementToDeploymentType -ApplicationName $ApplicationName -MinimumDiskSpaceMB 5120
            $null = Add-PCXCMApplicationMemoryRequirementToDeploymentType -ApplicationName $ApplicationName -MinimumMemoryMB 4096

            # Step 5 - Collections
            New-PCXCMDeploymentDeviceCollections -Collections $Collections -LimitingCollectionName $LimitingCollectionName

            # Step 6 - Deployments
            $DeploymentParams = @{
                Name              = $ApplicationName
                AvailableDateTime = $AvailableDateTime
                DeadlineDateTime  = $DeadlineDateTime
            }

            New-PCXCMApplicationDeployment @DeploymentParams -CollectionName $Collections.Available -Action Install -Purpose Available
            New-PCXCMApplicationDeployment @DeploymentParams -CollectionName $Collections.Install -Action Install -Purpose Required
            New-PCXCMApplicationDeployment @DeploymentParams -CollectionName $Collections.Uninstall -Action Uninstall -Purpose Required

            # Step 7 - Add Collection Rules
            $null = Set-PCXCMDeploymentCollectionRules -Collections $Collections

            # Step 8 - Collection Movement to folders
            $null = Move-PCXCMCollectionsToFolder -Collections $Collections -Meta $Meta -ObjectName $ApplicationName

            # Step 9 - Application Movement to folders
            $null = Move-PCXCMApplicationToFolder -Meta $Meta

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




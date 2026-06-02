<#
Remove-Module PCXLab.Core -Force
Remove-Module PCXLab.SCCM -Force

Import-Module .\src\Modules\PCXLab.Core -Force
Import-Module .\src\Modules\PCXLab.SCCM -Force

Get-Command -Module PCXLab.Core
Get-Command -Module PCXLab.SCCM
#>

if (-not (Test-Path "C:\Temp")) {
    New-Item -Path "C:\Temp" -ItemType Directory | Out-Null
}

$script:Config = @{
    LogPath    = "C:\Temp\PCX.log"
    RetryCount = 3
    RetryDelay = 5
}

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
        try {
            Ensure-PCXCMConnection
        
            # Validate source path
            $files = Test-PCXPackagePath $Path

            # Detect installer
            $installer = Get-PCXInstaller $files

            # Extract metadata
            $meta = Get-PCXMetadataFromPath $Path

            $ApplicationName = "APP $($meta.Name)"

            $Collections = Get-PCXCollectionNames -PackageName $ApplicationName
        
            New-PCXCollections -Collections $Collections -LimitingCollectionName $LimitingCollectionName

            # Find icon file
            $IconFile = $files |
            Where-Object {
                $_.Extension -match '\.(png|ico|jpg|jpeg)$'
            } |
            Select-Object -First 1

            if (-not $IconFile) {
                Write-PCXLog "No icon file found. Application will be created without icon." "WARN"
            }

            Write-PCXLog "Application Name : $ApplicationName"
            Write-PCXLog "Publisher        : $($meta.Company)"
            Write-PCXLog "Version          : $($meta.Version)"
            Write-PCXLog "Installer        : $($installer.Name)"

            # Step 1 - Create Application
            New-PCXCMApplication `
                -Name $ApplicationName `
                -Description "New Application" `
                -Publisher $meta.Company `
                -SoftwereVersion $meta.Version `
                -ReleaseDate (Get-Date) `
                -Iconlocationfile $IconFile.FullName

            # Step 2 - Create Deployment Type
            $null = New-PCXCMApplicationDeploymentType -Name $ApplicationName -InstallationFileLocation $installer.FullName

            # Step 2.1 - Add Windows 11 Requirement
            $OSValidateSetPath = Join-Path $PSScriptRoot "..\..\Config\OSValidateSet.csv"

            $OSValidateSetPath = (Resolve-Path $OSValidateSetPath).Path

            $null = Add-PCXCMApplicationOSRequirement `
                -ApplicationName $ApplicationName `
                -Requirement "All Windows 11 (64-bit)" `
                -OSValidateSetPath $OSValidateSetPath `
                -AllowRequirementCreation

            Write-PCXLog "Windows 11 requirement added"

            # Step 2.2 - Add Disk Space Requirement
            $null = Add-PCXDiskSpaceRequirementToDeploymentType -ApplicationName $ApplicationName -MinimumDiskSpaceMB 20480

            Write-PCXLog "Disk space requirement added"

            # Step 2.3 - Add Memory Requirement
            $null = Add-PCXMemoryRequirementToDeploymentType -ApplicationName $ApplicationName -MinimumMemoryMB 4096

            Write-PCXLog "Memory requirement added"

            # Step 3 - Distribute Content
            $null = Start-PCXCMContentDistribution -ApplicationName $ApplicationName -DistributionPointGroupName $DPGroup

            # Step 5 - Deploy Application
            $null = New-PCXCMApplicationDeployment `
                -Name $ApplicationName `
                -AvailableDateTime $AvailableDateTime `
                -CollectionName $Collections.Available `
                -DeadlineDateTime $DeadlineDateTime `
                -Action Install `
                -Purpose Available

            $null = New-PCXCMApplicationDeployment `
                -Name $ApplicationName `
                -AvailableDateTime $AvailableDateTime `
                -CollectionName $Collections.Install `
                -DeadlineDateTime $DeadlineDateTime `
                -Action Install `
                -Purpose Required

            $null = New-PCXCMApplicationDeployment `
                -Name $ApplicationName `
                -AvailableDateTime $AvailableDateTime `
                -CollectionName $Collections.Uninstall `
                -DeadlineDateTime $DeadlineDateTime `
                -Action Uninstall `
                -Purpose Required

            Set-PCXCollectionRules -Collections $Collections
        
            $null = Move-PCXCMCollectionsToFolder -Collections $Collections -meta $meta -ObjectName $ApplicationName

            $null = Move-PCXCMApplicationToFolder -meta $meta

            Write-PCXLog "SUCCESS: $ApplicationName"

            <#
            return [PSCustomObject]@{
                Success         = $true
                ApplicationName = $ApplicationName
                Publisher       = $meta.Company
                Version         = $meta.Version
                Installer       = $installer.Name
                SourcePath      = $Path
            }
            #>
        }
        catch {
            Write-PCXLog "FAILED: $($_.Exception.Message)" "ERROR"
            throw
        }
    }
    end {
        Write-PCXOperationEnd -Status Success
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


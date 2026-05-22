
Import-Module .\src\Modules\PCXLab.Core -Force
Import-Module .\src\Modules\PCXLab.SCCM -Force

Get-Command -Module PCXLab.Core
Get-Command -Module PCXLab.SCCM


<#
Create-PCXApplication
│
├─ Test-PCXPackagePath
├─ Get-PCXPackageMetadata
├─ Get-PCXInstaller
├─ Get-PCXCommandLine
├─ Get Icon File
├─ Connect-PCXCMSite
│
├─ New-PCXCMApplication
├─ New-PCXCMApplicationDeploymentType
├─ Start-PCXCMContentDistributionForApplication
├─ New-PCXCMDeviceCollection
├─ New-PCXCMApplicationDeployment
├─ Move Application to SCCM Folder
└─ Move Collection to SCCM Folder
#>


# Test-PCXPackagePath
# Get-PCXPackageMetadata
# Get-PCXInstaller
# Get-PCXCommandLine
# Get Icon File
# Connect-PCXCMSite

# New-PCXCMApplication
# New-PCXCMApplicationDeploymentType
# Start-PCXCMContentDistributionForApplication
# New-PCXCMDeviceCollection
# New-PCXCMApplicationDeployment
# Move Application to SCCM Folder
# Move Collection to SCCM Folder

# ============================
# INIT
# ============================

if (-not (Test-Path "C:\Temp")) {
    New-Item -Path "C:\Temp" -ItemType Directory | Out-Null
}

$script:Config = @{
    LogPath    = "C:\Temp\PCX.log"
    RetryCount = 3
    RetryDelay = 5
}

# ============================
# LOGGING
# ============================

function Write-PCXLog {
    param(
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR")]
        [string]$Level = "INFO"
    )

    $entry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [$Level] $Message"

    try {
        Add-Content -Path $script:Config.LogPath -Value $entry
    }
    catch {}

    switch ($Level) {
        "ERROR" { Write-Host $entry -ForegroundColor Red }
        "WARN" { Write-Host $entry -ForegroundColor Yellow }
        default { Write-Host $entry -ForegroundColor Green }
    }
}

# ============================
# RETRY
# ============================

function Invoke-PCXWithRetry {
    param([scriptblock]$ScriptBlock)

    for ($i = 1; $i -le $script:Config.RetryCount; $i++) {
        try {
            return & $ScriptBlock
        }
        catch {
            if ($i -eq $script:Config.RetryCount) {
                throw $_
            }
            Start-Sleep $script:Config.RetryDelay
        }
    }
}

# ============================
# FILE VALIDATION (FIXED)
# ============================
function Test-PCXPackagePath {
    param([string]$Path)

    $cleanPath = $Path.Trim()

    try {

        # Validate directory using pure .NET
        if (-not [System.IO.Directory]::Exists($cleanPath)) {
            throw "Path not accessible: $cleanPath"
        }

        # Enumerate files safely
        $items = [System.IO.Directory]::GetFiles($cleanPath) | ForEach-Object {
            [System.IO.FileInfo]$_
        }

        if (-not $items -or $items.Count -eq 0) {
            throw "No files found in package path: $cleanPath"
        }

        return $items
    }
    catch {
        throw "File enumeration failed on path: $cleanPath | $($_.Exception.Message)"
    }
}

# ============================
# METADATA
# ============================

function Get-PCXPackageMetadata {
    param([string]$Path)

    $clean = $Path.TrimEnd("\")
    $parts = $clean -split "\\"

    $company = $parts[-3]
    $raw = $parts[-1]

    $versionMatch = [regex]::Match($raw, '\d+(\.\d+)+')
    $version = if ($versionMatch.Success) { $versionMatch.Value } else { "1.0" }

    $product = $raw -replace [regex]::Escape($version), ""
    $product = $product -replace '[\.\-_]', ' '
    $product = ($product -replace '\s+', ' ').Trim()
    $product = $product -replace [regex]::Escape($company), ""
    $product = ($product -replace '\s+', ' ').Trim()

    $name = "$company $product $version"
    $packagename = "PKG $name"

    return @{
        Name        = $name
        PackageName = $packagename
        Company     = $company
        Product     = $product
        Version     = $version
    }
}

# ============================
# INSTALLER
# ============================

function Get-PCXInstaller {
    param($Files)

    $msi = $Files | Where-Object Extension -eq ".msi" | Select-Object -First 1
    if ($msi) { return $msi }

    $exe = $Files | Where-Object Extension -eq ".exe" | Select-Object -First 1
    if ($exe) { return $exe }

    throw "No installer found"
}

# ============================
# COMMAND BUILDER (FIXED SAFE FILE CHECK)
# ============================

function Get-PCXCommandLine {
    param(
        [string]$Path,
        [string]$Type,
        $Installer
    )

    $map = @{}

    # Safe filesystem enumeration (avoids SCCM PSDrive/provider issues)
    [System.IO.Directory]::GetFiles($Path) | ForEach-Object {

        $file = [System.IO.FileInfo]$_

        $map[$file.Name.ToLower()] = $file
    }

    switch ($Type) {

        "Install" {

            if ($map.ContainsKey("install.bat")) {
                return "cmd.exe /c install.bat"
            }

            if ($Installer.Extension -eq ".msi") {
                return "msiexec /i `"$($Installer.Name)`" /qn"
            }

            return "$($Installer.Name) /S"
        }

        "Uninstall" {

            if ($map.ContainsKey("uninstall.bat")) {
                return "cmd.exe /c uninstall.bat"
            }

            if ($Installer.Extension -eq ".msi") {
                return "msiexec /x `"$($Installer.Name)`" /qn"
            }

            return "$($Installer.Name) /uninstall /S"
        }

        "Upgrade" {

            if ($map.ContainsKey("upgrade.bat")) {
                return "cmd.exe /c upgrade.bat"
            }

            return $null
        }

        "OSD" {

            if ($Installer.Extension -eq ".msi") {
                return "msiexec /i `"$($Installer.Name)`" /qn"
            }

            return "$($Installer.Name)"
        }
    }
}

# ============================
# PROGRAM NAME FORMAT
# ============================
function Get-ProgramNames {
    param(
        [Parameter(Mandatory)]
        [string]$PackageName
    )

    [PSCustomObject]@{
        Available = "$PackageName [AVAILABLE]"
        Install   = "$PackageName [INSTALL]"
        Uninstall = "$PackageName [UNINSTALL]"
    }
}

function Get-CollectionNames {
    param(
        [Parameter(Mandatory)]
        [string]$PackageName
    )

    return [PSCustomObject]@{
        Available = "$PackageName [AVAILABLE]"
        Install   = "$PackageName [INSTALL]"
        Uninstall = "$PackageName [UNINSTALL]"
        Exception = "$PackageName [EXCEPTION]"
    }
}

# ============================
# UPGRADE CHECK
# ============================

function Test-PCXHasUpgrade {
    param([string]$Path)

    Test-Path (Join-Path $Path "upgrade.bat")
}

# ============================
# SCCM (DO NOT CHANGE - AS REQUESTED)
# ============================

function Get-PCXCMSiteCode {
    (Get-WmiObject -Namespace root\SMS -Class SMS_ProviderLocation).SiteCode | Select-Object -First 1
}

function Get-PCXCMProviderMachineName {
    (Get-WmiObject -Namespace root\SMS -Class SMS_ProviderLocation |
    Where-Object ProviderForLocalSite -eq $true).Machine
}

function Connect-PCXCMSite {
    param (
        [string]$SiteCode = $(Get-PCXCMSiteCode),
        [string]$ProviderMachineName = $(Get-PCXCMProviderMachineName)
    )

    $initParams = @{}

    if ((Get-Module ConfigurationManager) -eq $null) {
        Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams
    }

    if (-not (Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue)) {
        New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
    }

    Set-Location "$($SiteCode):\" @initParams
}

function New-PCXCMFolder {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [String]$Path,

        [Parameter(Mandatory = $false, Position = 1)]
        [string]$Name
    )

    begin {
        Write-Verbose "********** BEGIN BLOCK **********"
    }

    process {
        Write-Verbose "********** Function Begin **********"

        try {
            # -------------------------------
            # Step 1: Detect and extract SiteCode
            # -------------------------------
            $siteCode = $null
            $cleanPath = $null

            if ($Path -match '^[A-Za-z0-9]{3}:\\') {
                # Path includes PSDrive (e.g., PS1:\...)
                $siteCode = $Path.Substring(0, 3)
                $cleanPath = $Path.Substring(4)
                Write-Verbose "Detected PSDrive in path: $siteCode"
            }
            else {
                # No PSDrive → use function
                $siteCode = Get-PCXCMSiteCode
                if (-not $siteCode) {
                    throw "Failed to retrieve SCCM Site Code."
                }
                $cleanPath = $Path
                Write-Verbose "Using detected SiteCode: $siteCode"
            }

            # -------------------------------
            # Step 2: Ensure ConfigMgr Module + PSDrive
            # -------------------------------
            if (-not (Get-PSDrive -Name $siteCode -ErrorAction SilentlyContinue)) {

                Write-Verbose "PSDrive '$siteCode' not found. Attempting to initialize..."

                $cmModulePath = Join-Path $ENV:SMS_ADMIN_UI_PATH "..\ConfigurationManager.psd1"

                if (-not (Test-Path $cmModulePath)) {
                    throw "ConfigurationManager module not found. Install SCCM Console."
                }

                Import-Module $cmModulePath -ErrorAction Stop
                Write-Verbose "ConfigurationManager module loaded."

                try {
                    Set-Location "$siteCode`:" -ErrorAction Stop
                    Write-Verbose "Connected to site drive: $siteCode"
                }
                catch {
                    throw "Failed to switch to PSDrive '$siteCode'. Verify site code."
                }
            }

            $rootPath = "$siteCode`:"
            
            # -------------------------------
            # Step 3: Normalize Path
            # -------------------------------
            $cleanPath = $cleanPath.Trim('\')

            if ([string]::IsNullOrWhiteSpace($cleanPath)) {
                throw "Path cannot be empty."
            }

            $segments = ($cleanPath -split '\\') | Where-Object { $_ }

            Write-Verbose "Normalized Path: $cleanPath"
            Write-Verbose "Segments: $($segments -join ' -> ')"

            # -------------------------------
            # Step 4: Create Path Step-by-Step
            # -------------------------------
            $currentPath = $rootPath

            foreach ($folder in $segments) {
                $nextPath = Join-Path $currentPath $folder

                if (-not (Test-Path $nextPath)) {
                    if ($PSCmdlet.ShouldProcess($nextPath, "Create folder")) {
                        New-Item -Path $currentPath -Name $folder -ItemType Directory -ErrorAction Stop
                        Write-Verbose "Created: $nextPath"
                    }
                }
                else {
                    Write-Verbose "Exists: $nextPath"
                }

                $currentPath = $nextPath
            }

            # -------------------------------
            # Step 5: Handle Optional Name
            # -------------------------------
            if ($Name) {
                if ([string]::IsNullOrWhiteSpace($Name)) {
                    throw "Folder name cannot be empty."
                }

                $finalPath = Join-Path $currentPath $Name

                if (-not (Test-Path $finalPath)) {
                    if ($PSCmdlet.ShouldProcess($finalPath, "Create folder")) {
                        New-Item -Path $currentPath -Name $Name -ItemType Directory -ErrorAction Stop
                        Write-Verbose "Created final folder: $finalPath"
                    }
                }
                else {
                    Write-Verbose "Final folder already exists: $finalPath"
                }
            }
            else {
                # No Name → full path already created
                $finalPath = $currentPath
                Write-Verbose "No child name provided. Full path ensured."
            }

            # -------------------------------
            # Step 6: Return Result
            # -------------------------------
            return [PSCustomObject]@{
                Success  = $true
                Path     = $finalPath
                SiteCode = $siteCode
            }
        }
        catch {
            Write-Error "Failed: $($_.Exception.Message)"

            return [PSCustomObject]@{
                Success = $false
                Error   = $_.Exception.Message
            }
        }
    }

    end {
        Write-Verbose "********** END BLOCK **********"
    }
}

# ============================
# ADD PROGRAM
# ============================

function Add-PCXProgram {
    param(
        [string]$PackageName,
        [string]$Type,
        [string]$CommandLine,
        $Platforms
    )

    $name = "$PackageName [$Type]"

    # Default values
    $runType = "WhetherOrNotUserIsLoggedOn"
    $userInteraction = $false
    $runMode = "RunWithAdministrativeRights"

    # Special handling for AVAILABLE
    if ($Type -eq "Available") {
        $runType = "OnlyWhenUserIsLoggedOn"
        $userInteraction = $true
    }

    # Create Program
    Invoke-PCXWithRetry {
        New-CMProgram `
            -PackageName $PackageName `
            -StandardProgramName $name `
            -CommandLine $CommandLine `
            -AddSupportedOperatingSystemPlatform $Platforms `
            -RunMode $runMode `
            -ProgramRunType $runType `
            -UserInteraction $userInteraction `
            -RunType Normal `
            -DiskSpaceRequirement 5 `
            -DiskSpaceUnit GB `
            -Duration 20
    }

    # Post config ONLY for Available
    if ($Type -eq "Available") {
        Invoke-PCXWithRetry {
            Set-CMProgram `
                -PackageName $PackageName `
                -ProgramName $name `
                -StandardProgram `
                -SuppressProgramNotification $false
        }
    }

    Write-PCXLog "$Type program created: $name"
}

function New-SCCMCollections {
    param(
        [Parameter(Mandatory)]
        [pscustomobject]$Collections,

        [Parameter(Mandatory)]
        [string]$LimitingCollectionName
    )

    New-CMDeviceCollection -Name $Collections.Available -LimitingCollectionName $LimitingCollectionName
    New-CMDeviceCollection -Name $Collections.Install   -LimitingCollectionName $LimitingCollectionName
    New-CMDeviceCollection -Name $Collections.Uninstall -LimitingCollectionName $LimitingCollectionName
    New-CMDeviceCollection -Name $Collections.Exception -LimitingCollectionName $LimitingCollectionName

    Write-PCXLog "Collections created"
}

function Start-SCCMContentDistribution {
    param(
        [Parameter(Mandatory)]
        [string]$PackageName,

        [Parameter(Mandatory = $false)]
        [string]$DistributionPointGroupName = "All Mangalore DPs"
    )

    Start-CMContentDistribution `
        -PackageName $PackageName `
        -DistributionPointGroupName $DistributionPointGroupName

    Write-PCXLog "Content distributed to DP Group: $DistributionPointGroupName"
}

function New-SCCMDeployments {
    param(
        [Parameter(Mandatory)]
        [string]$PackageName,

        [Parameter(Mandatory)]
        [pscustomobject]$Programs,

        [Parameter(Mandatory)]
        [pscustomobject]$Collections,

        $DeadlineTime
    )

    $programComment = "$PackageName Program"

    New-CMPackageDeployment `
        -StandardProgram `
        -PackageName $PackageName `
        -CollectionName $Collections.Available `
        -Comment $programComment `
        -DeployPurpose Available `
        -ProgramName $Programs.Available

    if (-not $DeadlineTime) {
        $DeadlineTime = (Get-Date -Hour 20 -Minute 0 -Second 0).AddDays(30)
    }

    $schedule = New-CMSchedule -Start $DeadlineTime -Nonrecurring

    New-CMPackageDeployment `
        -StandardProgram `
        -PackageName $PackageName `
        -ProgramName $Programs.Install `
        -DeployPurpose Required `
        -CollectionName $Collections.Install `
        -Schedule $schedule

    New-CMPackageDeployment `
        -StandardProgram `
        -PackageName $PackageName `
        -ProgramName $Programs.Uninstall `
        -DeployPurpose Required `
        -CollectionName $Collections.Uninstall `
        -Schedule $schedule

    Write-PCXLog "Deployments created"
}

function Move-SCCMCollectionsToFolder {
    param(
        [Parameter(Mandatory)]
        [pscustomobject]$Collections,

        [Parameter(Mandatory)]
        [pscustomobject]$meta
    )

    $siteCode = Get-PCXCMSiteCode

    $folder = "\DeviceCollection\Mphasis Application Deployment\$($meta.Company)\$($meta.Product)\$($meta.PackageName)"
    $folderPath = "$siteCode`:$folder"

    New-PCXCMFolder -Path $folder

    $collectionList = @(
        $Collections.Available,
        $Collections.Install,
        $Collections.Uninstall,
        $Collections.Exception
    )

    foreach ($collection in $collectionList) {

        $collectionObject = Get-CMDeviceCollection -Name $collection

        Move-CMObject `
            -FolderPath $folderPath `
            -InputObject $collectionObject

        Write-PCXLog "Moved Collection: $collection"
    }
}

function Move-SCCMPackageToFolder {
    param(
        [Parameter(Mandatory)]
        [pscustomobject]$meta
    )

    $siteCode = Get-PCXCMSiteCode

    $folder = "\Package\Application Installation\$($meta.Company)\$($meta.Product)"
    
    $folderPath = "$siteCode`:$folder"

    New-PCXCMFolder -Path $folder

    $packageObject = Get-CMPackage -Name $meta.PackageName -Fast

    Move-CMObject `
        -FolderPath $folderPath `
        -InputObject $packageObject

    Write-PCXLog "Moved Package: $($meta.PackageName)"
}

function Set-SCCMCollectionRules {
    param(
        [Parameter(Mandatory)]
        [pscustomobject]$Collections
    )

    Add-CMDeviceCollectionIncludeMembershipRule `
        -CollectionName $Collections.Exception `
        -IncludeCollectionName $Collections.Uninstall

    Add-CMDeviceCollectionExcludeMembershipRule `
        -CollectionName $Collections.Install `
        -ExcludeCollectionName $Collections.Exception

    Write-PCXLog "Collection membership rules configured"
}

# ============================
# MAIN
# ============================

function Create-PCXApplication {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [string]$DPGroup = "All Mangalore Dps",

        [string]$AvailableDateTime = (
            Get-Date -Format 'yyyy-MM-dd 00:00:00'
        ),

        [string]$DeadlineDateTime = (
            (Get-Date).AddDays(1).ToString('yyyy-MM-dd 00:00:00')
        )
    )

    try {
        Clear-Host
        Write-PCXLog "===== APPLICATION CREATION STARTED ====="

        # Validate source path
        $files = Test-PCXPackagePath $Path

        # Detect installer
        $installer = Get-PCXInstaller $files

        # Extract metadata
        $meta = Get-PCXPackageMetadata $Path

        #Build application name
        $ApplicationName = "APP $($meta.Name)"
        <# Build application name
        $ApplicationName = "APS_{0}_{1}" -f `
            ($meta.Product -replace '\s+', ''),
            $meta.Version
        #>
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

        # Connect to SCCM
        #Connect-PCXCMSite

        # Step 1 - Create Application
        Invoke-PCXWithRetry {
            New-PCXCMApplication `
                -Name $ApplicationName `
                -Description "New Application" `
                -Publisher $meta.Company `
                -SoftwereVersion $meta.Version `
                -ReleaseDate (Get-Date) `
                -Iconlocationfile $IconFile.FullName
        }

        Write-PCXLog "Application created"

        # Step 2 - Create Deployment Type
        Invoke-PCXWithRetry {
            New-PCXCMApplicationDeploymentType `
                -Name $ApplicationName `
                -InstallationFileLocation $installer.FullName
        }

        Write-PCXLog "Deployment Type created"

        # Step 3 - Distribute Content
        Invoke-PCXWithRetry {
            Start-PCXCMContentDistributionForApplication `
                -ApplicationName $ApplicationName `
                -DistributionPointGroup $DPGroup
        }

        Write-PCXLog "Content distributed"

        # Step 4 - Create Collection
        Invoke-PCXWithRetry {
            New-PCXCMDeviceCollection `
                -CollectionName $ApplicationName
        }

        Write-PCXLog "Collection created"

        # Step 5 - Deploy Application
        Invoke-PCXWithRetry {
            New-PCXCMApplicationDeployment `
                -Name $ApplicationName `
                -AvailableDateTime $AvailableDateTime `
                -CollectionName $ApplicationName `
                -DeadlineDateTime $DeadlineDateTime `
                -Action Install `
                -Purpose Available
        }

        Write-PCXLog "Application deployed"

        Write-PCXLog "SUCCESS: $ApplicationName"

        return [PSCustomObject]@{
            Success         = $true
            ApplicationName = $ApplicationName
            Publisher       = $meta.Company
            Version         = $meta.Version
            Installer       = $installer.Name
            SourcePath      = $Path
        }
    }
    catch {
        Write-PCXLog "FAILED: $($_.Exception.Message)" "ERROR"
        throw
    }
    finally {
        Write-PCXLog "Application creation completed"
    }
}

Create-PCXApplication -Path "\\192.168.25.214\Package_Source\Applications\Igor Pavlov\7zip\7zip 26.0.0"

<# Reproduce case

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
function Get-PCXCMProviderMachineName {
    [CmdletBinding()]
    param ()

    try {
        $namespace = "root\SMS"
        $siteClass = Get-WmiObject -Namespace $namespace -Class SMS_ProviderLocation -ErrorAction Stop |
        Where-Object { $_.ProviderForLocalSite -eq $true }

        if ($null -eq $siteClass) {
            Write-Error "Could not find a local SCCM provider in WMI under namespace '$namespace'."
            return $null
        }

        return $siteClass.Machine
    }
    catch {
        Write-Error "Failed to retrieve SCCM provider machine name from WMI. $_"
        return $null
    }
}
function Get-PCXCMSiteCode {
    [CmdletBinding()]
    param()
    try {
        $siteObj = Get-WmiObject -Namespace 'Root\SMS' -Class SMS_ProviderLocation -ComputerName '.'
        $code = if ($siteObj -is [array]) { $siteObj[0].SiteCode } else { $siteObj.SiteCode }
        return $code
    }
    catch {
        Throw "Error retrieving SCCM site code: $_"
    }
}

function Get-PCXSystemFQDN {
    [CmdletBinding()]
    param()
    try {
        return [System.Net.Dns]::GetHostEntry($env:COMPUTERNAME).HostName
    }
    catch {
        Throw "Error retrieving FQDN: $_"
    }
}

function Connect-PCXCMSite {
    param (
        [string]$SiteCode = $(Get-PCXCMSiteCode),
        [string]$ProviderMachineName = $(Get-PCXCMProviderMachineName)
    )

    # Optional: Add custom parameters for debugging or strict error handling
    $initParams = @{}
    # $initParams.Add("Verbose", $true)
    # $initParams.Add("ErrorAction", "Stop")

    # Import the ConfigurationManager module if not already loaded
    if ((Get-Module ConfigurationManager) -eq $null) {
        Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams
    }

    # Connect to the site's drive if not already connected
    if ((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
        New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
    }

    # Set the current location to the site drive
    Set-Location "$($SiteCode):\" @initParams
}

function New-PCXCMFolder {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [String]$Path,

        [Parameter(Mandatory=$false, Position=1)]
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
                $siteCode = $Path.Substring(0,3)
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
function Get-PackageDetails {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    $pathSplit = $Path -split "\\"

    $packageName = $pathSplit[-1]
    $company = $pathSplit[-3]
    $product = $pathSplit[-2]

    $versionSplit = $packageName -split " "
    $version = $versionSplit[-1]

    [PSCustomObject]@{
        PackageName = $packageName
        Company     = $company
        Product     = $product
        Version     = $version
    }
}

function Get-ProgramNames {
    param(
        [Parameter(Mandatory)]
        [string]$PackageName
    )

    [PSCustomObject]@{
        Available = "$PackageName[AVAILABLE]"
        Install   = "$PackageName[INSTALL]"
        Uninstall = "$PackageName[UNINSTALL]"
    }
}

function Get-CollectionNames {
    param(
        [Parameter(Mandatory)]
        [string]$PackageName
    )

    [PSCustomObject]@{
        Available = "$PackageName[AVAILABLE]"
        Install   = "$PackageName[INSTALL]"
        Uninstall = "$PackageName[UNINSTALL]"
        Exception = "$PackageName[EXCEPTION]"
    }
}

function New-SCCMPackage {
    param(
        [Parameter(Mandatory)]
        [pscustomobject]$PackageInfo,

        [Parameter(Mandatory)]
        [string]$Language,

        [Parameter(Mandatory)]
        [string]$Path
    )

    New-CMPackage `
        -Name $PackageInfo.PackageName `
        -Manufacturer $PackageInfo.Company `
        -Version $PackageInfo.Version `
        -Language $Language `
        -Path $Path

    Write-Host "Package created: $($PackageInfo.PackageName)" -ForegroundColor Green
}

function New-SCCMPrograms {
    param(
        [Parameter(Mandatory)]
        [string]$PackageName,

        [Parameter(Mandatory)]
        [pscustomobject]$Programs
    )

    New-CMProgram `
        -PackageName $PackageName `
        -StandardProgramName $Programs.Available `
        -CommandLine "install.exe" `
        -RunMode RunWithAdministrativeRights `
        -ProgramRunType WhetherOrNotUserIsLoggedOn

    New-CMProgram `
        -PackageName $PackageName `
        -StandardProgramName $Programs.Install `
        -CommandLine "install.bat" `
        -RunMode RunWithAdministrativeRights `
        -ProgramRunType WhetherOrNotUserIsLoggedOn

    New-CMProgram `
        -PackageName $PackageName `
        -StandardProgramName $Programs.Uninstall `
        -CommandLine "uninstall.bat" `
        -RunMode RunWithAdministrativeRights `
        -ProgramRunType WhetherOrNotUserIsLoggedOn

    Write-Host "Programs created" -ForegroundColor Green
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

    Write-Host "Collections created" -ForegroundColor Green
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

    Write-Host "Content distributed to DP Group: $DistributionPointGroupName" -ForegroundColor Green
}

function New-SCCMDeployments {
    param(
        [Parameter(Mandatory)]
        [string]$PackageName,

        [Parameter(Mandatory)]
        [pscustomobject]$Programs,

        [Parameter(Mandatory)]
        [pscustomobject]$Collections,

        #[datetime]$DeadlineTime
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

    Write-Host "Deployments created" -ForegroundColor Green
    Write-Host "Deployments created" -ForegroundColor Green
}

function Move-SCCMCollectionsToFolder {
    param(
        [Parameter(Mandatory)]
        [pscustomobject]$Collections,

        [Parameter(Mandatory)]
        [pscustomobject]$PackageInfo
    )

    $siteCode = Get-PCXCMSiteCode

    $folder = "\DeviceCollection\Mphasis Application Deployment\$($PackageInfo.Company)\$($PackageInfo.Product)\$($PackageInfo.PackageName)"
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

        Write-Host "Moved Collection: $collection" -ForegroundColor Green
    }
}

function Move-SCCMPackageToFolder {
    param(
        [Parameter(Mandatory)]
        [pscustomobject]$PackageInfo
    )

    $siteCode = Get-PCXCMSiteCode

    #$folder = "\Package\Application Installation\$($PackageInfo.Company)\$($PackageInfo.Product)\$($PackageInfo.PackageName)"
    $folder = "\Package\Application Installation\$($PackageInfo.Company)\$($PackageInfo.Product)"
    
    $folderPath = "$siteCode`:$folder"

    New-PCXCMFolder -Path $folder

    $packageObject = Get-CMPackage -Name $PackageInfo.PackageName

    Move-CMObject `
        -FolderPath $folderPath `
        -InputObject $packageObject

    Write-Host "Moved Package: $($PackageInfo.PackageName)" -ForegroundColor Green
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

    Write-Host "Collection membership rules configured" -ForegroundColor Green
}

function Create-Package {

    [CmdletBinding()]
    param(
        [string]$Language = "EN-US",

        [Parameter(Mandatory)]
        [string]$Path,

        [string]$LimitingCollectionName = "ALL Systems",

        [string]$DistributionPointGroupName = "All Mangalore DPs",

        [datetime]$DeadlineTime
    )

    Clear-Host

    Connect-PCXCMSite

    Write-Host "Starting package creation..." -ForegroundColor Cyan

    # -------------------------------------------------
    # Extract package information
    # -------------------------------------------------
    $packageInfo = Get-PackageDetails -Path $Path

    Write-Host "Package Name : $($packageInfo.PackageName)" -ForegroundColor Yellow
    Write-Host "Company      : $($packageInfo.Company)" -ForegroundColor Yellow
    Write-Host "Product      : $($packageInfo.Product)" -ForegroundColor Yellow
    Write-Host "Version      : $($packageInfo.Version)" -ForegroundColor Yellow

    # -------------------------------------------------
    # Generate names
    # -------------------------------------------------
    $programs = Get-ProgramNames -PackageName $packageInfo.PackageName
    $collections = Get-CollectionNames -PackageName $packageInfo.PackageName

    #$DeadlineTime = (Get-Date -Hour 20 -Minute 0 -Second 0).AddDays(30)
    #$NewScheduleDeadline = New-CMSchedule -Start $DeadlineTime -Nonrecurring

    # -------------------------------------------------
    # SCCM Operations
    # -------------------------------------------------
    New-SCCMPackage `
        -PackageInfo $packageInfo `
        -Language $Language `
        -Path $Path

    New-SCCMPrograms `
        -PackageName $packageInfo.PackageName `
        -Programs $programs

    New-SCCMCollections `
        -Collections $collections `
        -LimitingCollectionName $LimitingCollectionName

    Start-SCCMContentDistribution `
        -PackageName $packageInfo.PackageName `
        -DistributionPointGroupName $DistributionPointGroupName

    New-SCCMDeployments `
        -PackageName $packageInfo.PackageName `
        -Programs $programs `
        -Collections $collections `
        -DeadlineTime $DeadlineTime

    # New-CMPackageDeployment -StandardProgram -PackageName $Packagename -ProgramName $ProgramName3 -DeployPurpose Required -CollectionName $CollectionName3 -Schedule $NewScheduleDeadline   

    #Set-SCCMCollectionRules `
    #    -Collections $collections

    Move-SCCMCollectionsToFolder `
        -Collections $collections `
        -PackageInfo $packageInfo

    Move-SCCMPackageToFolder `
        -PackageInfo $packageInfo

    Write-Host ""
    Write-Host "Package creation completed successfully." -ForegroundColor Cyan
}

Create-Package -Path "\\192.168.25.214\Package_Source\Applications\Google\Chrome\Google Chrome 145.0.7632.46"
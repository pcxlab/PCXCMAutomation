function Get-PCXCMSiteCode {
    [CmdletBinding()]
    param()
    try {
        $siteObj = Get-WmiObject -Namespace 'Root\SMS' -Class SMS_ProviderLocation -ComputerName '.'
        $code = if ($siteObj -is [array]) { $siteObj[0].SiteCode } else { $siteObj.SiteCode }
        return $code
    } catch {
        Throw "Error retrieving SCCM site code: $_"
    }
}
function Get-PackageDetails {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    $pathSplit = $Path -split "\\"

    $packageName = $pathSplit[-1]
    $company     = $pathSplit[-3]
    $product     = $pathSplit[-2]

    $versionSplit = $packageName -split " "
    $version      = $versionSplit[-1]

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

        [Parameter(Mandatory)]
        [string]$DistributionPointGroupName
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

        [datetime]$DeadlineTime
    )

    $programComment = "$PackageName Program"

    New-CMPackageDeployment `
        -StandardProgram `
        -PackageName $PackageName `
        -CollectionName $Collections.Available `
        -Comment $programComment `
        -DeployPurpose Available `
        -ProgramName $Programs.Available

    New-CMPackageDeployment `
        -StandardProgram `
        -PackageName $PackageName `
        -CollectionName $Collections.Install `
        -Comment $programComment `
        -DeployPurpose Available `
        -ProgramName $Programs.Install

    if (-not $DeadlineTime) {
        $DeadlineTime = (Get-Date -Hour 20 -Minute 0 -Second 0).AddDays(30)
    }

    $schedule = New-CMSchedule -Start $DeadlineTime -Nonrecurring

    New-CMPackageDeployment `
        -StandardProgram `
        -PackageName $PackageName `
        -ProgramName $Programs.Uninstall `
        -DeployPurpose Required `
        -CollectionName $Collections.Uninstall `
        -Schedule $schedule

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

    $folder = "\Package\Application Installation\$($PackageInfo.Company)\$($PackageInfo.Product)\$($PackageInfo.PackageName)"
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

        [string]$DistributionPointGroupName = "Mangalore Distribution point",

        [datetime]$DeadlineTime
    )

    Clear-Host

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
    $programs    = Get-ProgramNames -PackageName $packageInfo.PackageName
    $collections = Get-CollectionNames -PackageName $packageInfo.PackageName

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

    Set-SCCMCollectionRules `
        -Collections $collections

    Move-SCCMCollectionsToFolder `
        -Collections $collections `
        -PackageInfo $packageInfo

    Move-SCCMPackageToFolder `
        -PackageInfo $packageInfo

    Write-Host ""
    Write-Host "Package creation completed successfully." -ForegroundColor Cyan
}

Create-Package -Path "\\192.168.25.214\Package_Source\Applications\Google\Chrome\Google Chrome 145.0.7632.46"
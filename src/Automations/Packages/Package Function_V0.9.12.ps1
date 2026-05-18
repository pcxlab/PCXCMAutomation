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
        [ValidateSet("INFO","WARN","ERROR")]
        [string]$Level = "INFO"
    )

    $entry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [$Level] $Message"

    try {
        Add-Content -Path $script:Config.LogPath -Value $entry
    } catch {}

    switch ($Level) {
        "ERROR" { Write-Host $entry -ForegroundColor Red }
        "WARN"  { Write-Host $entry -ForegroundColor Yellow }
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
        } catch {
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

    if (-not (Test-Path $cleanPath)) {
        throw "Path not accessible: $cleanPath"
    }

    try {
        # Force stable enumeration
        $items = Get-ChildItem -LiteralPath $cleanPath -ErrorAction Stop |
                 Where-Object { -not $_.PSIsContainer }

        if (-not $items -or $items.Count -eq 0) {
            throw "No files found in package path: $cleanPath"
        }

        return $items
    }
    catch {
        throw "File enumeration failed on path: $cleanPath | $_"
    }
}

# ============================
# METADATA
# ============================

function Get-PCXPackageMetadata {
    param([string]$Path)

    $clean  = $Path.TrimEnd("\")
    $parts  = $clean -split "\\"

    $company = $parts[-3]
    $raw     = $parts[-1]

    $versionMatch = [regex]::Match($raw, '\d+(\.\d+)+')
    $version = if ($versionMatch.Success) { $versionMatch.Value } else { "1.0" }

    $product = $raw -replace [regex]::Escape($version), ""
    $product = $product -replace '[\.\-_]', ' '
    $product = ($product -replace '\s+', ' ').Trim()
    $product = $product -replace [regex]::Escape($company), ""
    $product = ($product -replace '\s+', ' ').Trim()

    $name = "PKG $company $product $version"

    return @{
        Name    = $name
        Company = $company
        Product = $product
        Version = $version
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
    Set-Location c:
    # FIX: no -File used
    Get-ChildItem -Path $Path | Where-Object { -not $_.PSIsContainer } | ForEach-Object {
        $map[$_.Name.ToLower()] = $_
    }

    Connect-PCXCMSite

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

function Get-PCXProgramName {
    param(
        [string]$Base,
        [string]$Type
    )

    return "$Base [$Type]"
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

# ============================
# RESET LOCATION
# ============================

function Reset-LocationSafe {
    Set-Location "C:\" -ErrorAction SilentlyContinue
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

# ============================
# MAIN
# ============================

function Create-PCXPackage {

    param(
        [Parameter(Mandatory)][string]$Path,
        [string]$Language = "EN-US",
        [string]$DPGroup = "All Mangalore Dps"
    )

    try {
        Clear-Host
        Write-PCXLog "===== START ====="

        $files     = Test-PCXPackagePath $Path
        $installer = Get-PCXInstaller $files
        $meta      = Get-PCXPackageMetadata $Path

        Write-PCXLog "Package: $($meta.Name)"
        Write-PCXLog "Installer: $($installer.Name)"

        Connect-PCXCMSite

        $platforms = Get-CMSupportedPlatform -Fast | Where-Object {
            $_.DisplayText -like "*Windows 11*"
        }

        Invoke-PCXWithRetry {
            New-CMPackage -Name $meta.Name -Manufacturer $meta.Company -Version $meta.Version -Language $Language -Path $Path
        }

        Write-PCXLog "Package created"

        # INSTALL
        Add-PCXProgram $meta.Name "Install" (Get-PCXCommandLine $Path "Install" $installer) $platforms

        # AVAILABLE (NEW)
        Add-PCXProgram `
            -PackageName $meta.Name `
            -Type "Available" `
            -CommandLine (Get-PCXCommandLine $Path "Install" $installer) `
            -Platforms $platforms

        # UNINSTALL
        Add-PCXProgram $meta.Name "Uninstall" (Get-PCXCommandLine $Path "Uninstall" $installer) $platforms

        # UPGRADE (optional)
        if (Test-PCXHasUpgrade $Path) {
            $upCmd = Get-PCXCommandLine $Path "Upgrade" $installer
            if ($upCmd) {
                Add-PCXProgram $meta.Name "Upgrade" $upCmd $platforms
            }
        }

        # OSD
        Add-PCXProgram $meta.Name "OSD" (Get-PCXCommandLine $Path "OSD" $installer) $platforms

        Invoke-PCXWithRetry {
            Start-CMContentDistribution -PackageName $meta.Name -DistributionPointGroupName $DPGroup
        }

        Write-PCXLog "SUCCESS: $($meta.Name)"
    }
    catch {
        Write-PCXLog "FAILED: $($_.Exception.Message)" "ERROR"
        throw
    }
    finally {
        Reset-LocationSafe
        Write-PCXLog "Returned to C:\"
    }
}

# ============================
# EXECUTION
# ============================

#Create-PCXPackage -Path "\\192.168.25.214\Package_source\Applications\Igor Pavlov\7zip\7zip 26.0.0\"
Create-PCXPackage -Path "\\192.168.25.214\Package_source\Applications\Igor Pavlov\7zip\7zip 26.0.1\"
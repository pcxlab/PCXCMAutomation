
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

    for ($i=1; $i -le $script:Config.RetryCount; $i++) {
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
# FILE VALIDATION
# ============================

function Test-PCXPackagePath {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        throw "Path not found: $Path"
    }

    return Get-ChildItem -Path $Path -File
}

# ============================
# METADATA (FINAL FIXED LOGIC)
# ============================

function Get-PCXPackageMetadata {
    param([string]$Path)

    $cleanPath = $Path.TrimEnd("\")
    $split = $cleanPath -split "\\"

    if ($split.Count -lt 3) {
        throw "Invalid folder structure"
    }

    $company = $split[-3]

    # Take last folder only
    $raw = $split[-1]

    # Extract version anywhere in string (MOST IMPORTANT FIX)
    $versionMatch = [regex]::Match($raw, '\d+(\.\d+)+')

    if ($versionMatch.Success) {
        $version = $versionMatch.Value
    } else {
        $version = "1.0"
    }

    # Remove version from raw string
    $product = $raw -replace [regex]::Escape($version), ""

    # Clean noise
    $product = $product -replace '[\.\-_]', ' '
    $product = ($product -replace '\s+', ' ').Trim()

    # FINAL SAFETY: remove duplicate company/product leaks
    if ($product -like "$company*") {
        $product = $product -replace [regex]::Escape($company), ""
        $product = $product.Trim()
    }

    # FINAL NAME (CORRECT)
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

    $exe = $Files | Where-Object Extension -eq ".exe" | Select-Object -First 1
    if ($exe) { return $exe }

    $msi = $Files | Where-Object Extension -eq ".msi" | Select-Object -First 1
    if ($msi) { return $msi }

    throw "No installer found"
}

function Get-PCXInstallCommand {
    param($Installer)

    if ($Installer.Extension -eq ".msi") {
        return "msiexec /i `"$($Installer.Name)`" /qn"
    }

    return "$($Installer.Name) /S"
}

function Get-PCXUninstallCommand {
    param($Installer)

    # MSI uninstall (best case)
    if ($Installer.Extension -eq ".msi") {

        return "msiexec /x `"$($Installer.Name)`" /qn"
    }

    # EXE fallback (generic silent uninstall attempt)
    return "$($Installer.Name) /uninstall /S"
}

function Get-PCXProgramName {
    param(
        [string]$PackageName,
        [string]$Type
    )

    return "$PackageName [$Type]"
}

# ============================
# SCCM CONNECTION
# ============================

function Get-PCXCMSiteCode {
    (Get-WmiObject -Namespace root\SMS -Class SMS_ProviderLocation).SiteCode | Select-Object -First 1
}

function Get-PCXCMProviderMachineName {
    (Get-WmiObject -Namespace root\SMS -Class SMS_ProviderLocation |
        Where-Object ProviderForLocalSite -eq $true).Machine
}

function Connect-PCXCMSite {

    $SiteCode = Get-PCXCMSiteCode
    $Provider = Get-PCXCMProviderMachineName

    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" -ErrorAction Stop

    if (-not (Get-PSDrive $SiteCode -ErrorAction SilentlyContinue)) {
        New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $Provider | Out-Null
    }

    Set-Location "${SiteCode}:\"

    Write-PCXLog "Connected to SCCM: $SiteCode"
}

# ============================
# SAFE RESET (FIX YOUR RE-RUN ISSUE)
# ============================

function Reset-LocationSafe {
    Set-Location "C:\" -ErrorAction SilentlyContinue
}

# ============================
# MAIN FUNCTION
# ============================

function Create-PCXPackage {

    param(
        [Parameter(Mandatory)][string]$Path,
        [string]$Language = "EN-US",
        [string]$DPGroup = "All Mangalore Dps"
    )

    Clear-Host

    try {
        Write-PCXLog "===== START ====="

        # -----------------------
        # FILE SYSTEM FIRST
        # -----------------------
        $files     = Test-PCXPackagePath $Path
        $installer = Get-PCXInstaller $files
        $meta      = Get-PCXPackageMetadata $Path

        Write-PCXLog "Package Name: $($meta.Name)"
        Write-PCXLog "Installer: $($installer.Name)"

        $cmd = Get-PCXInstallCommand $installer

        # -----------------------
        # CONNECT SCCM
        # -----------------------
        Connect-PCXCMSite

        # -----------------------
        # CREATE PACKAGE
        # -----------------------
        Invoke-PCXWithRetry {
            New-CMPackage `
                -Name $meta.Name `
                -Manufacturer $meta.Company `
                -Version $meta.Version `
                -Language $Language `
                -Path $Path
        }

        Write-PCXLog "Package created"

        Invoke-PCXWithRetry {

    # Install Program
    Invoke-PCXWithRetry {
        New-CMProgram `
            -PackageName $meta.Name `
            -StandardProgramName (Get-PCXProgramName $meta.Name "INSTALL") `
            -CommandLine $cmd `
            -RunMode RunWithAdministrativeRights `
            -ProgramRunType WhetherOrNotUserIsLoggedOn
    }

    Write-PCXLog "Install Program created"


    # Uninstall Program
    $uninstallCmd = Get-PCXUninstallCommand $installer

    Invoke-PCXWithRetry {
        New-CMProgram `
            -PackageName $meta.Name `
            -StandardProgramName (Get-PCXProgramName $meta.Name "UNINSTALL") `
            -CommandLine $uninstallCmd `
            -RunMode RunWithAdministrativeRights `
            -ProgramRunType WhetherOrNotUserIsLoggedOn
    }

    Write-PCXLog "Uninstall Program created"
        }

        Write-PCXLog "Program created"

        Invoke-PCXWithRetry {
            Start-CMContentDistribution `
                -PackageName $meta.Name `
                -DistributionPointGroupName $DPGroup
        }

        Write-PCXLog "Distribution started"
        Write-PCXLog "SUCCESS: $($meta.Name)"
    }
    catch {
        Write-PCXLog "FAILED: $($_.Exception.Message)" "ERROR"
        throw
    }
    finally {
        # 🔥 CRITICAL FIX: allow safe re-run
        Reset-LocationSafe
        Write-PCXLog "Returned to C:\ for clean re-run"
    }
}

# ============================
# EXECUTION
# ============================

#Create-PCXPackage -Path "\\192.168.25.214\Package_source\Applications\Igor Pavlov\7zip\7zip 26.0.0\"

Create-PCXPackage -Path "\\192.168.25.214\Package_source\Applications\Igor Pavlov\7zip\7zip 26.0.1\"
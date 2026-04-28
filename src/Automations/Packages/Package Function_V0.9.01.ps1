
# ----------------------------
# INIT - Local environment
# ----------------------------

if (-not (Test-Path "C:\Temp")) {
    New-Item -Path "C:\Temp" -ItemType Directory | Out-Null
}

$script:Config = @{
    LogPath    = "C:\Temp\PCX.log"
    RetryCount = 3
    RetryDelay = 5
}

# ----------------------------
# LOGGING
# ----------------------------

function Write-PCXLog {
    param(
        [string]$Message,
        [ValidateSet("INFO","WARN","ERROR")]
        [string]$Level = "INFO"
    )

    $time  = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "$time [$Level] $Message"

    $logPath = if ($script:Config.LogPath) {
        $script:Config.LogPath
    } else {
        "C:\Temp\PCX_Default.log"
    }

    try {
        Add-Content -Path $logPath -Value $entry
    } catch {
        Write-Host "Logging failed: $($_.Exception.Message)" -ForegroundColor Red
    }

    switch ($Level) {
        "ERROR" { Write-Host $entry -ForegroundColor Red }
        "WARN"  { Write-Host $entry -ForegroundColor Yellow }
        default { Write-Host $entry -ForegroundColor Green }
    }
}

# ----------------------------
# RETRY WRAPPER
# ----------------------------

function Invoke-PCXWithRetry {
    param([scriptblock]$ScriptBlock)

    for ($i = 1; $i -le $script:Config.RetryCount; $i++) {
        try {
            return & $ScriptBlock
        }
        catch {
            Write-PCXLog "Attempt $i failed: $($_.Exception.Message)" "WARN"

            if ($i -eq $script:Config.RetryCount) {
                throw "Final failure: $($_.Exception.Message)"
            }

            Start-Sleep -Seconds $script:Config.RetryDelay
        }
    }
}

# ----------------------------
# FILE SYSTEM VALIDATION
# ----------------------------

function Test-PCXPackagePath {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        throw "Path not found: $Path"
    }

    $files = Get-ChildItem -Path $Path -File

    if (-not $files) {
        throw "Folder is empty: $Path"
    }

    Write-PCXLog "Validated path: $Path"
    return $files
}

# ----------------------------
# METADATA
# ----------------------------

function Get-PCXPackageMetadata {
    param([string]$Path)

    $cleanPath = $Path.TrimEnd("\")
    $split     = $cleanPath -split "\\"

    if ($split.Count -lt 3) {
        throw "Invalid path structure"
    }

    $folderName = $split[-1]

    $version = if ($folderName -match '\d+(\.\d+)+') {
        $matches[0]
    } else {
        "1.0"
    }

    return @{
        Name    = "PKG " + $folderName
        Company = $split[-3]
        Product = $split[-2]
        Version = $version
    }
}

# ----------------------------
# INSTALLER HANDLING
# ----------------------------

function Get-PCXInstaller {
    param($Files)

    $exe = $Files | Where-Object { $_.Extension -eq ".exe" } | Select-Object -First 1
    if ($exe) { return $exe }

    $msi = $Files | Where-Object { $_.Extension -eq ".msi" } | Select-Object -First 1
    if ($msi) { return $msi }

    throw "No EXE or MSI found"
}

function Get-PCXInstallCommand {
    param($Installer)

    if ($Installer.Extension -eq ".msi") {
        return "msiexec /i `"$($Installer.Name)`" /qn"
    }
    else {
        return "$($Installer.Name) /S"
    }
}

# ----------------------------
# SCCM CONNECTION
# ----------------------------

function Get-PCXCMSiteCode {
    $siteObj = Get-WmiObject -Namespace "Root\SMS" -Class SMS_ProviderLocation -ComputerName "."

    if ($siteObj -is [array]) {
        return $siteObj[0].SiteCode
    }

    return $siteObj.SiteCode
}

function Get-PCXCMProviderMachineName {
    $site = Get-WmiObject -Namespace "root\SMS" -Class SMS_ProviderLocation |
            Where-Object { $_.ProviderForLocalSite -eq $true }

    return $site.Machine
}

function Connect-PCXCMSite {

    $SiteCode = Get-PCXCMSiteCode
    $ProviderMachineName = Get-PCXCMProviderMachineName

    if (-not $SiteCode -or -not $ProviderMachineName) {
        throw "Unable to determine SCCM site or provider"
    }

    if (-not (Get-Module ConfigurationManager)) {
        Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" -ErrorAction Stop
    }

    # Prevent duplicate PSDrive
    if (-not (Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue)) {
        New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName -ErrorAction Stop
    }

    # FIXED VARIABLE SYNTAX ERROR HERE
    $sitePath = "${SiteCode}:\"
    Set-Location $sitePath -ErrorAction Stop

    Write-PCXLog "Connected to SCCM Site: $SiteCode"
}

# ----------------------------
# MAIN FUNCTION
# ----------------------------

function Create-PCXPackage {

    param(
        [Parameter(Mandatory)][string]$Path,
        [string]$Language = "EN-US",
        [string]$DistributionPointGroupName = "All Mangalore Dps"
    )

    Clear-Host

    try {
        Write-PCXLog "===== START ====="

        # ----------------------------
        # FILE SYSTEM FIRST
        # ----------------------------
        $files     = Test-PCXPackagePath -Path $Path
        $installer = Get-PCXInstaller -Files $files
        $meta      = Get-PCXPackageMetadata -Path $Path

        Write-PCXLog "Package: $($meta.Name)"
        Write-PCXLog "Company: $($meta.Company)"
        Write-PCXLog "Product: $($meta.Product)"
        Write-PCXLog "Version: $($meta.Version)"
        Write-PCXLog "Installer: $($installer.Name)"

        $installCmd = Get-PCXInstallCommand -Installer $installer
        Write-PCXLog "Install Command: $installCmd"

        # ----------------------------
        # CONNECT TO SCCM
        # ----------------------------
        Connect-PCXCMSite

        # ----------------------------
        # SCCM OPERATIONS
        # ----------------------------

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
            New-CMProgram `
                -PackageName $meta.Name `
                -StandardProgramName "$($meta.Name)[INSTALL]" `
                -CommandLine $installCmd `
                -RunMode RunWithAdministrativeRights `
                -ProgramRunType WhetherOrNotUserIsLoggedOn
        }

        Write-PCXLog "Program created"

        Invoke-PCXWithRetry {
            Start-CMContentDistribution `
                -PackageName $meta.Name `
                -DistributionPointGroupName $DistributionPointGroupName
        }

        Write-PCXLog "Distribution started"
        Write-PCXLog "SUCCESS: $($meta.Name)"
        Write-PCXLog "===== END ====="
    }
    catch {
        Write-PCXLog "FAILED: $($_.Exception.Message)" "ERROR"
        throw
    }
}

# ----------------------------
# EXECUTION
# ----------------------------

Create-PCXPackage -Path "\\192.168.25.214\Package_source\Applications\Igor Pavlov\7zip\7zip 26.0.0\"

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

    try { Add-Content -Path $script:Config.LogPath -Value $entry } catch {}

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
        try { return & $ScriptBlock }
        catch {
            if ($i -eq $script:Config.RetryCount) { throw $_ }
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

    $files = Get-ChildItem -Path $Path -File -ErrorAction Stop

    if (-not $files) {
        throw "No files found"
    }

    return $files
}

# ============================
# METADATA
# ============================

function Get-PCXPackageMetadata {
    param([string]$Path)

    $parts = ($Path.TrimEnd("\") -split "\\")

    $company = $parts[-3]
    $raw     = $parts[-1]

    $version = ([regex]::Match($raw, '\d+(\.\d+)+')).Value
    if (-not $version) { $version = "1.0" }

    $product = $raw -replace [regex]::Escape($version), ""
    $product = $product -replace '[\.\-_]', ' '
    $product = ($product -replace '\s+', ' ').Trim()
    $product = $product -replace [regex]::Escape($company), ""
    $product = ($product -replace '\s+', ' ').Trim()

    return @{
        Name    = "PKG $company $product $version"
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
# COMMANDS
# ============================

function Get-PCXInstallCommand($Installer) {
    if ($Installer.Extension -eq ".msi") {
        return "msiexec /i `"$($Installer.Name)`" /qn"
    }
    return "$($Installer.Name) /S"
}

function Get-PCXUninstallCommand($Installer) {
    if ($Installer.Extension -eq ".msi") {
        return "msiexec /x `"$($Installer.Name)`" /qn"
    }
    return "$($Installer.Name) /uninstall /S"
}

# ============================
# BAT DETECTION (FIXED SAFE)
# ============================

function Get-PCXBatchFiles {
    param($Files)

    $map = @{}

    foreach ($f in $Files) {
        if ($null -ne $f -and $f.Name) {
            $map[$f.Name.ToLower()] = $true
        }
    }

    return @{
        Install   = $map.ContainsKey("install.bat")
        Uninstall = $map.ContainsKey("uninstall.bat")
        Upgrade   = $map.ContainsKey("upgrade.bat")
    }
}

# ============================
# SCCM CONNECT
# ============================

function Get-SiteCode {
    (Get-WmiObject -Namespace root\SMS -Class SMS_ProviderLocation |
        Select-Object -First 1).SiteCode
}

function Get-Provider {
    (Get-WmiObject -Namespace root\SMS -Class SMS_ProviderLocation |
        Where-Object ProviderForLocalSite -eq $true |
        Select-Object -First 1).Machine
}

function Connect-SCCM {
    $site = Get-SiteCode
    $prov = Get-Provider

    Import-Module "$env:SMS_ADMIN_UI_PATH\..\ConfigurationManager.psd1" -ErrorAction Stop

    if (-not (Get-PSDrive $site -ErrorAction SilentlyContinue)) {
        New-PSDrive -Name $site -PSProvider CMSite -Root $prov | Out-Null
    }

    Set-Location "${site}:\" -ErrorAction Stop

    Write-PCXLog "Connected to SCCM: $site"
}

function Reset-LocationSafe {
    Set-Location "C:\" -ErrorAction SilentlyContinue
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
        Write-PCXLog "===== START ====="

        $files     = Test-PCXPackagePath $Path
        $installer = Get-PCXInstaller $files
        $meta      = Get-PCXPackageMetadata $Path
        $bat       = Get-PCXBatchFiles $files

        Write-PCXLog "Package: $($meta.Name)"
        Write-PCXLog "Installer: $($installer.Name)"

        Connect-SCCM

        # PACKAGE
        Invoke-PCXWithRetry {
            New-CMPackage -Name $meta.Name -Manufacturer $meta.Company -Version $meta.Version -Language $Language -Path $Path
        }

        Write-PCXLog "Package created"

        # ============================
        # INSTALL
        # ============================
        if ($bat.Install) {

            New-CMProgram -PackageName $meta.Name `
                -StandardProgramName "$($meta.Name) [INSTALL]" `
                -CommandLine "cmd.exe /c install.bat" `
                -RunMode RunWithAdministrativeRights `
                -ProgramRunType WhetherOrNotUserIsLoggedOn

            Write-PCXLog "BAT INSTALL created"
        }
        else {

            New-CMProgram -PackageName $meta.Name `
                -StandardProgramName "$($meta.Name) [INSTALL]" `
                -CommandLine (Get-PCXInstallCommand $installer) `
                -RunMode RunWithAdministrativeRights `
                -ProgramRunType WhetherOrNotUserIsLoggedOn

            Write-PCXLog "MSI/EXE INSTALL created"
        }

        # ============================
        # UNINSTALL
        # ============================
        if ($bat.Uninstall) {

            New-CMProgram -PackageName $meta.Name `
                -StandardProgramName "$($meta.Name) [UNINSTALL]" `
                -CommandLine "cmd.exe /c uninstall.bat" `
                -RunMode RunWithAdministrativeRights `
                -ProgramRunType WhetherOrNotUserIsLoggedOn

            Write-PCXLog "BAT UNINSTALL created"
        }
        else {

            New-CMProgram -PackageName $meta.Name `
                -StandardProgramName "$($meta.Name) [UNINSTALL]" `
                -CommandLine (Get-PCXUninstallCommand $installer) `
                -RunMode RunWithAdministrativeRights `
                -ProgramRunType WhetherOrNotUserIsLoggedOn

            Write-PCXLog "MSI/EXE UNINSTALL created"
        }

        # ============================
        # UPGRADE (OPTIONAL)
        # ============================
        if ($bat.Upgrade) {

            New-CMProgram -PackageName $meta.Name `
                -StandardProgramName "$($meta.Name) [UPGRADE]" `
                -CommandLine "cmd.exe /c upgrade.bat" `
                -RunMode RunWithAdministrativeRights `
                -ProgramRunType WhetherOrNotUserIsLoggedOn

            Write-PCXLog "BAT UPGRADE created"
        }
        else {
            Write-PCXLog "No upgrade.bat found → skipped" "WARN"
        }

        # DISTRIBUTION
        Start-CMContentDistribution -PackageName $meta.Name -DistributionPointGroupName $DPGroup

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

# EXECUTE (MSI)
Create-PCXPackage -Path "\\192.168.25.214\Package_source\Applications\Igor Pavlov\7zip\7zip 26.0.0\"
# EXECUTE (EXE)
Create-PCXPackage -Path "\\192.168.25.214\Package_source\Applications\Igor Pavlov\7zip\7zip 26.0.1\"

<#

Connect-PCXCMSite
Remove-CMPackage -Name "PKG Igor Pavlov 7zip 26.0.1" -Force
Remove-CMPackage -Name "PKG Igor Pavlov 7zip 26.0.0" -Force
cd c:

#>


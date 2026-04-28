function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO","WARN","ERROR")]
        [string]$Level = "INFO"
    )

    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "$time [$Level] $Message"

    Add-Content -Path $script:Config.LogPath -Value $entry

    switch ($Level) {
        "ERROR" { Write-Host $entry -ForegroundColor Red }
        "WARN"  { Write-Host $entry -ForegroundColor Yellow }
        default { Write-Host $entry -ForegroundColor Green }
    }
}

function Invoke-WithRetry {
    param([scriptblock]$ScriptBlock)

    for ($i = 1; $i -le $script:Config.RetryCount; $i++) {
        try {
            return & $ScriptBlock
        }
        catch {
            Write-Log "Attempt $i failed: $_" "WARN"
            Start-Sleep -Seconds $script:Config.RetryDelay
        }
    }

    throw "Operation failed after multiple attempts"
}

function Test-PackagePath {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        throw "Path not found: $Path"
    }

    $files = Get-ChildItem -Path $Path -File
    if (-not $files) {
        throw "Folder is empty: $Path"
    }

    Write-Log "Validated path: $Path"
    return $files
}

function Get-PackageMetadata {
    param([string]$Path)

    $split = $Path -split "\\"

    return @{
        Name    = "PKG_" + $split[-1]
        Company = $split[-3]
        Product = $split[-2]
        Version = ($split[-1] -split "_")[-1]
    }
}

function Get-Installer {
    param($Files)

    $exe = $Files | Where-Object Name -like "*.exe" | Select-Object -First 1
    if ($exe) { return $exe }

    $msi = $Files | Where-Object Name -like "*.msi" | Select-Object -First 1
    if ($msi) { return $msi }

    throw "No EXE or MSI found"
}

function Create-Package {
    param(
        [Parameter(Mandatory)][string]$Path,
        [string]$Language = "EN-US",
        [string]$LimitingCollectionName = "ALL Systems",
        [string]$DistributionPointGroupName = "ALL Mangalore Group"
    )

    Clear-Host

    try {
        Write-Log "Starting package creation"

        $files     = Test-PackagePath -Path $Path
        $installer = Get-Installer -Files $files
        $meta      = Get-PackageMetadata -Path $Path

        Write-Log "Package: $($meta.Name)"
        Write-Log "Company: $($meta.Company)"
        Write-Log "Version: $($meta.Version)"

        $installCmd = "$($installer.Name) /S"

        # Create Package
        Invoke-WithRetry {
            New-CMPackage `
                -Name $meta.Name `
                -Manufacturer $meta.Company `
                -Version $meta.Version `
                -Language $Language `
                -Path $Path
        }

        Write-Log "Package created"

        # Programs
        Invoke-WithRetry {
            New-CMProgram `
                -PackageName $meta.Name `
                -StandardProgramName "$($meta.Name)[INSTALL]" `
                -CommandLine $installCmd `
                -RunMode RunWithAdministrativeRights `
                -ProgramRunType WhetherOrNotUserIsLoggedOn
        }

        Write-Log "Program created"

        # Distribution
        Invoke-WithRetry {
            Start-CMContentDistribution `
                -PackageName $meta.Name `
                -DistributionPointGroupName $DistributionPointGroupName
        }

        Write-Log "Distribution started"

        Write-Log "SUCCESS: $($meta.Name)"
    }
    catch {
        Write-Log "FAILED: $_" "ERROR"
        throw
    }
}
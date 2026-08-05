class Validator {
    static [void] ValidateSourcePath([string]$path) {
        if ([string]::IsNullOrWhiteSpace($path)) {
            throw "Please select a source path."
        }

        if (-not ([System.IO.Directory]::Exists($path))) {
            throw "Source path does not exist: $path"
        }

        $pathParts = $path.TrimEnd('\').Split([System.IO.Path]::DirectorySeparatorChar)
        if ($pathParts.Count -lt 3) {
            throw "Invalid package structure. Expected: ...\Company\Product\Package"
        }

        $files = [System.IO.Directory]::GetFiles($path)
        if ($files.Count -eq 0) {
            throw "Package folder is empty: $path"
        }

        $supportedExtensions = @('.msi', '.exe', '.ps1', '.cmd', '.bat')
        $hasInstaller = $false
        foreach ($file in $files) {
            if ([System.IO.Path]::GetExtension($file).ToLower() -in $supportedExtensions) {
                $hasInstaller = $true
                break
            }
        }

        if (-not $hasInstaller) {
            throw "No supported installer files (.msi, .exe, .ps1, .cmd, .bat) found in: $path"
        }
    }

    static [void] ValidateTargets([string[]]$dps, [string[]]$dpGroups) {
        if (($null -eq $dps -or $dps.Count -eq 0) -and ($null -eq $dpGroups -or $dpGroups.Count -eq 0)) {
            throw "Please select at least one Target (DP Group, DP or CMG)."
        }
    }
}

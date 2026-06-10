function Test-PCXPackageSource {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$PackagePath
    )

    if (-not ([System.IO.Directory]::Exists($PackagePath))) {
        throw "Source path does not exist: $PackagePath"
    }

    $PathParts = $PackagePath.TrimEnd('\').Split([System.IO.Path]::DirectorySeparatorChar)
    if ($PathParts.Count -lt 3) {
        throw "Invalid package structure. Expected: ...\Company\Product\Package"
    }

    $Files = [System.IO.Directory]::GetFiles($PackagePath)
    if ($Files.Count -eq 0) {
        throw "Package folder is empty: $PackagePath"
    }

    $SupportedExtensions = @('.msi', '.exe', '.ps1', '.cmd', '.bat')
    $HasInstaller = $false
    foreach ($File in $Files) {
        if ([System.IO.Path]::GetExtension($File).ToLower() -in $SupportedExtensions) {
            $HasInstaller = $true
            break
        }
    }

    if (-not $HasInstaller) {
        throw "No supported installer files (.msi, .exe, .ps1, .cmd, .bat) found in: $PackagePath"
    }
    
    return $true
}
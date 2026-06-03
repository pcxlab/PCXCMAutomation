function Test-PCXPackageSource {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$PackagePath
    )

    #if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $PackagePath)) {

    if (-not ([System.IO.Directory]::Exists($PackagePath))) {
        throw "Source path does not exist."
    }

    $PathParts = $PackagePath.Split(
        [System.IO.Path]::DirectorySeparatorChar
    )

    if ($PathParts.Count -lt 3) {
        throw "Invalid package structure."
    }

    $Company = $PathParts[-3]
    $Product = $PathParts[-2]
    $PackageFolder = $PathParts[-1]

    if ([string]::IsNullOrWhiteSpace($Company)) {
        throw "Company name could not be determined."
    }

    if ([string]::IsNullOrWhiteSpace($Product)) {
        throw "Product name could not be determined."
    }

    if ([string]::IsNullOrWhiteSpace($PackageFolder)) {
        throw "Package folder could not be determined."
    }

    $Content = Get-ChildItem -Path $PackagePath -File -ErrorAction SilentlyContinue

    if (-not $Content) {
        throw "Package folder does not contain any files."
    }

    $InstallerFiles = Get-ChildItem $PackagePath -File | Where-Object {
        $_.Extension -in '.msi', '.exe', '.ps1', '.cmd', '.bat'
    }

    if (-not $InstallerFiles) {
        throw "No supported installer files found in package folder."
    }
    
    return $true
}
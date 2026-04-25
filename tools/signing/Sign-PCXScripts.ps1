#Sign-PCXScripts.ps1


# Get the first available code signing certificate from CurrentUser\My store
$cert = Get-ChildItem cert:\CurrentUser\My -CodeSigningCert | Select-Object -First 1

if (-not $cert) {
    Write-Error "No code signing certificate found in the CurrentUser\My store."
    exit 1
}

# Get the folder where this script resides
$basePath = $PSScriptRoot

# Find all PowerShell script files in that path and subfolders
$files = Get-ChildItem -Path $basePath -Recurse -Include *.ps1, *.psm1, *.psd1 | Where-Object { -not $_.PSIsContainer }

foreach ($file in $files) {
    Write-Host "Signing: $($file.FullName)"
    $signature = Set-AuthenticodeSignature -Certificate $cert -FilePath $file.FullName

    if ($signature.Status -ne 'Valid') {
        Write-Warning "Failed to sign: $($file.FullName) - Status: $($signature.Status)"
    }
}

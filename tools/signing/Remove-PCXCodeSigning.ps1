# Remove-PCXCodeSigning.ps1

# Get script location
$basePath = $PSScriptRoot

# Get all PowerShell files
$files = Get-ChildItem -Path $basePath -Recurse -Include *.ps1, *.psm1, *.psd1 |
    Where-Object { -not $_.PSIsContainer }

foreach ($file in $files) {
    Write-Host "Processing: $($file.FullName)"

    $content = Get-Content $file.FullName -Raw

    if ($content -match '# SIG # Begin signature block') {

        # Remove signature block safely
        $cleanContent = $content -replace '(?s)# SIG # Begin signature block.*?# SIG # End signature block', ''

        # Write back
        Set-Content -Path $file.FullName -Value $cleanContent -Encoding UTF8

        Write-Host "Signature removed"
    }
    else {
        Write-Host "No signature found"
    }
}
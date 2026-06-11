param(
    [string]$ModuleRoot = "C:\Projects\PCXLABCMAutomation_ADDOSREQ\src\Modules\PCXLab.SCCM\0.7.0"
)

$results = @()

# ==========================================================
# GET ONLY FILES
# ==========================================================

$files = Get-ChildItem `
    -Path $ModuleRoot `
    -Recurse `
    -Include *.ps1, *.psm1 `
    -File `
    -ErrorAction SilentlyContinue

foreach ($file in $files) {

    try {

        $content = Get-Content `
            -Path $file.FullName `
            -Raw `
            -ErrorAction Stop

        # ==================================================
        # MATCH REAL FUNCTION DECLARATIONS ONLY
        # ==================================================

        $matches = [regex]::Matches(
            $content,
            '(?m)^\s*function\s+([A-Za-z0-9\-]+)'
        )

        foreach ($match in $matches) {

            $functionName = $match.Groups[1].Value

            $expectedFileName = "$functionName.ps1"

            $actualFileName = $file.Name

            if ($file.FullName -match '\\Public\\') {
                $folderType = 'Public'
            }
            elseif ($file.FullName -match '\\Private\\') {
                $folderType = 'Private'
            }
            else {
                $folderType = 'Other'
            }

            $status = 'OK'
            $recommendation = ''

            # ==============================================
            # FILE/FUNCTION NAME MISMATCH
            # ==============================================

            if (
                $actualFileName -ne 'PCXLab.SCCM.psm1' -and
                $actualFileName -ne 'PCXLab.SCCM.psd1' -and
                $expectedFileName -ne $actualFileName
            ) {

                $status = 'FileMismatch'

                $recommendation = "Rename file to: $expectedFileName"
            }

            # ==============================================
            # LEGACY SCCM NAMING
            # ==============================================

            elseif ($functionName -match '^[A-Za-z]+-SCCM') {

                $newName = $functionName -replace '-SCCM', '-PCX'

                $status = 'LegacySCCM'

                $recommendation = "Suggested: $newName"
            }

            # ==============================================
            # PUBLIC SHOULD BE PCXCM
            # ==============================================

            elseif (
                $folderType -eq 'Public' -and
                $functionName -notmatch '^[A-Za-z]+-PCXCM'
            ) {

                $status = 'PublicNaming'

                $parts = $functionName.Split('-', 2)

                if ($parts.Count -eq 2) {

                    $recommendation =
                        "Review: $($parts[0])-PCXCM$($parts[1])"
                }
            }

            # ==============================================
            # PRIVATE SHOULD BE PCX
            # ==============================================

            elseif (
                $folderType -eq 'Private' -and
                $functionName -notmatch '^[A-Za-z]+-PCX'
            ) {

                $status = 'PrivateNaming'

                $parts = $functionName.Split('-', 2)

                if ($parts.Count -eq 2) {

                    $recommendation =
                        "Review: $($parts[0])-PCX$($parts[1])"
                }
            }

            # ==============================================
            # RESULT
            # ==============================================

            $results += [PSCustomObject]@{
                FolderType     = $folderType
                FunctionName   = $functionName
                FileName       = $actualFileName
                Status         = $status
                Recommendation = $recommendation
                FullPath       = $file.FullName
            }
        }
    }
    catch {

        $results += [PSCustomObject]@{
            FolderType     = 'Error'
            FunctionName   = ''
            FileName       = $file.Name
            Status         = 'ReadFailed'
            Recommendation = $_.Exception.Message
            FullPath       = $file.FullName
        }
    }
}

# ==========================================================
# DISPLAY
# ==========================================================

$results |
Sort-Object Status, FunctionName |
Format-Table -AutoSize

# ==========================================================
# SUMMARY
# ==========================================================

Write-Host ""
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "-------" -ForegroundColor Cyan

$results |
Group-Object Status |
Sort-Object Count -Descending |
Format-Table Count, Name -AutoSize

# ==========================================================
# EXPORT
# ==========================================================

$reportPath = Join-Path `
    $ModuleRoot `
    "PCXCM-Refactor-Audit.csv"

$results |
Export-Csv `
    -Path $reportPath `
    -NoTypeInformation `
    -Encoding UTF8

Write-Host ""
Write-Host "Audit report exported:" -ForegroundColor Cyan
Write-Host $reportPath -ForegroundColor Green



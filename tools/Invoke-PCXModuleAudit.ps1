param(
    [string]$ModuleRoot = "C:\Projects\PCXLABCMAutomation_ADDOSREQ\src\Modules\PCXLab.SCCM\0.7.0"
)

$Results = @()

Write-Host ""
Write-Host "Scanning module..." -ForegroundColor Cyan
Write-Host $ModuleRoot -ForegroundColor Yellow
Write-Host ""

$AllFiles = Get-ChildItem `
    -Path $ModuleRoot `
    -Recurse `
    -Filter *.ps1

foreach ($File in $AllFiles) {

    $Content = Get-Content `
        -Path $File.FullName `
        -Raw

    $FunctionMatches = [regex]::Matches(
        $Content,
        'function\s+([A-Za-z0-9\-]+)'
    )

    foreach ($Match in $FunctionMatches) {

        $FunctionName = $Match.Groups[1].Value

        $ExpectedFileName = "$FunctionName.ps1"

        if ($File.FullName -match '\\Public\\') {
            $FolderType = 'Public'
        }
        elseif ($File.FullName -match '\\Private\\') {
            $FolderType = 'Private'
        }
        else {
            $FolderType = 'Other'
        }

        $CallMatches = Get-ChildItem `
            -Path $ModuleRoot `
            -Recurse `
            -Filter *.ps1 |
            Select-String `
                -Pattern "\b$([regex]::Escape($FunctionName))\b"

        $CallerCount = (
            $CallMatches |
            Where-Object {
                $_.Path -ne $File.FullName
            }
        ).Count

        $Status = "Keep"

        if ($CallerCount -eq 0) {
            $Status = "ArchiveCandidate"
        }

        if (
            $FolderType -eq "Private" -and
            $FunctionName -match "SCCM"
        ) {
            $Status = "RenameCandidate"
        }

        if ($ExpectedFileName -ne $File.Name) {
            $Status = "FileMismatch"
        }

        $Results += [PSCustomObject]@{
            FunctionName = $FunctionName
            FileName = $File.Name
            FolderType = $FolderType
            CallerCount = $CallerCount
            Status = $Status
            FullPath = $File.FullName
        }
    }
}

Write-Host ""
Write-Host "========== SUMMARY ==========" -ForegroundColor Cyan

$Results |
Group-Object Status |
Sort-Object Name |
Select-Object Name,Count |
Format-Table -AutoSize

Write-Host ""
Write-Host "========== DETAILS ==========" -ForegroundColor Cyan

$Results |
Sort-Object Status,FunctionName |
Format-Table `
    FunctionName,
    FileName,
    FolderType,
    CallerCount,
    Status `
    -AutoSize

$CsvPath = Join-Path `
    $ModuleRoot `
    "PCXModuleAudit.csv"

$Results |
Export-Csv `
    -Path $CsvPath `
    -NoTypeInformation `
    -Encoding UTF8

Write-Host ""
Write-Host "Audit report exported:" -ForegroundColor Green
Write-Host $CsvPath -ForegroundColor Yellow
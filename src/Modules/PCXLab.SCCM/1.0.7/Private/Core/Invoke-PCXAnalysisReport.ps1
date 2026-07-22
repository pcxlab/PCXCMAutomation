function Invoke-PCXAnalysisReport {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $InputObjects,

        [Parameter(Mandatory)]
        [scriptblock]$ProcessObject,

        [Parameter(Mandatory)]
        [string]$ReportPath,

        [Parameter(Mandatory)]
        [string]$CheckpointPath
    )

    $Checkpoint = Get-PCXCheckpoint `
        -Path $CheckpointPath

    $ResumeFound = $false

    if ([string]::IsNullOrWhiteSpace($Checkpoint)) {
        $ResumeFound = $true
    }

    $null = Initialize-PCXAnalysisReport `
        -Path $ReportPath

    foreach ($InputObject in $InputObjects) {

        $CheckpointValue = if ($InputObject.PSObject.Properties['CI_ID']) {
            [string]$InputObject.CI_ID
        }
        elseif ($InputObject.PSObject.Properties['PackageID']) {
            [string]$InputObject.PackageID
        }
        elseif ($InputObject.PSObject.Properties['CollectionID']) {
            [string]$InputObject.CollectionID
        }
        else {
            [string]$InputObject
        }

        if (-not $ResumeFound) {

            if ($CheckpointValue -eq $Checkpoint) {

                Write-PCXLog `
                    -Message "Checkpoint Found: $CheckpointValue"

                $ResumeFound = $true
            }

            continue
        }

        Write-PCXLog `
            -Message "Processing: $CheckpointValue"

        $ResultObject = & $ProcessObject $InputObject

        Write-PCXAnalysisResult `
            -InputObject $ResultObject `
            -Path $ReportPath

        Save-PCXCheckpoint `
            -Path $CheckpointPath `
            -Value $CheckpointValue
    }

    Complete-PCXAnalysisReport `
        -Path $ReportPath
}

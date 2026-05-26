function Add-PCXCMApplicationOSRequirementFromCSV {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$CsvPath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Requirement,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$OSValidateSetPath,

        [Parameter(Mandatory = $false)]
        [string]$ReportPath,

        [switch]$AllowRequirementCreation
    )

    Write-Verbose "Starting bulk OS requirement processing"

    # Import applications
    $Applications = Import-PCXApplicationList `
        -CsvPath $CsvPath

    foreach ($ApplicationName in $Applications) {

        Write-Verbose "Processing application: $ApplicationName"

        try {

            $Result = Add-PCXCMApplicationOSRequirement `
                -ApplicationName $ApplicationName `
                -Requirement $Requirement `
                -OSValidateSetPath $OSValidateSetPath `
                -AllowRequirementCreation:$AllowRequirementCreation `
                -ReportPath $ReportPath

            Write-Verbose "Successfully processed: $ApplicationName"

            # Stream live result to console
            Write-Output $Result
        }
        catch {

            Write-Warning "Failed processing: $ApplicationName"

            $FailureResult = New-PCXReportObject `
                -ApplicationName $ApplicationName `
                -Requirement $Requirement `
                -Status "Failed" `
                -Message $_.Exception.Message `
                -Application $null

            # Persist failure immediately
            if ($ReportPath) {

                if (-not (Test-Path $ReportPath)) {

                    $FailureResult | Export-Csv `
                        -Path $ReportPath `
                        -NoTypeInformation `
                        -Encoding UTF8
                }
                else {

                    $FailureResult | Export-Csv `
                        -Path $ReportPath `
                        -NoTypeInformation `
                        -Encoding UTF8 `
                        -Append
                }
            }

            # Stream failure immediately to console
            Write-Output $FailureResult
        }
    }

    Write-Verbose "Bulk processing completed"
}
function Add-PCXCMApplicationOSRequirement {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ApplicationName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Requirement,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$OSValidateSetPath,

        [switch]$AllowRequirementCreation,

        [string]$ReportPath
    )
    begin {

        Write-PCXOperationStart
    }
    process {
        try {
            # Connect to SCCM Site
            Ensure-PCXCMConnection
            
            # Resolve SCCM Application
            $Application = Get-PCXCMApplication `
                -ApplicationName $ApplicationName

            # Deserialize XML
            $XML = Get-PCXApplicationXML `
                -Application $Application

            # Detect existing OS requirement
            $ExistingOSRequirement = $false
            foreach ($dt in $XML.DeploymentTypes) {
                foreach ($requirementObj in $dt.Requirements) {
                    if ($requirementObj.Expression.GetType().Name -eq 'OperatingSystemExpression') {
                        $ExistingOSRequirement = $true
                    }
                }
            }

            # ==========================================================
            # NO OS REQUIREMENT EXISTS
            # ==========================================================

            if (-not $ExistingOSRequirement) {
                # Creation not allowed
                if (-not $AllowRequirementCreation) {
                    $Result = New-PCXReportObject `
                        -ApplicationName $ApplicationName `
                        -Requirement $Requirement `
                        -Status "Skipped" `
                        -Application $Application

                    # Persist report immediately
                    if ($ReportPath) {
                        if (-not (Test-Path $ReportPath)) {
                            $Result | Export-Csv `
                                -Path $ReportPath `
                                -NoTypeInformation `
                                -Encoding UTF8
                        }
                        else {
                            $Result | Export-Csv `
                                -Path $ReportPath `
                                -NoTypeInformation `
                                -Encoding UTF8 `
                                -Append
                        }
                    }
                    return $Result
                }

                # Resolve Operand
                $Operand = Get-PCXOSRequirementOperand `
                    -Requirement $Requirement `
                    -CsvPath $OSValidateSetPath

                # Validate Operand
                if (-not $Operand) {
                    throw [System.ArgumentException]::new(
                        "Requirement not found in OS validation set: $Requirement"
                    )
                }

                # Create SCCM Requirement Rule
                $RequirementRule = New-PCXOSRequirementRule `
                    -Operand $Operand

                # Add Requirement using SCCM-native cmdlets
                Add-PCXOSRequirementToDeploymentType `
                    -ApplicationName $ApplicationName `
                    -RequirementRule $RequirementRule

                # Create result
                $Result = New-PCXReportObject `
                    -ApplicationName $ApplicationName `
                    -Requirement $Requirement `
                    -Status "Updated" `
                    -Application $Application

                # Persist report immediately
                if ($ReportPath) {
                    if (-not (Test-Path $ReportPath)) {
                        $Result | Export-Csv `
                            -Path $ReportPath `
                            -NoTypeInformation `
                            -Encoding UTF8
                    }
                    else {
                        $Result | Export-Csv `
                            -Path $ReportPath `
                            -NoTypeInformation `
                            -Encoding UTF8 `
                            -Append
                    }
                }
                return $Result
            }

            # ==========================================================
            # EXISTING REQUIREMENT DETECTION
            # ==========================================================

            $Exists = Test-PCXOSRequirementExists `
                -Xml $XML `
                -Requirement $Requirement

            if ($Exists) {
                $Result = New-PCXReportObject `
                    -ApplicationName $ApplicationName `
                    -Requirement $Requirement `
                    -Status "AlreadyExists" `
                    -Application $Application

                # Persist report immediately
                if ($ReportPath) {
                    if (-not (Test-Path $ReportPath)) {
                        $Result | Export-Csv `
                            -Path $ReportPath `
                            -NoTypeInformation `
                            -Encoding UTF8
                    }
                    else {
                        $Result | Export-Csv `
                            -Path $ReportPath `
                            -NoTypeInformation `
                            -Encoding UTF8 `
                            -Append
                    }
                }
                return $Result
            }

            # ==========================================================
            # XML MERGE PATH
            # ==========================================================

            # Resolve Operand
            $Operand = Get-PCXOSRequirementOperand `
                -Requirement $Requirement `
                -CsvPath $OSValidateSetPath

            # Validate Operand
            if (-not $Operand) {
                throw [System.ArgumentException]::new(
                    "Requirement not found in OS validation set: $Requirement"
                )
            }

            # Modify XML
            $Updated = Add-PCXOSRequirementToXML `
                -Xml $XML `
                -Requirement $Requirement `
                -Operand $Operand

            if (-not $Updated) {
                $Result = New-PCXReportObject `
                    -ApplicationName $ApplicationName `
                    -Requirement $Requirement `
                    -Status "Skipped" `
                    -Application $Application

                # Persist report immediately
                if ($ReportPath) {
                    if (-not (Test-Path $ReportPath)) {
                        $Result | Export-Csv `
                            -Path $ReportPath `
                            -NoTypeInformation `
                            -Encoding UTF8
                    }
                    else {
                        $Result | Export-Csv `
                            -Path $ReportPath `
                            -NoTypeInformation `
                            -Encoding UTF8 `
                            -Append
                    }
                }
                return $Result
            }

            # Save XML
            $null = Save-PCXApplicationXML `
                -Application $Application `
                -Xml $XML

            # Create result
            $Result = New-PCXReportObject `
                -ApplicationName $ApplicationName `
                -Requirement $Requirement `
                -Status "Updated" `
                -Application $Application

            # Persist report immediately
            if ($ReportPath) {
                if (-not (Test-Path $ReportPath)) {
                    $Result | Export-Csv `
                        -Path $ReportPath `
                        -NoTypeInformation `
                        -Encoding UTF8
                }
                else {
                    $Result | Export-Csv `
                        -Path $ReportPath `
                        -NoTypeInformation `
                        -Encoding UTF8 `
                        -Append
                }
            }
            return $Result
        }
        catch {
            Write-PCXLog -Message "Failed OS requirement operation for application '$ApplicationName'. $($_.Exception.Message)" -Level ERROR
throw
        }
    }
    end {
        Write-PCXOperationEnd -Status Success
    }
}






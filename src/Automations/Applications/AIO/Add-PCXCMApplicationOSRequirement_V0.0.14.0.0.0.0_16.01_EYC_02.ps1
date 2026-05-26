<#
.SYNOPSIS
    Updates the operating system requirement for applications managed by Microsoft Endpoint Configuration Manager (MECM).

.DESCRIPTION
    The Add-PCXCMApplicationOSRequirement function automates the updating of OS requirement limitations for existing applications in MECM to include Windows 11.
    It performs the following tasks:
        - Connects to the specified MECM site using the provided site code and SMS Provider machine name.
        - Reads application names from a specified CSV file.
        - Checks if the Windows 11 OS requirements are already set for each application.
        - If not, updates the OS requirements to include Windows 11.
        - Logs the process and generates a comprehensive report.
        - Allows the inclusion of verbose output and error handling.
        - Generates logs in the script root directory with timestamps.

.PARAMETER Requirement
    The OS requirement to be added to the application. Possible values are read from the OSValidateSet.csv file located in the script's root directory.

.NOTES
    Developed by: Roopesh Shet
    Reviewed by: Sarat, Prajith
    Approved by: Chetan

.EXAMPLE
    .\Add-PCXCMApplicationOSRequirement.ps1 -Verbose

    This command runs the script with verbose output enabled.

.INPUTS
    None. You cannot pipe objects to this script.

.OUTPUTS
    The script generates a CSV report summarizing the updates made to each application, including their status, package ID, version, and modification details.
    The script logs the process in a log file located in the script root directory.
#>


##########################################################
#
# Press 'F5' to run this script. Running this script will load the ConfigurationManager
# module for Windows PowerShell and will connect to the site.
#
# This script was auto-generated at '5/28/2024 9:00:55 PM'.

<# Site configuration
$SiteCode = "PS1" # Site code 
$ProviderMachineName = "CM01.corp.pcxlab.com" # SMS Provider machine name

# Customizations
$initParams = @{}
#$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
#$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

# Do not change anything below this line

# Import the ConfigurationManager.psd1 module 
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}

# Connect to the site's drive if it is not already present
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}

# Set the current location to be the site code.
Set-Location "$($SiteCode):\" @initParams

#>
##########################################################
# Get time function
function Get-Timestamp {
    return Get-Date -Format "yyyyMMdd_HHmmss"
}

$LogTimestamp = Get-Timestamp

# Start logging
Start-Transcript -Path "$PSScriptRoot\Add-PCXCMApplicationOSRequirement_$LogTimestamp.log" -Append


function Add-PCXCMApplicationOSRequirement {
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        $appName,
        [Parameter(Position=1, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $siteCode,
        [Parameter(Position=2, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $siteServer
    )

    dynamicparam {
        $attributes = New-Object System.Management.Automation.ParameterAttribute
        $attributes.ParameterSetName = "__AllParameterSets"
        $attributes.Mandatory = $true
        $attributeCollection = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
        $attributeCollection.Add($attributes)

        $values = Get-Content "$PSScriptRoot\OSValidateSet.csv" | ForEach-Object {
            "$($PSItem.Split(",")[0])"
        }
        $ValidateSet = New-Object System.Management.Automation.ValidateSetAttribute($values)
        $attributeCollection.Add($ValidateSet)

        $dynParam1 = New-Object -Type System.Management.Automation.RuntimeDefinedParameter("Requirement", [string], $attributeCollection)
        $paramDictionary = New-Object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
        $paramDictionary.Add("Requirement", $dynParam1)
        return $paramDictionary
    }

    begin {
        if ($Verbose) {
            Write-Verbose "Starting Add-PCXCMApplicationOSRequirement function..."
        }
        Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" -Force
        if ((Get-PSDrive $sitecode -ErrorAction SilentlyContinue | Measure).Count -ne 1) {
            if ($Verbose) {
                Write-Verbose "Creating new PS drive..."
            }
            New-PSDrive -Name $SiteCode -PSProvider "AdminUI.PS.Provider\CMSite" -Root $SiteServer
        }

        if ($Verbose) {
            Write-Verbose "Creating hash table from OSValidateSet.csv..."
        }
        $NamedPairs = @{}
        Get-Content "$PSScriptRoot\OSValidateSet.csv" | ForEach-Object {
            $name = $PSItem.Split(",")[0]
            $operand = $PSItem.Split(",")[1]
            $NamedPairs.Add($name, $operand)
        }

        Set-Location $sitecode`:
    }

    process {
        if ($Verbose) {
            Write-Verbose "Processing application: $appName"
        }
        try {
            $Appdt = Get-CMApplication -Name $appName -ErrorAction Stop
            if (-not $Appdt) {
                throw [System.Exception]::new("Application '$appName' not found.")
            }
            $CreatedDate = $Appdt.DateCreated
            $CreatedBy = $Appdt.CreatedBy
            $DateLastModified = $Appdt.DateLastModified
            $LastModifiedBy = $Appdt.LastModifiedBy
            $CIVersion = $Appdt.CIVersion
            $PackageID = $Appdt.PackageID
            $SourceSite = $Appdt.SourceSite

            if (-not $Appdt.SDMPackageXML) {
                throw [System.Exception]::new("SDMPackageXML is missing for application '$appName'")
            }

            $xml = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($Appdt.SDMPackageXML, $True)

            $operand = $NamedPairs[$dynParam1.Value].Trim()
            $namedRequirement = $dynParam1.Value
            if ($Verbose) {
                Write-Verbose "Operand $operand"
                Write-Verbose "Requirement $namedRequirement"
            }
            $updated = $false
            foreach ($dt in $xml.DeploymentTypes) {
                foreach ($requirement in $dt.Requirements) {
                    if ($requirement.Expression.GetType().Name -eq 'OperatingSystemExpression') {
                        if ($requirement.Name -NotLike "*$namedRequirement*") {
                            if ($Verbose) {
                                Write-Verbose "Found an OS Requirement, appending value to it"
                            }
                            $requirement.Expression.Operands.Add("$operand")
                            $requirement.Name = [regex]::replace($requirement.Name, '(?<=Operating system One of {)(.*)(?=})', "`$1, $namedRequirement")
                            $null = $dt.Requirements.Remove($requirement)
                            $requirement.RuleId = "Rule_$([guid]::NewGuid())"
                            $null = $dt.Requirements.Add($requirement)
                            $updated = $true
                            break
                        }
                    }
                }
            }
            if ($updated) {
                $UpdatedXML = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::SerializeToString($xml, $True)
                $Appdt.SDMPackageXML = $UpdatedXML
                $Appdt.put()
                $t = Set-CMApplication -InputObject $Appdt -PassThru
                return @{
                    Status = "Updated"
                    CreatedDate = $CreatedDate
                    CreatedBy = $CreatedBy
                    DateLastModified = $DateLastModified
                    LastModifiedBy = $LastModifiedBy
                    CIVersion = $CIVersion
                    PackageID = $PackageID
                    SourceSite = $SourceSite
                }
            } else {
                return @{
                    Status = "Already exists"
                    CreatedDate = $CreatedDate
                    CreatedBy = $CreatedBy
                    DateLastModified = $DateLastModified
                    LastModifiedBy = $LastModifiedBy
                    CIVersion = $CIVersion
                    PackageID = $PackageID
                    SourceSite = $SourceSite
                }
            }
        } catch {
            if ($_.Exception.Message -like "*SDMPackageXML is missing*") {
                Write-Error "SDMPackageXML is missing for application '$appName': $_"
            } elseif ($_.Exception.Message -like "*Application '* not found.*") {
                Write-Error "Application '$appName' not found: $_"
            } else {
                Write-Error "An error occurred with application '$appName': $_"
            }
            return @{
                Status = "Application not found"
                CreatedDate = $null
                CreatedBy = $null
                DateLastModified = $null
                LastModifiedBy = $null
                CIVersion = $null
                PackageID = $null
                SourceSite = $null
            }
        }
   
}

    end {
        if ($Verbose) {
            Write-Verbose "Ending Add-PCXCMApplicationOSRequirement function..."
        }
        Set-Location $PSScriptRoot
    }
}

# Load configuration settings
function Load-Configuration {
    param (
        [string]$configFilePath
    )
    try {
        if (Test-Path $configFilePath) {
            $config = [xml](Get-Content $configFilePath)
            return $config
        } else {
            Write-Error "Configuration file not found."
            return $null
        }
    } catch {
        Write-Error "Failed to load configuration: $_"
        return $null
    }
}

# Read application names from CSV file
function Read-ApplicationNames {
    param (
        [string]$csvFilePath
    )
    try {
        $appNames = Import-Csv -Path $csvFilePath | Select-Object -ExpandProperty "Application Name"
        if ($appNames.Count -eq 0) {
            Write-Error "No application names found in the CSV file."
        } else {
            if ($Verbose) {
                Write-Verbose "Found $($appNames.Count) application names in the CSV file."
            }
        }
        return $appNames
    } catch {
        Write-Error "Failed to read application names: $_"
        return @()
    }
}

<# 
function Get-Timestamp {
    return Get-Date -Format "yyyyMMdd_HHmmss"
}
#>

function Resolve-ReportPath {
    param (
        [string]$outputPath,
        [string]$reportFileName
    )
    return Resolve-Path "$outputPath\$reportFileName"
}

function Generate-Report {
    param (
        [Array]$reportData,
        [string]$outputPath
    )
    $timestamp = Get-Timestamp
    $reportFileName = "CMAplicationOSReqUpdateReport_$timestamp.csv"
    $reportFilePath = "$outputPath\$reportFileName"

    $reportData | Export-Csv -Path $reportFilePath -NoTypeInformation
    return Resolve-ReportPath -outputPath $outputPath -reportFileName $reportFileName
}

# Load configuration settings
$configFilePath = "$PSScriptRoot\ConfigFile.xml"
$config = Load-Configuration -configFilePath $configFilePath
$siteCode = $config.Configuration.SiteCode
$siteServer = $config.Configuration.SiteServer
$requirement = $config.Configuration.Requirement

# Read application names from CSV file
$appNamesFromCSV = Read-ApplicationNames -csvFilePath "$PSScriptRoot\applicationlist.csv"
if ($appNamesFromCSV.Count -eq 0) {
    Write-Error "No application names found in the CSV file."
    exit
}

# Initialize the report array
$report = @()

<# 
foreach ($appName in $appNamesFromCSV) {
    if ($Verbose) {
        Write-Verbose "Processing application: $appName"
    }
    $result = Add-PCXCMApplicationOSRequirement -appName $appName -siteCode $siteCode -siteServer $siteServer -Requirement $requirement # -Verbose
    $report += [PSCustomObject]@{
        ApplicationName  = $appName
        Requirement      = $requirement
        Status           = $result.Status
        PackageID        = $result.PackageID
        CIVersion        = $result.CIVersion
        SourceSite       = $result.SourceSite
        CreatedDate      = $result.CreatedDate
        CreatedBy        = $result.CreatedBy
        DateLastModified = $result.DateLastModified
        LastModifiedBy   = $result.LastModifiedBy
    }
}

#>
foreach ($appName in $appNamesFromCSV) {
    if ($Verbose) {
        Write-Verbose "Processing application: $appName"
    }
    try {
        Set-Location $sitecode`:  # Change to the site's PSDrive
        $Appdt = Get-CMApplication -Name $appName -ErrorAction Stop
        if (-not $Appdt) {
            Write-Error "Application '$appName' not found."
            #Write-Host "Application '$appName' not found."
            $report += [PSCustomObject]@{
                ApplicationName  = $appName
                Requirement      = $requirement
                Status           = "Application not found"
                PackageID        = $null
                CIVersion        = $null
                SourceSite       = $null
                CreatedDate      = $null
                CreatedBy        = $null
                DateLastModified = $null
                LastModifiedBy   = $null
            }
            continue  # Skip processing this application and move to the next one
        }

        # Rest of the processing for updating OS requirement goes here
        #$result = Add-PCXCMApplicationOSRequirement -appName $appName -siteCode $siteCode -siteServer $siteServer -Requirement $requirement -Verbose
        $result = Add-PCXCMApplicationOSRequirement -appName $appName -siteCode $siteCode -siteServer $siteServer -Requirement $requirement #-Verbose
        $report += [PSCustomObject]@{
            ApplicationName  = $appName
            Requirement      = $requirement
            Status           = $result.Status
            PackageID        = $result.PackageID
            CIVersion        = $result.CIVersion
            SourceSite       = $result.SourceSite
            CreatedDate      = $result.CreatedDate
            CreatedBy        = $result.CreatedBy
            DateLastModified = $result.DateLastModified
            LastModifiedBy   = $result.LastModifiedBy
        }
    } catch {
        Write-Error "An error occurred with application '$appName': $_"
        $report += [PSCustomObject]@{
            ApplicationName  = $appName
            Requirement      = $requirement
            Status           = "Error"
            PackageID        = $null
            CIVersion        = $null
            SourceSite       = $null
            CreatedDate      = $null
            CreatedBy        = $null
            DateLastModified = $null
            LastModifiedBy   = $null
        }
    } finally {
        Set-Location $PSScriptRoot  # Change back to the original location
    }
}


# Generate the report
$reportFilePath = Generate-Report -reportData $report -outputPath $PSScriptRoot

Write-Output "Report generated at $reportFilePath"

# End logging
Stop-Transcript

#END












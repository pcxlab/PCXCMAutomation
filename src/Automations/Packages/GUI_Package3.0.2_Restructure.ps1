# File GUI_Package.ps1

# ================================
# SCCM Package GUI Tool
# ================================

Clear-Host
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationFramework


"F:\Development\SCCM_PS_GUI6.0.3\Functions.ps1"
#"F:\Development\SCCM_PS_GUI6.0.3\Package Function_V0.8.4.0.ps1"
"F:\Development\SCCM_PS_GUI6.0.3\Connect-PCXCMSite.ps1"
#"F:\Development\SCCM_PS_GUI6.0.3\New-PCXCMFolder_V02.03.02_A.ps1"
#"F:\Development\SCCM_PS_GUI6.0.3\Get-PCXCMSiteCode.ps1"

function Get-PCXCMSiteCode {
    [CmdletBinding()]
    param()
    try {
        $siteObj = Get-WmiObject -Namespace 'Root\SMS' -Class SMS_ProviderLocation -ComputerName '.'
        $code = if ($siteObj -is [array]) { $siteObj[0].SiteCode } else { $siteObj.SiteCode }
        return $code
    } catch {
        Throw "Error retrieving SCCM site code: $_"
    }
}

function New-PCXCMFolder {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string]$Path,

        [string]$Name
    )

    Write-Verbose "********** Function Begin **********"

    try {
        # -------------------------------
        # Step 1: Detect and extract SiteCode
        # -------------------------------
        $siteCode = $null
        $cleanPath = $null

        if ($Path -match '^[A-Za-z0-9]{3}:\\') {
            # Path includes PSDrive (e.g., PS1:\...)
            $siteCode = $Path.Substring(0,3)
            $cleanPath = $Path.Substring(4)
            Write-Verbose "Detected PSDrive in path: $siteCode"
        }
        else {
            # No PSDrive → use function
            $siteCode = Get-PCXCMSiteCode
            if (-not $siteCode) {
                throw "Failed to retrieve SCCM Site Code."
            }
            $cleanPath = $Path
            Write-Verbose "Using detected SiteCode: $siteCode"
        }

        # -------------------------------
        # Step 2: Ensure ConfigMgr Module + PSDrive
        # -------------------------------
        if (-not (Get-PSDrive -Name $siteCode -ErrorAction SilentlyContinue)) {

            Write-Verbose "PSDrive '$siteCode' not found. Attempting to initialize..."

            $cmModulePath = Join-Path $ENV:SMS_ADMIN_UI_PATH "..\ConfigurationManager.psd1"

            if (-not (Test-Path $cmModulePath)) {
                throw "ConfigurationManager module not found. Install SCCM Console."
            }

            Import-Module $cmModulePath -ErrorAction Stop
            Write-Verbose "ConfigurationManager module loaded."

            try {
                Set-Location "$siteCode`:" -ErrorAction Stop
                Write-Verbose "Connected to site drive: $siteCode"
            }
            catch {
                throw "Failed to switch to PSDrive '$siteCode'. Verify site code."
            }
        }

        $rootPath = "$siteCode`:"
        
        # -------------------------------
        # Step 3: Normalize Path
        # -------------------------------
        $cleanPath = $cleanPath.Trim('\')

        if ([string]::IsNullOrWhiteSpace($cleanPath)) {
            throw "Path cannot be empty."
        }

        $segments = ($cleanPath -split '\\') | Where-Object { $_ }

        Write-Verbose "Normalized Path: $cleanPath"
        Write-Verbose "Segments: $($segments -join ' -> ')"

        # -------------------------------
        # Step 4: Create Path Step-by-Step
        # -------------------------------
        $currentPath = $rootPath

        foreach ($folder in $segments) {
            $nextPath = Join-Path $currentPath $folder

            if (-not (Test-Path $nextPath)) {
                if ($PSCmdlet.ShouldProcess($nextPath, "Create folder")) {
                    New-Item -Path $currentPath -Name $folder -ItemType Directory -ErrorAction Stop
                    Write-Verbose "Created: $nextPath"
                }
            }
            else {
                Write-Verbose "Exists: $nextPath"
            }

            $currentPath = $nextPath
        }

        # -------------------------------
        # Step 5: Handle Optional Name
        # -------------------------------
        if ($Name) {
            if ([string]::IsNullOrWhiteSpace($Name)) {
                throw "Folder name cannot be empty."
            }

            $finalPath = Join-Path $currentPath $Name

            if (-not (Test-Path $finalPath)) {
                if ($PSCmdlet.ShouldProcess($finalPath, "Create folder")) {
                    New-Item -Path $currentPath -Name $Name -ItemType Directory -ErrorAction Stop
                    Write-Verbose "Created final folder: $finalPath"
                }
            }
            else {
                Write-Verbose "Final folder already exists: $finalPath"
            }
        }
        else {
            # No Name → full path already created
            $finalPath = $currentPath
            Write-Verbose "No child name provided. Full path ensured."
        }

        # -------------------------------
        # Step 6: Return Result
        # -------------------------------
        return [PSCustomObject]@{
            Success  = $true
            Path     = $finalPath
            SiteCode = $siteCode
        }
    }
    catch {
        Write-Error "Failed: $($_.Exception.Message)"

        return [PSCustomObject]@{
            Success = $false
            Error   = $_.Exception.Message
        }
    }
}

function Create-Package { 
    param(
        [parameter(mandatory=$false)] [string] $Language = "EN-US",
        [parameter(mandatory=$true)] [string] $Path,
        [parameter(mandatory=$false)] [string] $LimitingCollectionName = "All Windows Workstation or Professional Systems",
        [parameter(mandatory=$false)] [string] $DistributionPoinGroupName = "Mangalore Distribution point",
        [parameter(mandatory=$false)] [datetime] $DeadlineTime
    )

    Clear-Host

    #Write-Host "DP Group NAme is $DistributionPoinGroupName"

    <# FOR TEST ONLY###########################################################
    $Path = "\\192.168.25.214\Package_Source\Applications\Google\Chrome\Google_Chrome_145.0.7632.46"
    $Language = "EN-US"
    $LimitingCollectionName = "ALL Systems"
    $DistributionPoinGroupName = "ALL Mangalore Group"
    # FOR TEST ONLY########################################################### #>

    <#
    $Path = "\\172.16.100.56\Package_Source\Applications\Google\Chrome\Google_Chrome_500.0.7499.41"
    $Language = "EN-US"
    $LimitingCollectionName = "ALL Systems"
    # $DistributionPoinGroupName = "Mphasis & DR - Distribution Point of Application Pacakge Deployment"
    $DistributionPoinGroupName = "Mangalore Distribution point"
    #>

    # ---------------------------------------
    # Extract package details from given path
    # ---------------------------------------
    $pathSPlit = $Path -split "\\"

    $Packagename = $pathSPlit[-1]
    $Company     = $pathSPlit[-3]
    $Product     = $pathSPlit[-2]

    Write-Host "Package name: $Packagename" -ForegroundColor Yellow
    Write-Host "Company/Manufacturer: $Company" -ForegroundColor Yellow
    Write-Host "Product/Application: $Product" -ForegroundColor Yellow

    $PackageTest = Get-CMPackage -Name $Packagename

    if ($PackageTest -ne $null) {
        Write-Host "Package already present. Please delete before adding new $Packagename"
        return
    }
    
    # ---------------------------------------
    # Extract version from package name
    # ---------------------------------------
    $VersionSPlit = $Packagename -split " "
    $Version      = $VersionSPlit[-1]

    Write-Host "Version: $Version" -ForegroundColor Green

    # ---------------------------------------
    # Generate program names
    # ---------------------------------------
    $ProgramName1 = $Packagename + " [AVAILABLE]"
    $ProgramName2 = $Packagename + " [INSTALL]"
    $ProgramName3 = $Packagename + " [UNINSTALL]"

    Write-Host "ProgramName1: $ProgramName1" -ForegroundColor Green
    Write-Host "ProgramName2: $ProgramName2" -ForegroundColor Green
    Write-Host "ProgramName3: $ProgramName3" -ForegroundColor Green

    # ---------------------------------------
    # Generate collection names
    # ---------------------------------------
    $CollectionName1 = $Packagename + " [AVAILABLE]"
    $CollectionName2 = $Packagename + " [INSTALL]"
    $CollectionName3 = $Packagename + " [UNINSTALL]"
    $CollectionName4 = $Packagename + " [EXCEPTION]"

    Write-Host "CollectionName1: $CollectionName1" -ForegroundColor Green
    Write-Host "CollectionName2: $CollectionName2" -ForegroundColor Green
    Write-Host "CollectionName3: $CollectionName3" -ForegroundColor Green
    Write-Host "CollectionName4: $CollectionName4" -ForegroundColor Green

    # ---------------------------------------
    # Create SCCM package
    # ---------------------------------------
    New-CMPackage -Name $Packagename -Manufacturer $Company -Version $Version -Language $Language -Path $Path
    Write-Host "Package createda" -ForegroundColor Green
                                                                     
    # ---------------------------------------
    # Create programs (Available / Install / Uninstall)
    # ---------------------------------------
    New-CMProgram -PackageName $Packagename -StandardProgramName $ProgramName1 -CommandLine "install.exe" -RunMode RunWithAdministrativeRights -ProgramRunType WhetherOrNotUserIsLoggedOn
    New-CMProgram -PackageName $Packagename -StandardProgramName $ProgramName2 -CommandLine "install.bat" -RunMode RunWithAdministrativeRights -ProgramRunType WhetherOrNotUserIsLoggedOn
    New-CMProgram -PackageName $Packagename -StandardProgramName $ProgramName3 -CommandLine "uninstall.bat" -RunMode RunWithAdministrativeRights -ProgramRunType WhetherOrNotUserIsLoggedOn

    Write-Host "Programs created" -ForegroundColor Green
                 
    # ---------------------------------------
    # Create device collections
    # ---------------------------------------
    New-CMDeviceCollection -Name $CollectionName1 -LimitingCollectionName $LimitingCollectionName
    New-CMDeviceCollection -Name $CollectionName2 -LimitingCollectionName $LimitingCollectionName
    New-CMDeviceCollection -Name $CollectionName3 -LimitingCollectionName $LimitingCollectionName
    New-CMDeviceCollection -Name $CollectionName4 -LimitingCollectionName $LimitingCollectionName

    Write-Host "Collections created" -ForegroundColor Green
     
    # ---------------------------------------
    # Distribute content to DP group
    # ---------------------------------------
    Write-Host "Updatating GP group : $DistributionPoinGroupName" -ForegroundColor Yellow
    Start-CMContentDistribution -PackageName $Packagename -DistributionPointGroupName $DistributionPoinGroupName
    Write-Host "Distribution Point Group updated" -ForegroundColor Green
          
    # ---------------------------------------
    # Deploy programs to collections
    # ---------------------------------------
    $ProgramComment = $Packagename + " Program"
    
    New-CMPackageDeployment -StandardProgram -PackageName $Packagename -CollectionName $CollectionName1 -Comment "$ProgramComment" -DeployPurpose Available -ProgramName $ProgramName1
    New-CMPackageDeployment -StandardProgram -PackageName $Packagename -CollectionName $CollectionName2 -Comment "$ProgramComment" -DeployPurpose Available -ProgramName $ProgramName2
    #New-CMPackageDeployment -StandardProgram -PackageName $Packagename -CollectionName $CollectionName3 -Comment "$ProgramComment" -DeployPurpose Required -ProgramName $ProgramName3


    # Create deadline schedule (default: today 8 PM + 10 days)
    $DeadlineTime        = (Get-Date -Hour 20 -Minute 0 -Second 0).AddDays(30)
    $NewScheduleDeadline = New-CMSchedule -Start $DeadlineTime -Nonrecurring
    
    New-CMPackageDeployment -StandardProgram -PackageName $Packagename -ProgramName $ProgramName3 -DeployPurpose Required -CollectionName $CollectionName3 -Schedule $NewScheduleDeadline   

    Write-Host "Program deployed to collections" -ForegroundColor Green

    $siteCode = Get-PCXCMSiteCode
    $CollectionFolder =  "\DeviceCollection\Mphasis Application Deployment\$Company\$Product\$Packagename"
    $CollectionFolderPath = "$siteCode" + ":$CollectionFolder"

    #$CollectionFolderPath =  "\DeviceCollection\Mphasis Application Deployment\$Company\$Product\$Packagename\"
    
    New-PCXCMFolder -Path $CollectionFolder

    # Move the collection to the specified folder
    $CollectionObject = Get-CMDeviceCollection -Name $CollectionName1 # Available 
    Move-CMObject -FolderPath $CollectionFolderPath -InputObject $CollectionObject
    Write-Host "Collection '$CollectionName' is Moved to '$CollectionFolderPath'"

    $CollectionObject = Get-CMDeviceCollection -Name $CollectionName2 # Install
    Move-CMObject -FolderPath $CollectionFolderPath -InputObject $CollectionObject
    Write-Host "Collection '$CollectionName' is Moved to '$CollectionFolderPath'"

    $CollectionObject = Get-CMDeviceCollection -Name $CollectionName3 # Uninstall
    Move-CMObject -FolderPath $CollectionFolderPath -InputObject $CollectionObject
    Write-Host "Collection '$CollectionName' is Moved to '$CollectionFolderPath'"

    $CollectionObject = Get-CMDeviceCollection -Name $CollectionName4 # Exception
    Move-CMObject -FolderPath $CollectionFolderPath -InputObject $CollectionObject
    Write-Host "Collection '$CollectionName' is Moved to '$CollectionFolderPath'"

    Add-CMDeviceCollectionIncludeMembershipRule -CollectionName $CollectionName4 -IncludeCollectionName $CollectionName3
    Add-CMDeviceCollectionExcludeMembershipRule -CollectionName $CollectionName2 -ExcludeCollectionName $CollectionName4

    $siteCode = Get-PCXCMSiteCode
    $PackageFolder = "\Package\Application Installation\$Company\$Product"
    $PackageFolderFolderPath = "$siteCode" + ":$PackageFolder"

    New-PCXCMFolder -Path $PackageFolder
    $PackageObject = Get-CMPackage -Name $Packagename # Exception
    Move-CMObject -FolderPath $PackageFolderFolderPath -InputObject $PackageObject
    Write-Host "Pacakge '$Packagename' is Moved to '$PackageFolderFolderPath'"

}

<#
. "$PSScriptRoot\Functions.ps1"
. "$PSScriptRoot\Package Function_V0.8.4.0.ps1"
. "$PSScriptRoot\Connect-PCXCMSite.ps1"
. "$PSScriptRoot\New-PCXCMFolder_V02.03.02_A.ps1"
. "$PSScriptRoot\Get-PCXCMSiteCode.ps1"

#>
# Connect SCCM
#
# Press 'F5' to run this script. Running this script will load the ConfigurationManager
# module for Windows PowerShell and will connect to the site.
#
# This script was auto-generated at '8/14/2025 10:42:50 AM'.

# Site configuration
$SiteCode = "CSS" # Site code 
$ProviderMachineName = "SRVBAN19CASVM01.corp.mphasis.com" # SMS Provider machine name

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

# ================================
# XAML UI
# ================================
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="SCCM Package Tool" Height="450" Width="400">

    <Grid Margin="10">

        <Label Content="Source Path:" VerticalAlignment="Top"/>
        <!--TextBox Name="txtSourcePath" Margin="0,25,0,0" Height="25" VerticalAlignment="Top"/-->

        <TextBox Name="txtSourcePath" Margin="0,25,80,0" Height="25" VerticalAlignment="Top"/>

        <Button Name="btnBrowse" Content="..." Width="60" Height="25"
        Margin="0,25,0,0" HorizontalAlignment="Right" VerticalAlignment="Top"/>

        <Label Content="Package Name:" Margin="0,60,0,0" VerticalAlignment="Top"/>
        <TextBox Name="txtPackageName" Margin="0,85,0,0" Height="25" VerticalAlignment="Top" IsReadOnly="True"/>

        <Label Content="Company:" Margin="0,120,0,0" VerticalAlignment="Top"/>
        <TextBox Name="txtCompany" Margin="0,145,0,0" Height="25" VerticalAlignment="Top" IsReadOnly="True"/>

        <Label Content="Product:" Margin="0,180,0,0" VerticalAlignment="Top"/>
        <TextBox Name="txtProduct" Margin="0,205,0,0" Height="25" VerticalAlignment="Top" IsReadOnly="True"/>

        <Label Content="Version:" Margin="0,240,0,0" VerticalAlignment="Top"/>
        <TextBox Name="txtVersion" Margin="0,265,0,0" Height="25" VerticalAlignment="Top" IsReadOnly="True"/>

        <Button Name="btnCreatePackage" Content="Create Package" Height="30" Margin="0,310,0,0" VerticalAlignment="Top"/>

        <TextBlock Name="txtStatus" Margin="0,350,0,0" Height="60" TextWrapping="Wrap"/>

    </Grid>
</Window>
"@

# ================================
# Load UI
# ================================
$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

# ================================
# Get Controls
# ================================
$txtSourcePath   = $window.FindName("txtSourcePath")
$txtPackageName  = $window.FindName("txtPackageName")
$txtCompany      = $window.FindName("txtCompany")
$txtProduct      = $window.FindName("txtProduct")
$txtVersion      = $window.FindName("txtVersion")
$btnCreatePackage = $window.FindName("btnCreatePackage")
$txtStatus       = $window.FindName("txtStatus")
$btnBrowse       = $window.FindName("btnBrowse")

# ================================
# Auto-fill from Path
# ================================
$txtSourcePath.Add_TextChanged({

    $path = $txtSourcePath.Text

    if ([string]::IsNullOrWhiteSpace($path)) {
        return
    }

    try {
        $pathSplit = $path -split "\\"

        if ($pathSplit.Count -lt 3) {
            return
        }

        $packageName = $pathSplit[-1]
        $company     = $pathSplit[-3]
        $product     = $pathSplit[-2]

        $versionSplit = $packageName -split " "
        $version = $versionSplit[-1]

        # Populate UI
        $txtPackageName.Text = $packageName
        $txtCompany.Text     = $company
        $txtProduct.Text     = $product
        $txtVersion.Text     = $version
    }
    catch {
        # silent
    }
})

# ================================
# Browse Button (Explorer Style)
# ================================
$btnBrowse.Add_Click({

    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Title = "Select any file inside the Package folder"
    $openFileDialog.InitialDirectory = "C:\"
    $openFileDialog.Filter = "All files (*.*)|*.*"

    if ($openFileDialog.ShowDialog() -eq "OK") {

        # Get folder from selected file
        $folderPath = Split-Path $openFileDialog.FileName -Parent

        # Set to textbox (this will trigger auto-fill automatically)
        $txtSourcePath.Text = $folderPath
    }

})

# ================================
# Button Click
# ================================
$btnCreatePackage.Add_Click({

    $srcPath = $txtSourcePath.Text

    if ([string]::IsNullOrWhiteSpace($srcPath)) {
        $txtStatus.Text = "Enter Source Path!"
        return
    }

    try {
        $txtStatus.Text = "Running package creation..."

        # CALL YOUR FUNCTION (NO CHANGE)
        Create-Package -Path $srcPath

        $txtStatus.Text = "Package creation completed!"
    }
    catch {
        $txtStatus.Text = $_.Exception.Message
    }

})

# ================================
# Show Window
# ================================
$window.ShowDialog() | Out-Null



# SIG # Begin signature block
# MIIKmwYJKoZIhvcNAQcCoIIKjDCCCogCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUzFzWO0CpPeHHy7CCzG9Gc+2a
# HGygggfxMIIH7TCCBdWgAwIBAgITfgAqDS38gi3RBcr9PwAAACoNLTANBgkqhkiG
# 9w0BAQsFADBcMRMwEQYKCZImiZPyLGQBGRYDY29tMRcwFQYKCZImiZPyLGQBGRYH
# bXBoYXNpczEUMBIGCgmSJomT8ixkARkWBGNvcnAxFjAUBgNVBAMTDU1waGFzaXNS
# b290Q0EwHhcNMjUwMTI3MTIxNTE1WhcNMjcwMTI3MTIxNTE1WjCBuTETMBEGCgmS
# JomT8ixkARkWA2NvbTEXMBUGCgmSJomT8ixkARkWB21waGFzaXMxFDASBgoJkiaJ
# k/IsZAEZFgRjb3JwMR0wGwYDVQQLExRNcGhhc2lTIEJQTyBTZXJ2aWNlczESMBAG
# A1UECxMJTWFuZ2Fsb3JlMRQwEgYDVQQLEwtNb3JnYW4gR2F0ZTESMBAGA1UECxMJ
# QWxsIFVzZXJzMRYwFAYDVQQDEw1IYXJzaGl0aHJhaiBQMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEAxMQa6w0z2RxDuXsD42TVI+y6pNJGSfctL3Wo7FlZ
# 13PDFGwzrJ+MHYrHdXbTDXx9QNwRmp1XEACLBzXvtfkTvptoJXm8S5an710FmIhQ
# X1UaRtMBmxcPHPXYx9srPo/IrspfzjjfzIcA3iyV/kPp/BHc5TAUTwtkaUVDOfsr
# Eo+f0AkJTZY3+4U39rvVSh3Tymo8yett0lFMG+Mo8XoGxXhjmcDYr4WgdPnmRUf7
# 2NprzPYTAr9+CgiAMMlI2oEFVhevReXiYWI8NeBlnDxHF3Wz8vapN82qO/AyCvsu
# 9A8HWsFdKynYlgmqjcEFeq5LTDkqBG40M+mwUwlmrkfdHQIDAQABo4IDSDCCA0Qw
# OwYJKwYBBAGCNxUHBC4wLAYkKwYBBAGCNxUIhMyCH8+9G4LVjRuzxzWGhuksgUCG
# mfcDrJoTAgFkAgEOMBMGA1UdJQQMMAoGCCsGAQUFBwMDMAsGA1UdDwQEAwIHgDAb
# BgkrBgEEAYI3FQoEDjAMMAoGCCsGAQUFBwMDMFIGCSsGAQQBgjcZAgRFMEOgQQYK
# KwYBBAGCNxkCAaAzBDFTLTEtNS0yMS0xMDc5NTc2NTIzLTM4NTgxMjM1NjUtMTkw
# OTY3OTkxNS05NTg5MDQyME8GA1UdEQRIMEagKQYKKwYBBAGCNxQCA6AbDBlIYXJz
# aGl0aHJhai5QQG1waGFzaXMuY29tgRlIYXJzaGl0aHJhai5QQG1waGFzaXMuY29t
# MB0GA1UdDgQWBBSkZDx6EbPefW2Ud8IXKJ6tZ3dLPzAfBgNVHSMEGDAWgBQjRSRz
# 1j1XGGn4I9WpMcdUqHHtjTCB2wYDVR0fBIHTMIHQMIHNoIHKoIHHhoHEbGRhcDov
# Ly9DTj1NcGhhc2lzUm9vdENBLENOPVNSVkJBTjA5Q1JBVVZNMSxDTj1DRFAsQ049
# UHVibGljJTIwS2V5JTIwU2VydmljZXMsQ049U2VydmljZXMsQ049Q29uZmlndXJh
# dGlvbixEQz1jb3JwLERDPW1waGFzaXMsREM9Y29tP2NlcnRpZmljYXRlUmV2b2Nh
# dGlvbkxpc3Q/YmFzZT9vYmplY3RDbGFzcz1jUkxEaXN0cmlidXRpb25Qb2ludDCC
# AQEGCCsGAQUFBwEBBIH0MIHxMIG0BggrBgEFBQcwAoaBp2xkYXA6Ly8vQ049TXBo
# YXNpc1Jvb3RDQSxDTj1BSUEsQ049UHVibGljJTIwS2V5JTIwU2VydmljZXMsQ049
# U2VydmljZXMsQ049Q29uZmlndXJhdGlvbixEQz1jb3JwLERDPW1waGFzaXMsREM9
# Y29tP2NBQ2VydGlmaWNhdGU/YmFzZT9vYmplY3RDbGFzcz1jZXJ0aWZpY2F0aW9u
# QXV0aG9yaXR5MDgGCCsGAQUFBzABhixodHRwOi8vU1JWQkFOMDlDUkFVVk0xLmNv
# cnAubXBoYXNpcy5jb20vb2NzcDANBgkqhkiG9w0BAQsFAAOCAgEAK86w/bs3xZR1
# wCj+aHRSPYtMjPWaBV1x7FYIRUI4cYUWh8/LSXd+SeecR9ZILHv98WmpHHSCANMm
# AjmLx0GufMz1IS+CuWrMmbtWA81zlYICoCMC8sNGoOHAm16njFwm09Yj0/7lB5OA
# UMbPdy1FoL7FTrOTgnWElBxbZZd4DyEKfC4f+f+6L7cIrFgXiansLLiYy8mTHNUW
# /T4ZipxPYMdcKXkItY94NCsQzccy12xDI8JCd2PFk5p8IVE85yUxP7xT9jc7ZSKg
# AGOuwJ9PDWAFMXQe8DmYyVCrrw0oVn0t7OWcmBsjId8kUjm1kq+lUcMyx+xwhO6q
# 8DbgqFekH6KLJA/fKsSGgxInpqvJzQ9ExTpAuxATrdTZkrlfkIEArqp1DPBMBF7+
# 2pewhdwF3PWqd1zRI1Phmo6lm4ixUST0sVRygV+PT5KuDWVCnrkD39rGn2XcZ5Tk
# /+0eezAMjG4xnXmwja7pu3h0jcDwt7RQoLKKMHc70pFiyKGr5lY5/jWLClFLh3RV
# 7Z/2zKRTRf8NL/uiiS6z9Qv7vuZZ+IqrzB4XxPdCytpKZwoy4vSxBFob6syDLc2r
# FaTctXl3Yg27zp4NYG0+CP+y6fsGw2V6g4zz50wp1SAmWkLL7WK2e3gDzbdUrXq2
# WD+POBA6s8795fJpOk+tkFSY8SENWR0xggIUMIICEAIBATBzMFwxEzARBgoJkiaJ
# k/IsZAEZFgNjb20xFzAVBgoJkiaJk/IsZAEZFgdtcGhhc2lzMRQwEgYKCZImiZPy
# LGQBGRYEY29ycDEWMBQGA1UEAxMNTXBoYXNpc1Jvb3RDQQITfgAqDS38gi3RBcr9
# PwAAACoNLTAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZ
# BgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYB
# BAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUlChEEH39McaZV6YyKLuhMARSW1UwDQYJ
# KoZIhvcNAQEBBQAEggEAXw7MBIVA6PmpSR1ov4m5Ndh6u3TueefqYH5DS71G8Lkx
# Sz1cqxWCEM7P1p7U9+puEpzrWjJpOPLbS/pLhBM/LnlnKIUoOyFAKLsBlx1lGX+M
# uIcspbAu9Mz3hfq+qRpdEVwLE/18IEBMYe4rNFOwJSq/09nEBfCOddsQcHp2Mtzv
# h2QecU2WtqP9TlOba71iTjdFNQlt3wrfen1dXOrRZLtA2eCku6QLSy3tJGj20gTr
# WD+g0aj1/x/XLloTPN9tKU2yTQC4aC5yuVAlcB24idqDN88TO6m6AuZwKY1+BCPx
# Bmtlh2HdkXVEp0++brZEJd+KZc9aui7eQoE0Ody9Fw==
# SIG # End signature block

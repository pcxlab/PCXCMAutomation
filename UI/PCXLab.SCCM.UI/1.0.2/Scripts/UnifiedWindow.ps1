#Requires -Version 5.1

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

# Load Helper Functions from UI project
$UIFunctionsPath = Join-Path (Split-Path $PSScriptRoot -Parent) "Functions"
Get-ChildItem -Path "$UIFunctionsPath\*.ps1" | ForEach-Object { . $_.FullName }

# Load XAML
$XamlPath = Join-Path (Split-Path $PSScriptRoot -Parent) "Xaml\UnifiedWindow.xaml"
[xml]$xaml = Get-Content $XamlPath
$reader = New-Object System.Xml.XmlNodeReader $xaml
$Window = [Windows.Markup.XamlReader]::Load($reader)

# Map UI Controls
$txtSourcePath   = $Window.FindName("txtSourcePath")
$btnBrowse       = $Window.FindName("btnBrowse")
$txtAppName      = $Window.FindName("txtAppName")
$txtPkgName      = $Window.FindName("txtPkgName")
$txtCompany      = $Window.FindName("txtCompany")
$txtProduct      = $Window.FindName("txtProduct")
$txtVersion      = $Window.FindName("txtVersion")
$pnlDPGroups     = $Window.FindName("pnlDPGroups")
$pnlDPs          = $Window.FindName("pnlDPs")
$pnlCMGs         = $Window.FindName("pnlCMGs")
$btnRefreshDPs   = $Window.FindName("btnRefreshDPs")
$radApp          = $Window.FindName("radApp")
$radPkg          = $Window.FindName("radPkg")
$btnCreate       = $Window.FindName("btnCreate")
$txtStatus       = $Window.FindName("txtStatus")
$pnlAppName     = $Window.FindName("pnlAppName")
$pnlPkgName     = $Window.FindName("pnlPkgName")
$txtRefNumber   = $Window.FindName("txtRefNumber")
$txtReviewer    = $Window.FindName("txtReviewer")
$txtComment    = $Window.FindName("txtComment")

# State
$script:LastLoadedSourcePath = ''

# ------------------------------------------------------------
# Logging / Status Helpers
# ------------------------------------------------------------

function Write-GUIStatus {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "HH:mm:ss"
    $FormattedMessage = "[$Timestamp] [$Level] $Message`r`n"
    
    $Window.Dispatcher.Invoke({
        $txtStatus.AppendText($FormattedMessage)
        $txtStatus.ScrollToEnd()
    })
}

# ------------------------------------------------------------
# Data Loading
# ------------------------------------------------------------

function Refresh-DistributionLists {
    param([switch]$ForceRefresh)

    Write-GUIStatus "Refreshing Distribution Point and Group lists..."
    
    $Window.Dispatcher.Invoke({
        $pnlDPGroups.Children.Clear()
        $pnlDPs.Children.Clear()
        $pnlCMGs.Children.Clear()
        
        try {
            #$Groups = Get-PCXCMDPGroups -ForceRefresh:$ForceRefresh
            $Groups = @(Get-PCXCMDPGroups -ForceRefresh:$ForceRefresh)
            foreach ($G in $Groups) { 
                $CheckBox = New-Object System.Windows.Controls.CheckBox
                $CheckBox.Content = $G
                $CheckBox.Margin = "2"
                $CheckBox.Foreground = [System.Windows.Media.Brushes]::Black
                [void]$pnlDPGroups.Children.Add($CheckBox)
            }

            #$DPs = Get-PCXCMDPs -ForceRefresh:$ForceRefresh
            $DPs = @(Get-PCXCMDPs -ForceRefresh:$ForceRefresh)
            foreach ($D in $DPs) { 
                $CheckBox = New-Object System.Windows.Controls.CheckBox
                $CheckBox.Content = $D
                $CheckBox.Margin = "2"
                $CheckBox.Foreground = [System.Windows.Media.Brushes]::Black
                [void]$pnlDPs.Children.Add($CheckBox)
            }

            #$CMGs = Get-PCXCMCMGs -ForceRefresh:$ForceRefresh
            $CMGs = @(Get-PCXCMCMGs -ForceRefresh:$ForceRefresh)
            foreach ($C in $CMGs) { 
                $CheckBox = New-Object System.Windows.Controls.CheckBox
                $CheckBox.Content = $C
                $CheckBox.Margin = "2"
                $CheckBox.Foreground = [System.Windows.Media.Brushes]::Black
                [void]$pnlCMGs.Children.Add($CheckBox)
            }
            
            Write-GUIStatus "Successfully loaded $($Groups.Count) Groups, $($DPs.Count) DPs and $($CMGs.Count) CMGs."
        }
        catch {
            Write-GUIStatus "Failed to load distribution lists: $($_.Exception.Message)" "ERROR"
        }
    })
}

# ------------------------------------------------------------
# Metadata Extraction
# ------------------------------------------------------------

function Update-Metadata {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        $Window.Dispatcher.Invoke({
            $txtAppName.Text = ""
            $txtPkgName.Text = ""
            $txtCompany.Text = ""
            $txtProduct.Text = ""
            $txtVersion.Text = ""
        })
        return
    }

    try {
        Write-GUIStatus "Validating source folder: $Path"
        Test-PCXPackageSource -PackagePath $Path

        # Use the module's metadata extraction logic
        $Metadata = $null
        if (Get-Command Get-PCXMetadataFromPath -ErrorAction SilentlyContinue) {
            $Metadata = Get-PCXMetadataFromPath -Path $Path
            Write-GUIStatus "Metadata extracted using module logic."
        }
        else {
            $Metadata = Get-PCXSourceMetadata -SourcePath $Path
            Write-GUIStatus "Metadata extracted using UI helper (Fallback)." "WARNING"
        }

        # Fix Version Display Issue: Ensure $DisplayVersion is never null and assigned correctly
        $DisplayVersion = "Not Detected"
        if ($null -ne $Metadata.Version -and -not [string]::IsNullOrWhiteSpace($Metadata.Version)) {
            $DisplayVersion = $Metadata.Version.ToString()
        }

        $Window.Dispatcher.Invoke({
            $txtCompany.Text = $Metadata.Company
            $txtProduct.Text = $Metadata.Product
            $txtVersion.Text = $DisplayVersion
            $txtAppName.Text = "APP $($Metadata.Name)"
            $txtPkgName.Text = "PKG $($Metadata.Name)"
        })

        $script:LastLoadedSourcePath = $Path
        Write-GUIStatus "Successfully identified: $($Metadata.Name) (Version: $DisplayVersion)"
    }
    catch {
        $Window.Dispatcher.Invoke({
            $txtAppName.Text = ""
            $txtPkgName.Text = ""
            $txtCompany.Text = ""
            $txtProduct.Text = ""
            $txtVersion.Text = ""
        })
        $script:LastLoadedSourcePath = ''
        Write-GUIStatus "Path Validation Failed: $($_.Exception.Message)" "ERROR"
    }
}

# ------------------------------------------------------------
# Custom Dialogs
# ------------------------------------------------------------

function Show-PCXCMConfirmDialog {
    param(
        [string]$SourcePath,
        [string]$Type,
        [string]$Name,
        [string]$Company,
        [string]$Product,
        [string]$Version,
        [string[]]$Groups,
        [string[]]$DPs,
        [string[]]$CMGs,
        [string]$RefNumber,
        [string]$Reviewer,
        [string]$Comment
    )

    $ConfirmXamlPath = Join-Path (Split-Path $PSScriptRoot -Parent) "Xaml\ConfirmWindow.xaml"
    [xml]$cXaml = Get-Content $ConfirmXamlPath
    $cReader = New-Object System.Xml.XmlNodeReader $cXaml
    $cWindow = [Windows.Markup.XamlReader]::Load($cReader)

    # Map Controls
    $cTxtSource    = $cWindow.FindName("txtConfSource")
    $cTxtType      = $cWindow.FindName("txtConfType")
    $cTxtName      = $cWindow.FindName("txtConfName")
    $cTxtCompany   = $cWindow.FindName("txtConfCompany")
    $cTxtProduct   = $cWindow.FindName("txtConfProduct")
    $cTxtVersion   = $cWindow.FindName("txtConfVersion")
    $cTxtGroups    = $cWindow.FindName("txtConfGroups")
    $cTxtDPs       = $cWindow.FindName("txtConfDPs")
    $cTxtCMGs      = $cWindow.FindName("txtConfCMGs")
    $cTxtRef       = $cWindow.FindName("txtConfRef")
    $cTxtReviewer  = $cWindow.FindName("txtConfReviewer")
    $cTxtComment  = $cWindow.FindName("txtConfComment")
    $cBtnBack      = $cWindow.FindName("btnConfBack")
    $cBtnProceed   = $cWindow.FindName("btnConfProceed")

    # Populate Data
    $cTxtSource.Text   = $SourcePath
    $cTxtType.Text     = $Type
    $cTxtName.Text     = $Name
    $cTxtCompany.Text  = $Company
    $cTxtProduct.Text  = $Product
    $cTxtVersion.Text  = $Version
    $cTxtGroups.Text   = $(if ($Groups.Count -gt 0) { $Groups -join ", " } else { "None" })
    $cTxtDPs.Text      = $(if ($DPs.Count -gt 0) { $DPs -join ", " } else { "None" })
    $cTxtCMGs.Text     = $(if ($CMGs.Count -gt 0) { $CMGs -join ", " } else { "None" })
    $cTxtRef.Text      = $RefNumber
    $cTxtReviewer.Text = $Reviewer
    $cTxtComment.Text = $Comment

    # Context Aware Button
    if ($Type -eq "Application") {
        $cBtnProceed.Content = "CREATE APPLICATION"
        $cBtnProceed.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#107C10")
    }
    else {
        $cBtnProceed.Content = "CREATE PACKAGE"
        $cBtnProceed.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#0078D4")
    }

    $script:ConfirmResult = $false

    $cBtnBack.Add_Click({
        $cWindow.Close()
    })

    $cBtnProceed.Add_Click({
        $script:ConfirmResult = $true
        $cWindow.Close()
    })

    $cWindow.ShowDialog() | Out-Null
    return $script:ConfirmResult
}

# ------------------------------------------------------------
# Event Handlers
# ------------------------------------------------------------

# Radio Button Handlers
$radApp.Add_Checked({
    $btnCreate.Content = "CREATE APPLICATION"
    $btnCreate.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#107C10")
    $pnlAppName.Visibility = "Visible"
    $pnlPkgName.Visibility = "Collapsed"
})

$radPkg.Add_Checked({
    $btnCreate.Content = "CREATE PACKAGE"
    $btnCreate.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#0078D4")
    $pnlAppName.Visibility = "Collapsed"
    $pnlPkgName.Visibility = "Visible"
})

# Modern Browse Logic (Pick File -> Use Parent Folder)
$btnBrowse.Add_Click({
    try {
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
        $FileBrowser.Title = "Select any file inside the source folder"
        $FileBrowser.Filter = "All Files (*.*)|*.*"
        
        # Set initial directory if current path exists
        $CurrentPath = $txtSourcePath.Text.Trim()
        if (-not [string]::IsNullOrWhiteSpace($CurrentPath)) {
            if (Test-Path $CurrentPath) { 
                $FileBrowser.InitialDirectory = $(if (Test-Path $CurrentPath -PathType Container) { $CurrentPath } else { Split-Path $CurrentPath -Parent })
            }
        }

        if ($FileBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            # Use parent directory of the selected file
            $FolderPath = Split-Path $FileBrowser.FileName -Parent
            $txtSourcePath.Text = $FolderPath
            Update-Metadata -Path $FolderPath
        }
    }
    catch {
        Write-GUIStatus "Browse failed: $($_.Exception.Message)" "ERROR"
        [System.Windows.MessageBox]::Show("Browse failed: $($_.Exception.Message)", "Error")
    }
})

$txtSourcePath.Add_LostFocus({
    $CurrentPath = $txtSourcePath.Text.Trim()
    if ($CurrentPath -ne $script:LastLoadedSourcePath) { Update-Metadata -Path $CurrentPath }
})

$btnRefreshDPs.Add_Click({ Refresh-DistributionLists -ForceRefresh })

# Helper to get selected items from CheckBoxes in a Panel
function Get-SelectedItemsFromPanel {
    param($Panel)
    $Selected = New-Object System.Collections.Generic.List[string]
    $Window.Dispatcher.Invoke({
        foreach ($Child in $Panel.Children) {
            if ($Child -is [System.Windows.Controls.CheckBox] -and $Child.IsChecked) {
                $Selected.Add($Child.Content.ToString())
            }
        }
    })
    return $Selected.ToArray()
}

# Unified Creation Action
$btnCreate.Add_Click({
    $Path = $txtSourcePath.Text.Trim()
    if (-not $Path) {
        [System.Windows.MessageBox]::Show("Please select a source path.", "Error")
        return
    }

    $SelectedGroups = Get-SelectedItemsFromPanel -Panel $pnlDPGroups
    $SelectedDPs = Get-SelectedItemsFromPanel -Panel $pnlDPs
    $SelectedCMGs = Get-SelectedItemsFromPanel -Panel $pnlCMGs

    # Merge DPs and CMGs into a single DistributionPoints array
    $DistributionPoints = @(
        $SelectedCMGs
        $SelectedDPs
    ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

    # Require at least one target
    if ($SelectedGroups.Count -eq 0 -and $DistributionPoints.Count -eq 0) {
        [System.Windows.MessageBox]::Show(
            "Please select at least one Target (DP Group, DP or CMG).",
            "Error"
        )
        return
    }

    $IsApp = $radApp.IsChecked
    $ObjectName = if ($IsApp) {
        $txtAppName.Text
    }
    else {
        $txtPkgName.Text
    }

    # Custom Confirmation Dialog
    $Confirmed = Show-PCXCMConfirmDialog `
        -SourcePath $Path `
        -Type $(if ($IsApp) { "Application" } else { "Package" }) `
        -Name $ObjectName `
        -Company $txtCompany.Text `
        -Product $txtProduct.Text `
        -Version $txtVersion.Text `
        -Groups $SelectedGroups `
        -DPs $SelectedDPs `
        -CMGs $SelectedCMGs `
        -RefNumber $txtRefNumber.Text `
        -Reviewer $txtReviewer.Text `
        -Comment $txtComment.Text

    if (-not $Confirmed) {
        return
    }

    try {
        $btnCreate.IsEnabled = $false
        $Window.Cursor = [System.Windows.Input.Cursors]::Wait

        $Type = if ($IsApp) {
            "APPLICATION"
        }
        else {
            "PACKAGE"
        }

        Write-GUIStatus ">>> STARTING $Type CREATION: $ObjectName" "ACTION"

        $Params = @{
            Path = $Path
            ReferenceNumber = $txtRefNumber.Text
            ReviewerName = $txtReviewer.Text
            Comment = $txtComment.Text
        }

        if ($SelectedGroups.Count -gt 0) {
            $Params["DistributionPointGroups"] = $SelectedGroups
        }

        if ($DistributionPoints.Count -gt 0) {
            $Params["DistributionPoints"] = $DistributionPoints
        }

        if ($IsApp) {
            Create-PCXCMApplication @Params
        }
        else {
            Create-PCXCMPackage @Params
        }

        Write-GUIStatus "SUCCESS: $Type created and distributed." "SUCCESS"
        [System.Windows.MessageBox]::Show("$Type created successfully.", "Success")
    }
    catch {
        Write-GUIStatus "FAILED: $($_.Exception.Message)" "ERROR"
        [System.Windows.MessageBox]::Show(
            "Creation failed: $($_.Exception.Message)",
            "Error"
        )
    }
    finally {
        $btnCreate.IsEnabled = $true
        $Window.Cursor = [System.Windows.Input.Cursors]::Arrow
    }
})

# ------------------------------------------------------------
# Initialization
# ------------------------------------------------------------

Refresh-DistributionLists
Write-GUIStatus "System Ready. Please select a package source folder to begin."

# Show Window
$Window.ShowDialog() | Out-Null
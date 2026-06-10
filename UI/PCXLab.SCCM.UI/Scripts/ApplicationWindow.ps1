Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

. (Join-Path (Split-Path $PSScriptRoot -Parent) "Functions\Get-PCXSourceMetadata.ps1")
. (Join-Path (Split-Path $PSScriptRoot -Parent) "Functions\Get-PCXCMDPGroups.ps1")
. (Join-Path (Split-Path $PSScriptRoot -Parent) "Functions\Test-PCXPackageSource.ps1")

# Load XAML
$XamlPath = Join-Path (Split-Path $PSScriptRoot -Parent) "Xaml\ApplicationWindow.xaml"

[xml]$xaml = Get-Content $XamlPath

$reader = New-Object System.Xml.XmlNodeReader $xaml

$Window = [Windows.Markup.XamlReader]::Load($reader)

# Controls
$txtSourcePath = $Window.FindName("txtSourcePath")
$txtApplicationName = $Window.FindName("txtApplicationName")
$txtCompany = $Window.FindName("txtCompany")
$txtProduct = $Window.FindName("txtProduct")
$txtVersion = $Window.FindName("txtVersion")

$cmbDPGroup = $Window.FindName("cmbDPGroup")

$txtStatus = $Window.FindName("txtStatus")

$btnBrowse = $Window.FindName("btnBrowse")
$btnCreateApplication = $Window.FindName("btnCreateApplication")

# Cache
$script:LastLoadedSourcePath = ''

# ------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------

function Clear-ApplicationMetadata {

    $txtApplicationName.Text = ''
    $txtCompany.Text = ''
    $txtProduct.Text = ''
    $txtVersion.Text = ''

}

function Write-GUIStatus {

    param(
        [string]$Message
    )

    $txtStatus.AppendText("$Message`r`n")
    $txtStatus.ScrollToEnd()

}

Write-GUIStatus "Ready"

# Helper function to load metadata into UI
function Update-ApplicationMetadata {
    param([string]$Path)

    try {
        Test-PCXPackageSource -PackagePath $Path
        $Metadata = Get-PCXSourceMetadata -SourcePath $Path

        $txtCompany.Text = $Metadata.Company
        $txtProduct.Text = $Metadata.Product
        $txtVersion.Text = $Metadata.Version
        $txtApplicationName.Text = "APP $($Metadata.Name)"

        $script:LastLoadedSourcePath = $Path
        Write-GUIStatus "Application information loaded."
        return $true
    }
    catch {
        Clear-ApplicationMetadata
        $script:LastLoadedSourcePath = ''
        Write-GUIStatus "Error: $($_.Exception.Message)"
        return $false
    }
}

# ------------------------------------------------------------
# Source Path Events
# ------------------------------------------------------------

$txtSourcePath.Add_TextChanged({
    if ([string]::IsNullOrWhiteSpace($txtSourcePath.Text)) {
        Clear-ApplicationMetadata
        $script:LastLoadedSourcePath = ''
        $txtStatus.Clear()
        Write-GUIStatus "Ready"
    }
})

$txtSourcePath.Add_LostFocus({
    $CurrentPath = $txtSourcePath.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($CurrentPath) -or $CurrentPath -eq $script:LastLoadedSourcePath) { return }
    
    Update-ApplicationMetadata -Path $CurrentPath
})

# ------------------------------------------------------------
# Distribution Point Groups
# ------------------------------------------------------------

$DPGroups = Get-PCXCMDPGroups
foreach ($DPGroup in $DPGroups) { [void]$cmbDPGroup.Items.Add($DPGroup) }
if ($cmbDPGroup.Items.Count -gt 0) { $cmbDPGroup.SelectedIndex = 0 }

# ------------------------------------------------------------
# Browse
# ------------------------------------------------------------

$btnBrowse.Add_Click({
    $Dialog = New-Object System.Windows.Forms.OpenFileDialog
    $Dialog.Title = "Select any file inside Application Folder"
    $Dialog.Filter = "All Files (*.*)|*.*"

    if ($Dialog.ShowDialog() -eq "OK") {
        $Folder = Split-Path $Dialog.FileName -Parent
        $txtSourcePath.Text = $Folder
        Update-ApplicationMetadata -Path $Folder
    }
})

# ------------------------------------------------------------
# Create Application
# ------------------------------------------------------------

$btnCreateApplication.Add_Click({

        try {

            if ([string]::IsNullOrWhiteSpace($txtSourcePath.Text)) {
                [System.Windows.MessageBox]::Show(
                    "Please select a Application source path.",
                    "Validation Error"
                )
                return
            }

            $btnCreateApplication.IsEnabled = $false
            $Window.Cursor = [System.Windows.Input.Cursors]::Wait
            # Enable below line only if cursor doesnt switch
            #[System.Windows.Forms.Application]::DoEvents()

            Write-GUIStatus "Creating Application..."
            Write-GUIStatus "Please do not close the window."

            Create-PCXCMApplication -Path $txtSourcePath.Text -DPGroup $cmbDPGroup.SelectedItem

            Write-GUIStatus "Application created successfully."

            [System.Windows.MessageBox]::Show(
                "Application created successfully.",
                "PCXLab SCCM"
            )

        }
        catch {

            Write-GUIStatus $_.Exception.Message

            [System.Windows.MessageBox]::Show(
                $_.Exception.Message,
                "Application Creation Failed"
            )

        }
        finally {
            $Window.Cursor = [System.Windows.Input.Cursors]::Arrow
            $btnCreateApplication.IsEnabled = $true
        }

    })

# ------------------------------------------------------------
# Show Window
# ------------------------------------------------------------

$Window.ShowDialog() | Out-Null
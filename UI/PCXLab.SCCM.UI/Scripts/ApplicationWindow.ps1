Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

. (Join-Path (Split-Path $PSScriptRoot -Parent) "Functions\Get-PCXApplicationMetadata.ps1")
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

    if ([string]::IsNullOrWhiteSpace($CurrentPath)) {
        return
    }

    if ($CurrentPath -eq $script:LastLoadedSourcePath) {
        return
    }

    try {
        Test-PCXPackageSource -PackagePath $CurrentPath

        $Metadata = Get-PCXApplicationMetadata -ApplicationPath $CurrentPath

        $txtCompany.Text = $Metadata.Company
        $txtProduct.Text = $Metadata.Product
        $txtVersion.Text = $Metadata.Version
        $txtApplicationName.Text = $Metadata.ApplicationName

        $script:LastLoadedSourcePath = $CurrentPath

        Write-GUIStatus "Application information loaded."
    }
    catch {
        Clear-ApplicationMetadata
        $script:LastLoadedSourcePath = ''
        Write-GUIStatus "Invalid Application source."
    }

})

# ------------------------------------------------------------
# Distribution Point Groups
# ------------------------------------------------------------

$DPGroups = Get-PCXCMDPGroups

foreach ($DPGroup in $DPGroups) {
    [void]$cmbDPGroup.Items.Add($DPGroup)
}

if ($cmbDPGroup.Items.Count -gt 0) {
    $cmbDPGroup.SelectedIndex = 0
}

# ------------------------------------------------------------
# Browse
# ------------------------------------------------------------

$btnBrowse.Add_Click({

    $Dialog = New-Object System.Windows.Forms.OpenFileDialog
    $Dialog.Title = "Select any file inside Application Folder"
    $Dialog.Filter = "All Files (*.*)|*.*"

    if ($Dialog.ShowDialog() -eq "OK") {

        $Folder = Split-Path $Dialog.FileName -Parent

        Write-Host "Selected Folder: $Folder" -ForegroundColor Yellow
        Write-Host "Test-Path Result: $(Test-Path $Folder)" -ForegroundColor Yellow

        try {
            Test-PCXPackageSource -PackagePath $Folder
        }
        catch {
            Clear-ApplicationMetadata
            $script:LastLoadedSourcePath = ''

            [System.Windows.MessageBox]::Show(
                $_.Exception.Message,
                "Validation Error"
            )
            return
        }

        $txtSourcePath.Text = $Folder

        try {
            $Metadata = Get-PCXApplicationMetadata -ApplicationPath $Folder

            $txtCompany.Text = $Metadata.Company
            $txtProduct.Text = $Metadata.Product
            $txtVersion.Text = $Metadata.Version
            $txtApplicationName.Text = $Metadata.ApplicationName

            $script:LastLoadedSourcePath = $Folder

            Write-GUIStatus "Application information loaded."
        }
        catch {
            Clear-ApplicationMetadata
            $script:LastLoadedSourcePath = ''

            [System.Windows.MessageBox]::Show(
                $_.Exception.Message,
                "Metadata Error"
            )
            return
        }
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
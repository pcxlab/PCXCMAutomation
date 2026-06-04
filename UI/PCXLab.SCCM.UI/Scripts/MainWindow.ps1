Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

. (Join-Path (Split-Path $PSScriptRoot -Parent) "Functions\Get-PCXSourceMetadata.ps1")
. (Join-Path (Split-Path $PSScriptRoot -Parent) "Functions\Get-PCXCMDPGroups.ps1")
. (Join-Path (Split-Path $PSScriptRoot -Parent) "Functions\Test-PCXPackageSource.ps1")

# Load XAML
$XamlPath = Join-Path (Split-Path $PSScriptRoot -Parent) "Xaml\MainWindow.xaml"

[xml]$xaml = Get-Content $XamlPath

$reader = New-Object System.Xml.XmlNodeReader $xaml

$Window = [Windows.Markup.XamlReader]::Load($reader)

# Controls
$txtSourcePath = $Window.FindName("txtSourcePath")
$txtPackageName = $Window.FindName("txtPackageName")
$txtCompany = $Window.FindName("txtCompany")
$txtProduct = $Window.FindName("txtProduct")
$txtVersion = $Window.FindName("txtVersion")

$cmbDPGroup = $Window.FindName("cmbDPGroup")

$txtStatus = $Window.FindName("txtStatus")

$btnBrowse = $Window.FindName("btnBrowse")
$btnCreatePackage = $Window.FindName("btnCreatePackage")

# Cache
$script:LastLoadedSourcePath = ''

# ------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------

function Clear-PackageMetadata {

    $txtPackageName.Text = ''
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
            Clear-PackageMetadata
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

            $Metadata = Get-PCXSourceMetadata -SourcePath $CurrentPath

            $txtCompany.Text = $Metadata.Company
            $txtProduct.Text = $Metadata.Product
            $txtVersion.Text = $Metadata.Version
            $txtPackageName.Text = "PKG $($Metadata.Name)"

            $script:LastLoadedSourcePath = $CurrentPath

            Write-GUIStatus "Package information loaded."
        }
        catch {
            Clear-PackageMetadata
            $script:LastLoadedSourcePath = ''
            Write-GUIStatus "Invalid package source."
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
        $Dialog.Title = "Select any file inside Package Folder"
        $Dialog.Filter = "All Files (*.*)|*.*"

        if ($Dialog.ShowDialog() -eq "OK") {

            $Folder = Split-Path $Dialog.FileName -Parent

            Write-Host "Selected Folder: $Folder" -ForegroundColor Yellow
            Write-Host "Test-Path Result: $(Test-Path $Folder)" -ForegroundColor Yellow

            try {
                Test-PCXPackageSource -PackagePath $Folder
            }
            catch {
                Clear-PackageMetadata
                $script:LastLoadedSourcePath = ''

                [System.Windows.MessageBox]::Show(
                    $_.Exception.Message,
                    "Validation Error"
                )
                return
            }

            $txtSourcePath.Text = $Folder

            try {
                $Metadata = Get-PCXSourceMetadata -SourcePath $Folder

                $txtCompany.Text = $Metadata.Company
                $txtProduct.Text = $Metadata.Product
                $txtVersion.Text = $Metadata.Version
                $txtPackageName.Text = "PKG $($Metadata.Name)"

                $script:LastLoadedSourcePath = $Folder

                Write-GUIStatus "Package information loaded."
            }
            catch {
                Clear-PackageMetadata
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
# Create Package
# ------------------------------------------------------------

$btnCreatePackage.Add_Click({

        try {

            if ([string]::IsNullOrWhiteSpace($txtSourcePath.Text)) {
                [System.Windows.MessageBox]::Show(
                    "Please select a package source path.",
                    "Validation Error"
                )
                return
            }

            $btnCreatePackage.IsEnabled = $false
            $Window.Cursor = [System.Windows.Input.Cursors]::Wait
            # Enable below line only if cursor doesnt switch
            #[System.Windows.Forms.Application]::DoEvents()

            Write-GUIStatus "Creating package..."
            Write-GUIStatus "Please do not close the window."

            Create-PCXCMPackage -Path $txtSourcePath.Text -DPGroup $cmbDPGroup.SelectedItem

            Write-GUIStatus "Package created successfully."

            [System.Windows.MessageBox]::Show(
                "Package created successfully.",
                "PCXLab SCCM"
            )

        }
        catch {

            Write-GUIStatus $_.Exception.Message

            [System.Windows.MessageBox]::Show(
                $_.Exception.Message,
                "Package Creation Failed"
            )

        }
        finally {
            $Window.Cursor = [System.Windows.Input.Cursors]::Arrow
            $btnCreatePackage.IsEnabled = $true
        }

    })

# ------------------------------------------------------------
# Show Window
# ------------------------------------------------------------

$Window.ShowDialog() | Out-Null
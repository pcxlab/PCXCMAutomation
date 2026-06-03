Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

. (Join-Path (Split-Path $PSScriptRoot -Parent) "Functions\Get-PCXPackageMetadata.ps1")
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

# Distribution Point Groups
$DPGroups = Get-PCXCMDPGroups

foreach ($DPGroup in $DPGroups) {
    [void]$cmbDPGroup.Items.Add($DPGroup)
}

if ($cmbDPGroup.Items.Count -gt 0) {
    $cmbDPGroup.SelectedIndex = 0
}

# Browse
$btnBrowse.Add_Click({

        $Dialog = New-Object System.Windows.Forms.OpenFileDialog
        $Dialog.Title = "Select any file inside Package Folder"
        $Dialog.Filter = "All Files (*.*)|*.*"

        if ($Dialog.ShowDialog() -eq "OK") {
            # Folder Path
            $Folder = Split-Path $Dialog.FileName -Parent

            Write-Host "Selected Folder: $Folder" -ForegroundColor Yellow
            Write-Host "Test-Path Result: $(Test-Path $Folder)" -ForegroundColor Yellow

            try {
                Test-PCXPackageSource -PackagePath $Folder
            }
            catch {
                [System.Windows.MessageBox]::Show(
                    $_.Exception.Message,
                    "Validation Error"
                )
                return
            }

            $txtSourcePath.Text = $Folder

            try {
                $Metadata = Get-PCXPackageMetadata -PackagePath $Folder
                $txtCompany.Text = $Metadata.Company
                $txtProduct.Text = $Metadata.Product
                $txtVersion.Text = $Metadata.Version
                $txtPackageName.Text = $Metadata.PackageName
                $txtStatus.Text = "Package information loaded."
            }
            catch {
                [System.Windows.MessageBox]::Show(
                    $_.Exception.Message, "Metadata Error"
                )
                return
            }
        }
    })

# Create Package
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

            $txtStatus.Text = "Creating package..."

            Create-PCXCMPackage -Path $txtSourcePath.Text -DPGroup $cmbDPGroup.SelectedItem

            $txtStatus.Text = "Package created successfully."

            [System.Windows.MessageBox]::Show(
                "Package created successfully.",
                "PCXLab SCCM"
            )
        }
        catch {
            $txtStatus.Text = $_.Exception.Message

            [System.Windows.MessageBox]::Show(
                $_.Exception.Message,
                "Package Creation Failed"
            )
        }
        finally {
            $btnCreatePackage.IsEnabled = $true
        }
    })
    
# Show Window
$Window.ShowDialog() | Out-Null
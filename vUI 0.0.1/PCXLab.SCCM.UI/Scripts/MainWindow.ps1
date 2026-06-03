Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

# ============================================================
# Load XAML
# ============================================================

$XamlPath = Join-Path `
    (Split-Path $PSScriptRoot -Parent) `
    "Xaml\MainWindow.xaml"

[xml]$xaml = Get-Content $XamlPath

$reader = New-Object System.Xml.XmlNodeReader $xaml

$Window = [Windows.Markup.XamlReader]::Load($reader)

# ============================================================
# Controls
# ============================================================

$txtSourcePath    = $Window.FindName("txtSourcePath")
$txtPackageName   = $Window.FindName("txtPackageName")
$txtCompany       = $Window.FindName("txtCompany")
$txtProduct       = $Window.FindName("txtProduct")
$txtVersion       = $Window.FindName("txtVersion")

$cmbDPGroup       = $Window.FindName("cmbDPGroup")

$txtStatus        = $Window.FindName("txtStatus")

$btnBrowse        = $Window.FindName("btnBrowse")
$btnCreatePackage = $Window.FindName("btnCreatePackage")

# ============================================================
# Distribution Point Groups
# ============================================================

[void]$cmbDPGroup.Items.Add("All Mangalore DPs")
[void]$cmbDPGroup.Items.Add("Pilot DPs")
[void]$cmbDPGroup.Items.Add("Test DPs")

$cmbDPGroup.SelectedIndex = 0

# ============================================================
# Browse
# ============================================================

$btnBrowse.Add_Click({

    $Dialog = New-Object System.Windows.Forms.OpenFileDialog

    $Dialog.Title =
        "Select any file inside Package Folder"

    $Dialog.Filter =
        "All Files (*.*)|*.*"

    if ($Dialog.ShowDialog() -eq "OK")
    {
        #
        # Folder Path
        #

        $Folder =
            Split-Path `
                $Dialog.FileName `
                -Parent

        $txtSourcePath.Text = $Folder

        #
        # TEMPORARY METADATA
        #
        # Replace later with:
        # Get-PCXPackageMetadata
        #

        $txtCompany.Text =
            "Igor Pavlov"

        $txtProduct.Text =
            "7zip"

        $txtVersion.Text =
            "26.0.2"

        $txtPackageName.Text =
            "PKG Igor Pavlov 7zip 26.0.2"

        $txtStatus.Text =
            "Package information loaded."
    }
})

# ============================================================
# Create Package
# ============================================================

$btnCreatePackage.Add_Click({

    [System.Windows.MessageBox]::Show(
        "Create-PCXCMPackage integration will be added next.",
        "PCXLab SCCM"
    )

    $txtStatus.Text =
        "Ready for package creation integration."
})

# ============================================================
# Show Window
# ============================================================

$Window.ShowDialog() | Out-Null
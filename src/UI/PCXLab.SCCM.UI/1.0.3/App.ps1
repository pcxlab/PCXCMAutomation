$AppPath = $PSScriptRoot

# Load standard presentation assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

# 1. Central Utilities
. (Join-Path $AppPath "Logging\Logger.ps1")
. (Join-Path $AppPath "Configuration\Settings.ps1")

# 2. Infrastructure
. (Join-Path $AppPath "Infrastructure\ModuleLoader.ps1")

# 3. Models
. (Join-Path $AppPath "Models\DeploymentModels.ps1")

# 4. Validation
. (Join-Path $AppPath "Validation\Validator.ps1")

# 5. Services
. (Join-Path $AppPath "Services\MetadataService.ps1")
. (Join-Path $AppPath "Services\CommentService.ps1")
. (Join-Path $AppPath "Services\SCCMService.ps1")

# 6. Views
. (Join-Path $AppPath "Views\ConfirmWindow.ps1")
. (Join-Path $AppPath "Views\MainWindow.ps1")

# 7. Controllers
. (Join-Path $AppPath "Controllers\MainController.ps1")

try {
    # Initialize backend module & UI requirements
    [ModuleLoader]::InitializeUI($AppPath)

    # Initialize MainWindow View
    $xamlPath = Join-Path $AppPath "Xaml\UnifiedWindow.xaml"
    $mainWindowView = [MainWindowView]::new($xamlPath)

    # Register logger with main window textbox dispatcher
    [Logger]::Initialize($mainWindowView.Window)

    # Initialize Services
    $metadataService = [MetadataService]::new()
    $sccmService = [SCCMService]::new()
    $commentService = [CommentService]::new()

    # Initialize Controller
    $controller = [MainController]::new($mainWindowView, $metadataService, $sccmService, $commentService, $AppPath)
    $controller.Initialize()

    # Launch UI
    $mainWindowView.Show()
}
catch {
    [System.Windows.MessageBox]::Show($_.Exception.Message, "Startup Error")
    Write-Error $_.Exception.Message
}

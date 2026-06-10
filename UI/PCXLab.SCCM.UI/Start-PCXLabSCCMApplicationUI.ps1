#Requires -Version 5.1

Add-Type -AssemblyName PresentationFramework

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

. (Join-Path $ScriptRoot "Functions\Import-PCXLabSCCMModule.ps1")
. (Join-Path $ScriptRoot "Functions\Initialize-PCXLabSCCMUI.ps1")
. (Join-Path $ScriptRoot "Functions\Get-PCXSourceMetadata.ps1")


try {
    # Initialize UI and Load Module
    [void](Initialize-PCXLabSCCMUI)
}
catch {
    [System.Windows.MessageBox]::Show($_.Exception.Message, "Startup Error")
    return
}

# Launch Application Window
& (Join-Path $ScriptRoot "Scripts\ApplicationWindow.ps1")
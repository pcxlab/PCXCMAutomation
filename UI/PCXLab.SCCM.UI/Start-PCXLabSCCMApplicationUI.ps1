#Requires -Version 5.1

Add-Type -AssemblyName PresentationFramework

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

. (Join-Path $ScriptRoot "Functions\Import-PCXLabSCCMModule.ps1")
. (Join-Path $ScriptRoot "Functions\Initialize-PCXLabSCCMUI.ps1")
. (Join-Path $ScriptRoot "Functions\Get-PCXSourceMetadata.ps1")


try {
    #Initialize-PCXLabSCCMUI
    [void](Initialize-PCXLabSCCMUI)
    # $null = Initialize-PCXLabSCCMUI # TEST this if you are using this please 
}
catch {
    [System.Windows.MessageBox]::Show(
        $_.Exception.Message,
        "Startup Error"
    )
    return
}

& (Join-Path $ScriptRoot "Scripts\ApplicationWindow.ps1")
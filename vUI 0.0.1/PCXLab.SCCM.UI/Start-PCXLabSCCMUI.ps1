#Requires -Version 5.1

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

$MainWindowScript = Join-Path $ScriptRoot "Scripts\MainWindow.ps1"

& $MainWindowScript
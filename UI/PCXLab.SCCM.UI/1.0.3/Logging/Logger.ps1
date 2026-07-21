class Logger {
    static [string] $LogTextBoxName = "txtStatus"
    static [object] $Dispatcher
    static [object] $LogTextBox

    static [void] Initialize([object]$window) {
        [Logger]::Dispatcher = $window.Dispatcher
        [Logger]::LogTextBox = $window.FindName([Logger]::LogTextBoxName)
    }

    static [void] Log([string]$message) {
        [Logger]::Log($message, "INFO")
    }

    static [void] Log([string]$message, [string]$level) {
        $timestamp = Get-Date -Format "HH:mm:ss"
        $formattedMessage = "[$timestamp] [$level] $message`r`n"
        
        $color = switch ($level) {
            "ERROR"   { "Red" }
            "WARNING" { "Yellow" }
            "ACTION"  { "Cyan" }
            "SUCCESS" { "Green" }
            default   { "Gray" }
        }
        Write-Host "[$level] $message" -ForegroundColor $color

        if ([Logger]::Dispatcher -and [Logger]::LogTextBox) {
            [Logger]::Dispatcher.Invoke({
                [Logger]::LogTextBox.AppendText($formattedMessage)
                [Logger]::LogTextBox.ScrollToEnd()
            })
        }
    }
}

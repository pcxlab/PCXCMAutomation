class Settings {
    static [object] GetSetting([string]$name) {
        if (Get-Command Get-PCXCMSetting -ErrorAction SilentlyContinue) {
            return Get-PCXCMSetting -Name $name
        }
        return $null
    }
    
    static [bool] EnableFallbackData() {
        $val = [Settings]::GetSetting("EnableFallbackData")
        return $null -ne $val -and $val -eq $true
    }
}

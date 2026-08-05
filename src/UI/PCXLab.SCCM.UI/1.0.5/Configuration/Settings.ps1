class Settings {
    static [object] GetSetting([string]$name) {
        if (Get-Command Get-PCXCMSetting -ErrorAction SilentlyContinue) {
            return Get-PCXCMSetting -Name $name
        }
        return $null
    }
    
    static [string] GetFallbackMode([string]$TargetType) {
        $settings = [Settings]::GetSetting("FallbackSettings")
    
        if ($null -eq $settings) {
            return "Disabled"
        }
    
        return $settings.$TargetType.FallbackMode
    }
    
    static [string[]] GetFallbackTargets([string]$TargetType) {
        $settings = [Settings]::GetSetting("FallbackSettings")
    
        if ($null -eq $settings) {
            return @()
        }
    
        return @($settings.$TargetType.Targets)
    }
}

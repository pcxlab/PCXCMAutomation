function Initialize-PCXCMEnvironment {

    [CmdletBinding()]
    param()

    begin {
        Write-PCXOperationStart
    }
    process {
        try {

            # Validate SCCM Console
            if ([string]::IsNullOrWhiteSpace($env:SMS_ADMIN_UI_PATH)) {
                throw 'SMS_ADMIN_UI_PATH not found. SCCM Console may not be installed.'
            }

            # Locate ConfigurationManager module
            $CMModulePath = Join-Path `
                (Split-Path $env:SMS_ADMIN_UI_PATH -Parent) `
                'ConfigurationManager.psd1'

            if (-not (Test-Path $CMModulePath)) {
                throw "ConfigurationManager module not found: $CMModulePath"
            }

            Write-PCXLog -Message 'Locating ConfigurationManager module.'

            # Check if module is already loaded
            if (-not (Get-Module -Name ConfigurationManager)) {
                Write-PCXLog -Message 'Importing ConfigurationManager module.'
                Import-Module $CMModulePath -Global -ErrorAction Stop
            }
            else {
                Write-PCXLog -Message 'ConfigurationManager module already loaded.'
            }

            $CMModule = Get-Module ConfigurationManager -ErrorAction SilentlyContinue

            if (-not $CMModule) {
                throw 'ConfigurationManager module failed to load.'
            }

            $RequiredCommands = @(
                'Get-CMApplication',
                'New-CMApplication',
                'New-CMCollection',
                'New-CMDeviceCollection'
            )

            foreach ($Command in $RequiredCommands) {

                if (-not (Get-Command $Command -ErrorAction SilentlyContinue)) {
                    throw "Required SCCM command unavailable: $Command"
                }
            }

            Write-PCXLog -Message 'SCCM cmdlets verified.'
        }
        catch {
            Write-PCXLog -Message $_.Exception.Message -Level ERROR
            throw
        }
    }
    end {
        Write-PCXOperationEnd
    }
}

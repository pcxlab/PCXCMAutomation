function Get-PCXSizingValue {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [ValidateRange(0, [double]::MaxValue)]
        [double]$Value,

        [Parameter(Mandatory)]
        [string]$SettingName,

        [Parameter(Mandatory)]
        [string]$CompareProperty,

        [Parameter(Mandatory)]
        [string]$ReturnProperty,

        [Parameter(Mandatory)]
        [string]$MaximumProperty

    )

    begin {
        Write-PCXOperationStart
    }

    process {

        try {

            $Settings = Get-PCXCMSetting -Name $SettingName

            if (-not $Settings) {
                throw "Configuration '$SettingName' was not found."
            }

            if (-not $Settings.Thresholds) {
                throw "Configuration '$SettingName' does not contain any thresholds."
            }

            if ($null -eq $Settings.$MaximumProperty) {
                throw "Configuration '$SettingName' does not contain '$MaximumProperty'."
            }

            #
            # Always process thresholds in ascending order.
            #
            $Thresholds = $Settings.Thresholds | Sort-Object -Property $CompareProperty

            foreach ($Threshold in $Thresholds) {

                if ($null -eq $Threshold.$CompareProperty) {
                    throw "Threshold is missing property '$CompareProperty'."
                }

                if ($null -eq $Threshold.$ReturnProperty) {
                    throw "Threshold is missing property '$ReturnProperty'."
                }

                if ($Value -le $Threshold.$CompareProperty) {
                    return $Threshold.$ReturnProperty
                }

            }

            return $Settings.$MaximumProperty

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
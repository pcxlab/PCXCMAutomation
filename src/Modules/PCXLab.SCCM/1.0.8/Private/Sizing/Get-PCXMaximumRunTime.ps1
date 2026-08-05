function Get-PCXMaximumRunTime {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [ValidateRange(0, [double]::MaxValue)]
        [double]$SizeMB

    )

    begin {
        Write-PCXOperationStart
    }

    process {

        try {

            return Get-PCXSizingValue `
                -Value $SizeMB `
                -SettingName "DefaultSizing.MaximumRunTime" `
                -CompareProperty "SizeMB" `
                -ReturnProperty "Minutes" `
                -MaximumProperty "MaximumMinutes"

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
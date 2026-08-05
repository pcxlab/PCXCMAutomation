function Get-PCXEstimatedDiskSpace {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateRange(0, [double]::MaxValue)]
        [double]$SizeGB
    )

    begin {
        Write-PCXOperationStart
    }
    process {
        try {
            return Get-PCXSizingValue `
                -Value $SizeGB `
                -SettingName "DefaultSizing.DiskSpace" `
                -CompareProperty "SizeGB" `
                -ReturnProperty "DiskSpaceGB" `
                -MaximumProperty "MaximumGB"
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
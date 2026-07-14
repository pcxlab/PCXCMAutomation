function Set-PCXCMCollectionRefreshType {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$CollectionName,

        [ValidateSet("Manual","Periodic","Continuous","Both")]
        [string]$RefreshType = "Manual"
    )

    begin {
        Write-PCXOperationStart
    }

    process {
        try {

            Write-PCXLog "Setting collection refresh type to '$RefreshType' for '$CollectionName'."

            Set-CMCollection `
                -Name $CollectionName `
                -RefreshType $RefreshType

            Write-PCXLog "Collection refresh type updated: $CollectionName"

        }
        catch {
            Write-PCXLog -Message "Failed to set collection refresh type for '$CollectionName'. $($_.Exception.Message)" -Level ERROR
            throw
        }
    }

    end {
        Write-PCXOperationEnd
    }
}
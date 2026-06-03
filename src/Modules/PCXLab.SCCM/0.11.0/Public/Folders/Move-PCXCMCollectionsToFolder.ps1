function Move-PCXCMCollectionsToFolder {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [pscustomobject]$Collections,

        [Parameter(Mandatory)]
        [pscustomobject]$meta,

        [Parameter(Mandatory)]
        [string]$ObjectName
    )

    begin {

        Write-PCXOperationStart
    }
    process {
        try {

            $folder = "\DeviceCollection\Mphasis Application Deployment\$($meta.Company)\$($meta.Product)\$ObjectName"

            $null = New-PCXCMFolder -Path $folder

            $collectionList = @(
                $Collections.Available,
                $Collections.Install,
                $Collections.Uninstall,
                $Collections.Exception
            )

            foreach ($collection in $collectionList) {

                if (-not $collection) {
                    continue
                }

                $collectionObject = Get-CMDeviceCollection -Name $collection

                Move-PCXCMObject -InputObject $collectionObject -FolderPath $folder

                Write-PCXLog "Moved Collection: $collection"
            }
        }
        catch {
            Write-PCXLog -Message "Failed to move collections: $ObjectName. $($_.Exception.Message)" -Level ERROR

            throw
        }
        
    }
    end {

        Write-PCXOperationEnd -Status Success
    }
}





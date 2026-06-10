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

            $collectionNames = @(
                $Collections.Available,
                $Collections.Install,
                $Collections.Uninstall,
                $Collections.Exception
            ) | Where-Object { $_ }

            foreach ($name in $collectionNames) {

                $collectionObject = Get-CMDeviceCollection -Name $name
                
                if ($collectionObject) {
                    Move-PCXCMObject -InputObject $collectionObject -FolderPath $folder
                    Write-PCXLog "Moved Collection: $name"
                }
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





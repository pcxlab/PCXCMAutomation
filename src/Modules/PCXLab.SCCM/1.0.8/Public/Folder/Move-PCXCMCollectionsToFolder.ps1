function Move-PCXCMCollectionsToFolder {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [pscustomobject]$Collections,

        [Parameter(Mandatory)]
        [pscustomobject]$Meta,

        [Parameter(Mandatory)]
        [string]$ObjectName
    )

    begin {

        Write-PCXOperationStart
    }

    process {

        try {

            $Folder = "\DeviceCollection\$($Global:PCXLogConfiguration.Organization) Application Deployment\$($Meta.Company)\$($Meta.Product)\$ObjectName"

            $null = New-PCXCMFolder -Path $Folder

            $CollectionNames = @(
                $Collections.Available,
                $Collections.Install,
                $Collections.Uninstall,
                $Collections.Exception
            ) | Where-Object { $_ }

            foreach ($CollectionName in $CollectionNames) {

                $CollectionObject = Get-CMDeviceCollection -Name $CollectionName -ErrorAction SilentlyContinue

                if ($CollectionObject) {

                    Move-PCXCMObject `
                        -InputObject $CollectionObject `
                        -FolderPath $Folder

                    Write-PCXLog "Moved Collection: $CollectionName"
                }
                else {

                    Write-PCXLog `
                        -Message "Collection not found: $CollectionName" `
                        -Level WARNING
                }
            }
        }
        catch {

            Write-PCXLog `
                -Message "Failed to move collections: $ObjectName. $($_.Exception.Message)" `
                -Level ERROR

            throw
        }
    }

    end {

        Write-PCXOperationEnd -Status Success
    }
}
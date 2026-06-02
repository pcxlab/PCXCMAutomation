function Move-PCXCMObject {

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [object]$InputObject,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$FolderPath
    )

    begin {
        #Write-PCXOperationStart
    }
    process {
        try {
            Ensure-PCXCMConnection

            $resolvedPath = Resolve-PCXCMPath -Path $FolderPath

            $objectName = $null

            if ($InputObject.Name) {
                $objectName = $InputObject.Name
            }
            else {
                $objectName = "Configuration Manager Object"
            }

            if ($PSCmdlet.ShouldProcess($objectName, "Move to $resolvedPath")) {

                $null = Move-CMObject -FolderPath $resolvedPath -InputObject $InputObject -ErrorAction Stop

                #Write-PCXMessage -Type Success -Message "'$objectName' moved to '$resolvedPath'."

                return New-PCXResultObject `
                    -Success $true `
                    -Action "Move Object" `
                    -Name $objectName `
                    -Path $resolvedPath `
                    -Message "Object moved successfully."
            }
        }
        catch {
            #Write-PCXMessage -Type Error -Message "Move failed: $($_.Exception.Message)"
            Write-PCXLog "Move failed: $($_.Exception.Message)" "ERROR"

            return New-PCXResultObject `
                -Success $false `
                -Action "Move Object" `
                -Name $objectName `
                -Path $FolderPath `
                -ErrorMessage $_.Exception.Message
        }
    }
    end {
        #Write-PCXOperationEnd -Status Success
    }
}

<#
.SYNOPSIS
Moves a Configuration Manager object into a folder.

.DESCRIPTION
Accepts a CM object and target folder path.
Folder path may be:
- \DeviceCollection\Test
- DeviceCollection\Test
- ABC:\DeviceCollection\Test

.EXAMPLE
$col = Get-PCXCMDeviceCollection -Name "PCX - Test"

Move-PCXCMObject -InputObject $col -FolderPath "\DeviceCollection\Production"
#>




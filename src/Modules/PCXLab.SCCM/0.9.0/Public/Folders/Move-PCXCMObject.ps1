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
        Write-PCXLog "BEGIN - PCXLab Automation"
    }
    process {
        try {
            if (-not (Test-PCXCMConnection)) {
                throw "No active Configuration Manager connection detected."
            }

            $resolvedPath = Resolve-PCXCMPath -Path $FolderPath

            $objectName = $null

            if ($InputObject.Name) {
                $objectName = $InputObject.Name
            }
            else {
                $objectName = "Configuration Manager Object"
            }

            if ($PSCmdlet.ShouldProcess($objectName, "Move to $resolvedPath")) {

                Move-CMObject -FolderPath $resolvedPath -InputObject $InputObject -ErrorAction Stop

                Write-PCXMessage -Type Success -Message "'$objectName' moved to '$resolvedPath'."

                return New-PCXResultObject `
                    -Success $true `
                    -Action "Move Object" `
                    -Name $objectName `
                    -Path $resolvedPath `
                    -Message "Object moved successfully."
            }
        }
        catch {
            Write-PCXMessage -Type Error -Message "Move failed: $($_.Exception.Message)"

            return New-PCXResultObject `
                -Success $false `
                -Action "Move Object" `
                -Name $objectName `
                -Path $FolderPath `
                -Error $_.Exception.Message
        }
        finally {
            Write-PCXLog "Move object operation completed: $objectName"
        }
    }
    end {
        Write-PCXLog "END - www.pcxlab.com"
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
$col = Get-PCXCMCollection -Name "PCX - Test"

Move-PCXCMObject -InputObject $col -FolderPath "\DeviceCollection\Production"
#>
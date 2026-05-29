function New-PCXCMDeviceCollectionInFolder {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$CollectionName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$LimitingCollection = "All Systems",

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$FolderPath = "\DeviceCollection\TEMP",

        [Parameter()]
        [switch]$PassThru
    )

    begin {
        Write-Verbose "PCXLab - Starting New-PCXCMCollectionInFolder"
    }

    process {
        try {
            # Normalize path
            $FolderPath = $FolderPath.Trim().TrimEnd('\')
            $ResolvedFolderPath = Resolve-PCXCMPath -Path $FolderPath

            Write-Verbose "PCXLab - Input folder path    : $FolderPath"
            Write-Verbose "PCXLab - Resolved CM path    : $ResolvedFolderPath"

            # -------------------------------------------------
            # Ensure folder exists
            # -------------------------------------------------
            if ($PSCmdlet.ShouldProcess($FolderPath, "Create folder structure if missing")) {

                $folderResult = New-PCXCMFolder -Path $FolderPath

                if ($folderResult.Success -eq $false) {
                    Write-Host "Folder creation failed: $($folderResult.Error) - PCXLab" -ForegroundColor Red
                    return
                }
                else {
                    Write-Host "Folder path '$FolderPath' verified/created successfully. - PCXLab" -ForegroundColor Green
                }
            }

            # -------------------------------------------------
            # Check collection
            # -------------------------------------------------
            $collectionObject = Get-CMDeviceCollection -Name $CollectionName -ErrorAction SilentlyContinue
            $collectionCreated = $false

            if (-not $collectionObject) {

                if ($PSCmdlet.ShouldProcess($CollectionName, "Create device collection")) {

                    New-CMDeviceCollection `
                        -Name $CollectionName `
                        -LimitingCollectionName $LimitingCollection | Out-Null

                    Write-Host "Collection '$CollectionName' with limiting '$LimitingCollection' created successfully. - PCXLab" -ForegroundColor Green

                    $collectionCreated = $true
                }

                $collectionObject = Get-CMDeviceCollection -Name $CollectionName -ErrorAction Stop
            }
            else {
                Write-Host "Collection '$CollectionName' already exists. - PCXLab" -ForegroundColor Yellow
            }

            # -------------------------------------------------
            # Move collection
            # -------------------------------------------------
            if ($PSCmdlet.ShouldProcess($CollectionName, "Move collection to $ResolvedFolderPath")) {

                Move-CMObject `
                    -FolderPath $ResolvedFolderPath `
                    -InputObject $collectionObject `
                    -ErrorAction Stop

                Write-Host "Collection '$CollectionName' moved to '$ResolvedFolderPath'. - PCXLab" -ForegroundColor Green
            }

            # -------------------------------------------------
            # Return object
            # -------------------------------------------------
            $result = [pscustomobject]@{
                Success            = $true
                CollectionName     = $CollectionName
                LimitingCollection = $LimitingCollection
                FolderPath         = $FolderPath
                ResolvedFolderPath = $ResolvedFolderPath
                CollectionCreated  = $collectionCreated
                Timestamp          = Get-Date
            }

            if ($PassThru) {
                $result
            }
        }
        catch {
            $message = $_.Exception.Message

            Write-Host "ERROR (PCXLab Automation): $message" -ForegroundColor Red

            if ($PassThru) {
                [pscustomobject]@{
                    Success        = $false
                    CollectionName = $CollectionName
                    FolderPath     = $FolderPath
                    Error          = $message
                    Timestamp      = Get-Date
                }
            }
        }
        finally {
            Write-Verbose "PCXLab - Execution completed for New-PCXCMCollectionInFolder"
        }
    }

    end {
        Write-Verbose "PCXLab - Function finished"
    }
}
<#
.SYNOPSIS
PCXLab Configuration Manager automation function to create a Device Collection and place it into a specified folder structure.

.DESCRIPTION
This function is part of the PCXLab (www.pcxlab.com) Configuration Manager automation toolkit.

It performs the following actions:

- Creates a new Device Collection if it does not already exist
- Uses the specified Limiting Collection (default: All Systems)
- Ensures the target folder structure exists using PCXLab folder automation functions
- Resolves folder paths using Resolve-PCXCMPath
- Moves the collection into the requested Configuration Manager folder
- Supports -WhatIf and -Confirm for safe change control

This function helps standardize collection creation, improve object organization,
and automate repetitive administrative tasks in Microsoft Configuration Manager.

.REQUIREMENTS
- Microsoft Configuration Manager PowerShell module
- Active connection to a Configuration Manager site PSDrive (for example: ABC:)
- Required helper functions:
    Resolve-PCXCMPath
    New-PCXCMFolder

.RELATED COMMANDS
New-CMDeviceCollection
https://learn.microsoft.com/en-us/powershell/module/configurationmanager/new-cmdevicecollection

Get-CMDeviceCollection
https://learn.microsoft.com/en-us/powershell/module/configurationmanager/get-cmdevicecollection

Move-CMObject
https://learn.microsoft.com/en-us/powershell/module/configurationmanager/move-cmobject

.EXAMPLE
New-PCXCMCollectionInFolder -CollectionName "PKG_7zip_Install"

Creates the collection using default values and places it in:
\DeviceCollection\TEMP

.EXAMPLE
New-PCXCMCollectionInFolder `
    -CollectionName "PKG_7zip_Install" `
    -FolderPath "\DeviceCollection\Software"

Creates the collection and moves it into the Software folder.

.EXAMPLE
New-PCXCMCollectionInFolder `
    -CollectionName "PKG_7zip_Uninstall" `
    -LimitingCollection "All Systems" `
    -FolderPath "\DeviceCollection\Software"

Creates the collection with a custom limiting collection.

.EXAMPLE
New-PCXCMCollectionInFolder `
    -CollectionName "PKG_7zip_2.0.0_[Install]" `
    -FolderPath "\DeviceCollection\7zip"

New-PCXCMCollectionInFolder `
    -CollectionName "PKG_7zip_2.0.0_[Available]" `
    -FolderPath "\DeviceCollection\7zip"

New-PCXCMCollectionInFolder `
    -CollectionName "PKG_7zip_2.0.0_[Uninstall]" `
    -FolderPath "\DeviceCollection\7zip"

Example bulk naming pattern usage.

.EXAMPLE
New-PCXCMCollectionInFolder `
    -CollectionName "Pilot Devices" `
    -FolderPath "\DeviceCollection\Testing" `
    -WhatIf

Shows what actions would occur without making changes.

.OUTPUTS
System.Management.Automation.PSCustomObject
(when -PassThru is used)

.NOTES
Author   : PCXLab Automation Team
Website  : www.pcxlab.com
Module   : PCXCM Automation Framework
Purpose  : Device Collection + Folder Automation Standardization
Platform : Microsoft Endpoint Configuration Manager (SCCM / MECM)
#>

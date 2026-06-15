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

        Write-PCXOperationStart
    }

    process {
        $OperationSucceeded = $true
        try {
            $FolderPath = $FolderPath.Trim().TrimEnd('\')
            $ResolvedFolderPath = Resolve-PCXCMPath -Path $FolderPath

            Write-Verbose "PCXLab - Input folder path : $FolderPath"
            Write-Verbose "PCXLab - Resolved CM path : $ResolvedFolderPath"

            if ($PSCmdlet.ShouldProcess($FolderPath, "Create folder structure if missing")) {
                $FolderResult = New-PCXCMFolder -Path $FolderPath

                if ($FolderResult.Success -eq $false) {
                    throw "Folder creation failed: $($FolderResult.Error)"
                }

                Write-PCXLog "Folder path '$FolderPath' verified or created successfully."
            }

            $CollectionObject = Get-PCXCMCachedCollection | Where-Object Name -eq $CollectionName | Select-Object -First 1
            $CollectionCreated = $false

            if (-not $CollectionObject) {

                if ($PSCmdlet.ShouldProcess($CollectionName, "Create device collection")) {
                    $null = New-CMDeviceCollection -Name $CollectionName -LimitingCollectionName $LimitingCollection
                    Write-PCXLog "Collection '$CollectionName' created successfully."
                    $CollectionCreated = $true
                }

                $CollectionObject = Get-CMDeviceCollection -Name $CollectionName -ErrorAction Stop

                if ($CollectionObject) {
                    $Global:PCXCMRuntimeCache.Collections += $CollectionObject
                }
            }
            else {
                Write-PCXLog "Device collection already exists: $CollectionName"
            }

            if ($PSCmdlet.ShouldProcess($CollectionName, "Move collection to $ResolvedFolderPath")) {
                Move-CMObject -FolderPath $ResolvedFolderPath -InputObject $CollectionObject -ErrorAction Stop
                Write-PCXLog "Collection '$CollectionName' moved to '$ResolvedFolderPath'."
            }

            $Result = [PSCustomObject]@{
                Success            = $true
                CollectionName     = $CollectionName
                LimitingCollection = $LimitingCollection
                FolderPath         = $FolderPath
                ResolvedFolderPath = $ResolvedFolderPath
                CollectionCreated  = $CollectionCreated
                Timestamp          = Get-Date
            }

            if ($PassThru) {
                return $Result
            }
        }
        catch {

            $OperationSucceeded = $false

            $Message = $_.Exception.Message

            Write-PCXLog -Message "Failed collection folder operation: $CollectionName. $Message" -Level ERROR

            if ($PassThru) {

                return [PSCustomObject]@{
                    Success        = $false
                    CollectionName = $CollectionName
                    FolderPath     = $FolderPath
                    Error          = $Message
                    Timestamp      = Get-Date
                }
            }

            throw
        }
        
    }

    end {

        if ($OperationSucceeded) {

            Write-PCXOperationEnd -Status Success
        }
        else {
}
    }
}

<#
.SYNOPSIS
Creates a Configuration Manager device collection and places it into a folder.

.DESCRIPTION
Creates the collection if it does not already exist, ensures the folder structure exists, and moves the collection into the requested Configuration Manager folder.

.EXAMPLE
New-PCXCMDeviceCollectionInFolder -CollectionName "PKG_7zip_Install"

.EXAMPLE
New-PCXCMDeviceCollectionInFolder -CollectionName "PKG_7zip_Install" -FolderPath "\DeviceCollection\Software"

.EXAMPLE
New-PCXCMDeviceCollectionInFolder -CollectionName "PKG_7zip_Uninstall" -LimitingCollection "All Systems" -FolderPath "\DeviceCollection\Software"

.EXAMPLE
New-PCXCMDeviceCollectionInFolder -CollectionName "PKG_7zip_2.0.0_[Install]" -FolderPath "\DeviceCollection\7zip"

.EXAMPLE
New-PCXCMDeviceCollectionInFolder -CollectionName "Pilot Devices" -FolderPath "\DeviceCollection\Testing" -WhatIf

.OUTPUTS
System.Management.Automation.PSCustomObject (when -PassThru is used)

.NOTES
Author  : PCXLab Automation Team
Website : www.pcxlab.com
#>



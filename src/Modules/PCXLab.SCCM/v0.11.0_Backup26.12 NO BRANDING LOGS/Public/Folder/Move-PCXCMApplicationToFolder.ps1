function Move-PCXCMApplicationToFolder {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [pscustomobject]$meta
    )
    begin {
        Write-PCXOperationStart
    }
    process {
        try {
            $ApplicationName = "APP $($meta.Name)"
            $folder = "\Application\Application Installation\$($meta.Company)\$($meta.Product)"

            $null = New-PCXCMFolder -Path $folder

            $applicationObject = Get-CMApplication -Name $ApplicationName -Fast
            if (-not $applicationObject) {
                throw "Application not found: $ApplicationName"
            }

            Move-PCXCMObject -InputObject $applicationObject -FolderPath $folder
            Write-PCXLog "Moved Application: $ApplicationName"

            return New-PCXResultObject `
                -Success $true `
                -Action "Move Application" `
                -Name $ApplicationName `
                -Path $folder `
                -Message "Application moved successfully."
        }
        catch {
            Write-PCXLog -Message "Failed to move application '$ApplicationName'. $($_.Exception.Message)" -Level ERROR
            return New-PCXResultObject `
                -Success $false `
                -Action "Move Application" `
                -Name $ApplicationName `
                -Path $folder `
                -ErrorMessage $_.Exception.Message
        }
    }
    end {
        Write-PCXOperationEnd
    }
}





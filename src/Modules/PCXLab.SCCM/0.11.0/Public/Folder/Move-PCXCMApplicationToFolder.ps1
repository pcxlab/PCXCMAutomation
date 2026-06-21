function Move-PCXCMApplicationToFolder {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [pscustomobject]$Meta
    )

    begin {
        Write-PCXOperationStart
    }

    process {
        try {

            $ApplicationName = "APP $($Meta.Name)"

            $folder = "\Application\Application Installation\$($Meta.Company)\$($Meta.Product)"

            $null = New-PCXCMFolder -Path $folder

            $ApplicationObject = Get-PCXCMApplication -ApplicationName $ApplicationName

            if (-not $applicationObject) {
                throw "Application not found: $ApplicationName"
            }

            Move-PCXCMObject `
                -InputObject $applicationObject `
                -FolderPath $folder

            Write-PCXLog "Moved Application: $ApplicationName"

            return New-PCXResultObject `
                -Success $true `
                -Action "Move Application" `
                -Name $ApplicationName `
                -Path $folder `
                -Message "Application moved successfully."
        }
        catch {

            Write-PCXLog `
                -Message "Failed to move application '$ApplicationName'. $($_.Exception.Message)" `
                -Level ERROR

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

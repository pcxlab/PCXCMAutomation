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
            # BUILD APPLICATION NAME
            $ApplicationName = "APP $($meta.Name)"

            # BUILD TARGET FOLDER
            $folder = "\Application\Application Installation\$($meta.Company)\$($meta.Product)"

            # ENSURE FOLDER EXISTS
            $null = New-PCXCMFolder -Path $folder

            # GET APPLICATION OBJECT
            $applicationObject = Get-CMApplication -Name $ApplicationName -Fast

            if (-not $applicationObject) {
                throw "Application not found: $ApplicationName"
            }

            # MOVE APPLICATION
            Move-PCXCMObject -InputObject $applicationObject -FolderPath $folder

            # LOG SUCCESS
            Write-PCXLog "Moved Application: $ApplicationName"

            # RETURN RESULT
            return New-PCXResultObject `
                -Success $true `
                -Action "Move Application" `
                -Name $ApplicationName `
                -Path $folder `
                -Message "Application moved successfully."
        }
        catch {
            Write-PCXLog "Failed to move application: $($_.Exception.Message)" "ERROR"

            return New-PCXResultObject `
                -Success $false `
                -Action "Move Application" `
                -Name $ApplicationName `
                -Path $folder `
                -ErrorMessage $_.Exception.Message
        }
        
    }
    end {

        Write-PCXOperationEnd -Status Success
    }
}




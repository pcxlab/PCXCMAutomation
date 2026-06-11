function Save-PCXApplicationXML {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        $Application,

        [Parameter(Mandatory)]
        $Xml
    )

    begin {

        Write-PCXOperationStart
    }
    process {
        try {

            $UpdatedXML = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::SerializeToString(
                $Xml,
                $True
            )

            $Application.SDMPackageXML = $UpdatedXML

            $Application.Put()

            return Set-CMApplication `
                -InputObject $Application `
                -PassThru
        }
        catch {
            Write-PCXLog -Message "Failed to save application XML. $($_.Exception.Message)" -Level ERROR
            throw
        }
        
    }
    end {

        Write-PCXOperationEnd -Status Success
    }
}





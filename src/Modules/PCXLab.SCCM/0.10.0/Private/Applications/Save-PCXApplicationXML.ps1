function Save-PCXApplicationXML {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        $Application,

        [Parameter(Mandatory)]
        $Xml
    )

    begin {
        Write-PCXLog "BEGIN - PCXLab Automation"
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
            Write-PCXLog "Failed to save application XML. $($_.Exception.Message)" "ERROR"
            throw
        }
        finally {
            Write-PCXLog "Save application XML operation completed"
        }
    }
    end {
        Write-PCXLog "END - www.pcxlab.com"
    }
}
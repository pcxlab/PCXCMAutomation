function Get-PCXApplicationXML {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        $Application
    )

    begin {
        Write-PCXLog "BEGIN - PCXLab Automation"
    }
    process {
        try {
            if (-not $Application.SDMPackageXML) {
                throw "Application XML is empty or application object is invalid."
            }
            return [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString(
                $Application.SDMPackageXML,
                $True
            )
        }
        catch {
            Write-PCXLog "Failed to get application XML. $($_.Exception.Message)" "ERROR"
            throw
        }
        finally {
            Write-PCXLog "Get application XML operation completed"
        }
    }
    end {
        Write-PCXLog "END - www.pcxlab.com"
    }
}
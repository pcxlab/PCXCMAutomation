function Get-PCXApplicationXML {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        $Application
    )

    begin {

        Write-PCXOperationStart
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
        
    }
    end {

        Write-PCXOperationEnd -Status Success
    }
}




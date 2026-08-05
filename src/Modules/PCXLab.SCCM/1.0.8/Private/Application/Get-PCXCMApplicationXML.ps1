function Get-PCXCMApplicationXML {

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
            Write-PCXLog "Application XML Length: $($Application.SDMPackageXML.Length)"
            if (-not $Application.SDMPackageXML) {
                throw "Application XML is empty or application object is invalid."
            }
            return [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString(
                $Application.SDMPackageXML,
                $True
            )
        }
        catch {
            Write-PCXLog -Message "Failed to get application XML. $($_.Exception.Message)" -Level ERROR
            throw
        }
    }
    end {
        Write-PCXOperationEnd -Status Success
    }
}





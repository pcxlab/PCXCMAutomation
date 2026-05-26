function Get-PCXApplicationXML {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        $Application
    )

    if (-not $Application.SDMPackageXML) {
        throw "Application XML is empty or application object is invalid."
    }

    return [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString(
        $Application.SDMPackageXML,
        $True
    )
}
function Save-PCXApplicationXML {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        $Application,

        [Parameter(Mandatory)]
        $Xml
    )

    $UpdatedXML = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::SerializeToString(
        $Xml,
        $True
    )

    $Application.SDMPackageXML = $UpdatedXML

    $Application.Put()

    Set-CMApplication `
        -InputObject $Application `
        -PassThru
}
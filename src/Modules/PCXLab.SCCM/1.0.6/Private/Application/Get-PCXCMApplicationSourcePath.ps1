function Get-PCXCMApplicationSourcePath {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Application
    )

    try {

        [xml]$ApplicationXml = $Application.SDMPackageXML

        $ContentLocation = $ApplicationXml.SelectSingleNode(
            "//*[local-name()='Content']/*[local-name()='Location']"
        )

        if ($ContentLocation) {
            return $ContentLocation.InnerText
        }

        return $null
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}

function Get-PCXCMApplicationOwner {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Application
    )

    try {

        # Future enhancement:
        # CM Category
        # AD Group
        # Custom Property
        # External CMDB

        return $null
    }
    catch {

        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}
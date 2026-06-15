function Test-PCXCMPackageExists {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$PackageName
    )

    try {
        #return $null -ne (Get-CMPackage -Name $PackageName -ErrorAction SilentlyContinue)
        return $null -ne (Get-CMPackage -Name $PackageName -Fast -ErrorAction SilentlyContinue)
    }
    catch {
        Write-PCXLog -Message $_.Exception.Message -Level ERROR
        throw
    }
}
function Write-PCXBanner {

    [CmdletBinding()]
    param()

    Write-PCXLog "========================================================"
    Write-PCXLog $Global:PCXLogConfiguration.FrameworkName
    Write-PCXLog $Global:PCXLogConfiguration.Website
    Write-PCXLog "Version 1.0"
    Write-PCXLog "========================================================"
}
function Get-PCXCMDefaultTestMachinesCollection {

    [CmdletBinding()]
    param()

    return Get-PCXCMSetting -Name "Collections.DefaultTestMachinesCollection"
}
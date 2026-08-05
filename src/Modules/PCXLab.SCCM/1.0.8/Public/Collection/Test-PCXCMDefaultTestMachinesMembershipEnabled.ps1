function Test-PCXCMDefaultTestMachinesMembershipEnabled {

    [CmdletBinding()]
    param()

    return [bool](Get-PCXCMSetting -Name "Collections.EnableDefaultTestMachinesMembership")
}
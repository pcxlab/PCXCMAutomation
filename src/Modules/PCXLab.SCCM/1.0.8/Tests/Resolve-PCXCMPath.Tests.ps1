# ============================================================
# FILE: Tests\Resolve-PCXCMPath.Tests.ps1
# Requires Pester
# ============================================================

Describe 'Resolve-PCXCMPath' {

    BeforeAll {
        Mock Get-PCXCMSiteDrive { 'ABC' }
    }

    It 'Should resolve rooted path' {
        Resolve-PCXCMPath -Path '\DeviceCollection\Test' |
            Should -Be 'ABC:\DeviceCollection\Test'
    }

    It 'Should resolve non-rooted path' {
        Resolve-PCXCMPath -Path 'DeviceCollection\Test' |
            Should -Be 'ABC:\DeviceCollection\Test'
    }

    It 'Should preserve provider path correctly' {
        Resolve-PCXCMPath -Path 'XYZ:\DeviceCollection\Test' |
            Should -Be 'ABC:\DeviceCollection\Test'
    }
}




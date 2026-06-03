# ============================================================
# FILE: Tests\New-PCXCMCollectionInFolder.Tests.ps1
# Requires Pester
# ============================================================

Describe 'New-PCXCMCollectionInFolder' {

    BeforeAll {

        Mock Resolve-PCXCMPath { 'ABC:\DeviceCollection\Test' }

        Mock New-PCXCMFolder {
            [pscustomobject]@{
                Success = $true
            }
        }

        Mock Get-CMDeviceCollection { $null }

        Mock New-CMDeviceCollection { }

        Mock Move-CMObject { }
    }

    It 'Should create collection successfully' {

        $result = New-PCXCMCollectionInFolder `
            -CollectionName 'PCX Test Collection' `
            -PassThru

        $result.Success | Should -Be $true
    }
}



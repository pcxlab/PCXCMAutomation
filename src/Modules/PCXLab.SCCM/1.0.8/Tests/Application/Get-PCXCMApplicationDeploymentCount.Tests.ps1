Describe 'Get-PCXCMApplicationDeploymentCount' {

    BeforeAll {

        Ensure-PCXCMConnection

        $Application = Get-CMApplication -Name 'APP Google Chrome 145.0.7632.46' -Fast

        $Result = Get-PCXCMApplicationDeploymentCount -Application $Application
    }

    It 'Returns a value' {

        $Result | Should Not Be $null
    }

    It 'Returns an integer' {

        $Result.GetType().Name | Should Be 'Int32'
    }

    It 'Returns a value greater than or equal to zero' {

        ($Result -ge 0) | Should Be $true
    }
}

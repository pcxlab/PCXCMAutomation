(Get-Module PCXLab.SCCM).Invoke({

    function Test-PCXLogging {

        begin {
            Write-PCXOperationStart
        }

        process {

            Write-PCXLog "Step 1"
            Write-PCXLog "Step 2"
            Write-PCXLog "Step 3"
        }

        end {
            Write-PCXOperationEnd
        }
    }

    $Global:PCXOperationNames["Test-PCXLogging"] = "Logging Test"

    Test-PCXLogging
})

.\Tests\Run-LoggingTests.ps1
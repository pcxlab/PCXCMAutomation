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

Test-PCXLogging
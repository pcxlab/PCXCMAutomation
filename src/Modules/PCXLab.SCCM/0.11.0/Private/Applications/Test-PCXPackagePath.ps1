function Test-PCXPackagePath {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    begin {

        $OperationSucceeded = $true

        Write-PCXOperationStart
    }

    process {

        try {

            $cleanPath = $Path.Trim()

            if (-not [System.IO.Directory]::Exists($cleanPath)) {
                throw "Path not accessible: $cleanPath"
            }

            $items = [System.IO.Directory]::GetFiles($cleanPath) | ForEach-Object {
                [System.IO.FileInfo]$_
            }

            if (-not $items -or $items.Count -eq 0) {
                throw "No files found in package path: $cleanPath"
            }

            return $items
        }
        catch {

            $OperationSucceeded = $false
Write-PCXLog "File enumeration failed on path: $cleanPath. $($_.Exception.Message)" "ERROR"

            throw "File enumeration failed on path: $cleanPath | $($_.Exception.Message)"
        }
    }

    end {

        if ($OperationSucceeded) {

            Write-PCXOperationEnd -Status Success
        }
    }
}



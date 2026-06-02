function Test-PCXPackagePath {

    [CmdletBinding()]
    param(

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    begin {
        Write-PCXLog "BEGIN - PCXLab Automation"
    }
    process {
        try {
            $cleanPath = $Path.Trim()

            # Validate directory using pure .NET
            if (-not [System.IO.Directory]::Exists($cleanPath)) {
                throw "Path not accessible: $cleanPath"
            }

            # Enumerate files safely
            $items = [System.IO.Directory]::GetFiles($cleanPath) | ForEach-Object {
                [System.IO.FileInfo]$_
            }

            if (-not $items -or $items.Count -eq 0) {
                throw "No files found in package path: $cleanPath"
            }

            return $items
        }
        catch {
            Write-PCXLog "File enumeration failed on path: $cleanPath. $($_.Exception.Message)" "ERROR"
            throw
        }
        finally {
            Write-PCXLog "Package path validation operation completed: $cleanPath"
        }
    }
    end {
        Write-PCXLog "END - www.pcxlab.com"
    }
}
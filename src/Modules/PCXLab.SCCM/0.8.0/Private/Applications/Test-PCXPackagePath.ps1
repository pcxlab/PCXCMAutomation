function Test-PCXPackagePath {
    param([string]$Path)

    $cleanPath = $Path.Trim()

    try {

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
        throw "File enumeration failed on path: $cleanPath | $($_.Exception.Message)"
    }
}
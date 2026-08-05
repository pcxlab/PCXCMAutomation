class MetadataService {
    [Metadata] ExtractMetadata([string]$path) {
        if (Get-Command Get-PCXMetadataFromPath -ErrorAction SilentlyContinue) {
            $rawMetadata = Get-PCXMetadataFromPath -Path $path
            [Logger]::Log("Metadata extracted using module logic.")
        }
        else {
            $rawMetadata = $this.FallbackExtractMetadata($path)
            [Logger]::Log("Metadata extracted using UI helper (Fallback).", "WARNING")
        }

        $versionStr = "Not Detected"
        if ($null -ne $rawMetadata.Version -and -not [string]::IsNullOrWhiteSpace($rawMetadata.Version)) {
            $versionStr = $rawMetadata.Version.ToString()
        }

        return [Metadata]::new($rawMetadata.Name, $rawMetadata.Company, $rawMetadata.Product, $versionStr)
    }

    [hashtable] FallbackExtractMetadata([string]$path) {
        $clean = $path.TrimEnd("\")
        $parts = $clean -split "\\"
        if ($parts.Count -lt 3) {
            throw "Invalid path structure. Path must be like ...\Company\Product\Package"
        }

        $company = $parts[-3]
        $raw = $parts[-1]

        $versionMatch = [regex]::Match($raw, '\d+(\.\d+)+')
        $version = $(if ($versionMatch.Success) { $versionMatch.Value } else { "1.0" })

        $product = $raw -replace [regex]::Escape($version), ""
        $product = $product -replace '[\.\-_]', ' '
        $product = ($product -replace '\s+', ' ').Trim()
        $product = $product -replace [regex]::Escape($company), ""
        $product = ($product -replace '\s+', ' ').Trim()

        $name = "$company $product $version"

        return @{
            Name    = $name
            Company = $company
            Product = $product
            Version = $version
        }
    }
}

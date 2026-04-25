function Resolve-PCXPath {
    param([string]$Path)
    (Resolve-Path $Path).Path
}

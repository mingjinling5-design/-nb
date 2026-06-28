$ErrorActionPreference = "Stop"

$baseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$output = Join-Path $baseDir "Modex-MH-Agent-portable-20260628.zip"
$expectedHash = "2BC8CADDB13E1337417698C4292BA55857782ECA8781CB13A9FC4A0D9025B32B"

$parts = Get-ChildItem -LiteralPath $baseDir -Filter "Modex-MH-Agent-portable-20260628.zip.part-*" |
    Sort-Object Name

if ($parts.Count -eq 0) {
    throw "No archive parts found: Modex-MH-Agent-portable-20260628.zip.part-*"
}

if (Test-Path -LiteralPath $output) {
    Remove-Item -LiteralPath $output -Force
}

$outStream = [System.IO.File]::Open($output, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write)
try {
    foreach ($part in $parts) {
        Write-Host "Merging $($part.Name)"
        $inStream = [System.IO.File]::OpenRead($part.FullName)
        try {
            $inStream.CopyTo($outStream)
        } finally {
            $inStream.Dispose()
        }
    }
} finally {
    $outStream.Dispose()
}

$actualHash = (Get-FileHash -LiteralPath $output -Algorithm SHA256).Hash
if ($actualHash -ne $expectedHash) {
    throw "SHA256 check failed. Actual: $actualHash"
}

Write-Host ""
Write-Host "Rebuild complete: $output"
Write-Host "SHA256 OK: $actualHash"

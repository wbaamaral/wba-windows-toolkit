function Get-StaticDocsMetadata {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [object]$Command
    )

    $metadata = @{}
    $sourcePath = $Command.ScriptBlock.File

    if (-not $sourcePath -or -not (Test-Path -LiteralPath $sourcePath)) {
        return $metadata
    }

    $line = Get-Content -LiteralPath $sourcePath -ErrorAction SilentlyContinue |
        Where-Object { $_ -match '^\s*#\s*WBA-DOCS:\s*(?<Metadata>.+)$' } |
        Select-Object -First 1

    if (-not $line) {
        return $metadata
    }

    $rawMetadata = [regex]::Match($line, '^\s*#\s*WBA-DOCS:\s*(?<Metadata>.+)$').Groups['Metadata'].Value
    foreach ($entry in ($rawMetadata -split '\s*;\s*')) {
        if ($entry -notmatch '^(?<Key>[A-Za-z][A-Za-z0-9_-]*)\s*=\s*(?<Value>.+)$') {
            continue
        }

        $metadata[$Matches.Key] = $Matches.Value.Trim()
    }

    $metadata
}

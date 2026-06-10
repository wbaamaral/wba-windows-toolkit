[CmdletBinding()]
param()

$publicPath  = Join-Path $PSScriptRoot 'Public'
$privatePath = Join-Path $PSScriptRoot 'Private'

Get-ChildItem -Path $publicPath, $privatePath -Filter '*.ps1' -ErrorAction SilentlyContinue |
    ForEach-Object {
        . $_.FullName
    }

Export-ModuleMember -Function @(
    'Test-IsAdministrator',
    'Invoke-Safe',
    'Format-FileSize',
    'Write-Ok',
    'Write-Fail',
    'Write-Warn',
    'Write-Info',
    'Write-Title',
    'Write-Section',
    'Read-YesNo',
    'Invoke-ExternalCommand',
    'ConvertTo-HtmlSafe'
)

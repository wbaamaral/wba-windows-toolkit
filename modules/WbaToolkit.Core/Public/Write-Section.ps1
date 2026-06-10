function Write-Section {
    <#
    .SYNOPSIS
        Escreve um separador com titulo padronizado.

    .PARAMETER Title
        Titulo da secao.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Title
    )

    Write-Host ''
    Write-Host ('=' * 60) -ForegroundColor Cyan
    Write-Host " $Title" -ForegroundColor Cyan
    Write-Host ('=' * 60) -ForegroundColor Cyan
}

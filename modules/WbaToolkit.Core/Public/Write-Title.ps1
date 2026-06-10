function Write-Title {
    <#
    .SYNOPSIS
        Escreve um titulo de secao padronizado.

    .PARAMETER Message
        Titulo a ser apresentado.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message
    )

    Write-Host ''
    Write-Host ('=' * 80) -ForegroundColor Cyan
    Write-Host $Message -ForegroundColor Cyan
    Write-Host ('=' * 80) -ForegroundColor Cyan
}

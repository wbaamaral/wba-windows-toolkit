function Write-Warn {
    <#
    .SYNOPSIS
        Escreve uma mensagem de alerta padronizada.

    .PARAMETER Message
        Texto a ser apresentado.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message
    )

    Write-StatusLine -Label 'AVISO' -Message $Message -Color Yellow
}

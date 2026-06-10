function Write-Ok {
    <#
    .SYNOPSIS
        Escreve uma mensagem de sucesso padronizada.

    .PARAMETER Message
        Texto a ser apresentado.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message
    )

    Write-StatusLine -Label 'OK' -Message $Message -Color Green
}

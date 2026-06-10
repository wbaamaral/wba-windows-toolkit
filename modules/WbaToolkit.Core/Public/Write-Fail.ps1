function Write-Fail {
    <#
    .SYNOPSIS
        Escreve uma mensagem de falha padronizada.

    .PARAMETER Message
        Texto a ser apresentado.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message
    )

    Write-StatusLine -Label 'FALHA' -Message $Message -Color Red
}

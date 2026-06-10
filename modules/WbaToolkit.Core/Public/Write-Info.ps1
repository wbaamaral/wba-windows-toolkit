function Write-Info {
    <#
    .SYNOPSIS
        Escreve uma mensagem informativa padronizada.

    .PARAMETER Message
        Texto a ser apresentado.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message
    )

    Write-StatusLine -Label 'INFO' -Message $Message -Color White
}

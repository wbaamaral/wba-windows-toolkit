function Format-FileSize {
    <#
    .SYNOPSIS
        Formata um valor em bytes para uma unidade legivel.

    .DESCRIPTION
        Converte bytes em uma representacao legivel usando TB, GB, MB, KB ou B,
        mantendo uma saida previsivel para relatorios em console e HTML.

    .PARAMETER Bytes
        Quantidade de bytes a formatar.

    .EXAMPLE
        Format-FileSize -Bytes 1536
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateRange(0, [long]::MaxValue)]
        [long]$Bytes
    )

    if ($Bytes -ge 1TB) { return "{0:N2} TB" -f ($Bytes / 1TB) }
    if ($Bytes -ge 1GB) { return "{0:N2} GB" -f ($Bytes / 1GB) }
    if ($Bytes -ge 1MB) { return "{0:N1} MB" -f ($Bytes / 1MB) }
    if ($Bytes -ge 1KB) { return "{0:N1} KB" -f ($Bytes / 1KB) }
    return "$Bytes B"
}

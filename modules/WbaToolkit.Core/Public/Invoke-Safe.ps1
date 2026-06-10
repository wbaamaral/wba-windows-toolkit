function Invoke-Safe {
    <#
    .SYNOPSIS
        Executa um bloco de codigo com tratamento padronizado de erros.

    .DESCRIPTION
        Executa um scriptblock, captura excecoes e padroniza a saida de erro sem
        interromper o fluxo do chamador. Retorna $true quando a operacao conclui
        com sucesso e $false quando ocorre falha.

    .PARAMETER Description
        Descricao curta da operacao em execucao.

    .PARAMETER Command
        Bloco de codigo a ser executado.

    .EXAMPLE
        Invoke-Safe -Description 'Limpeza de cache' -Command { Remove-Item -LiteralPath $path -Force }
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Description,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [scriptblock]$Command
    )

    try {
        & $Command

        if ($LASTEXITCODE -ne $null -and $LASTEXITCODE -ne 0) {
            Write-Warning "A operacao '$Description' retornou codigo de saida $LASTEXITCODE."
            return $false
        }

        return $true
    }
    catch {
        Write-Error -Message "Falha em '$Description'. Detalhes: $($_.Exception.Message)"
        return $false
    }
}

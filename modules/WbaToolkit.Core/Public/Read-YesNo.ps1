function Read-YesNo {
    <#
    .SYNOPSIS
        Faz uma pergunta de confirmacao simples e retorna um valor booleano.

    .DESCRIPTION
        Exibe uma pergunta no console e interpreta respostas comuns em pt-BR e en-US.
        Resposta vazia retorna o valor padrao informado.

    .PARAMETER Question
        Pergunta exibida ao operador.

    .PARAMETER DefaultYes
        Define se Enter sem resposta deve ser interpretado como sim.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Question,

        [Parameter(Mandatory = $false)]
        [bool]$DefaultYes = $false
    )

    $suffix = if ($DefaultYes) { '[S/n]' } else { '[s/N]' }

    while ($true) {
        $answer = Read-Host "$Question $suffix"

        if ([string]::IsNullOrWhiteSpace($answer)) {
            return $DefaultYes
        }

        switch -Regex ($answer.Trim().ToLower()) {
            '^(s|sim|y|yes)$' { return $true }
            '^(n|nao|não|no)$' { return $false }
            default { Write-Warn 'Resposta inválida. Digite S ou N.' }
        }
    }
}

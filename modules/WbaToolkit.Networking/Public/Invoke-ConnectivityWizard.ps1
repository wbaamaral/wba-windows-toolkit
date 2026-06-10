function Invoke-ConnectivityWizard {
    <#
    .SYNOPSIS
        Executa um wizard simples para o diagnóstico de conectividade.
    #>
    [CmdletBinding()]
    param()

    Write-Host 'WBA Connectivity Tester' -ForegroundColor Cyan
    Write-Host '1. Executar teste completo'
    Write-Host '2. Cancelar'

    $choice = Read-Host 'Escolha uma opcao'
    switch ($choice) {
        '1' {
            $report = Invoke-ConnectivityTest
            Show-ConnectivityReport -Report $report
            $report
        }
        default {
            Write-Host 'Operacao cancelada.' -ForegroundColor Yellow
            return
        }
    }
}

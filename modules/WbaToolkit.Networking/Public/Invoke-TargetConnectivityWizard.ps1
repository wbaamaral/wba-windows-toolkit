function Invoke-TargetConnectivityWizard {
    <#
    .SYNOPSIS
        Executa wizard para teste de conectividade contra alvo informado pelo operador.
    #>
    [CmdletBinding()]
    param()

    # WBA-DOCS: Category=Networking; Related=Invoke-TargetConnectivityTest,Show-ConnectivityReport; Manual=Wizard interativo para teste direcionado

    Write-Host ''
    Write-Host 'WBA Target Connectivity Tester' -ForegroundColor Cyan

    do {
        $target = Read-Host 'Informe o IP ou nome do destino'
    } while ([string]::IsNullOrWhiteSpace($target))

    Write-Host ''
    Write-Host 'Protocolo:'
    Write-Host '1. TCP'
    Write-Host '2. UDP'
    Write-Host '3. ICMP'
    Write-Host '4. Todos'

    $protocol = $null
    while (-not $protocol) {
        switch (Read-Host 'Escolha uma opcao') {
            '1' { $protocol = 'TCP' }
            '2' { $protocol = 'UDP' }
            '3' { $protocol = 'ICMP' }
            '4' { $protocol = 'All' }
            default { Write-Host 'Opcao invalida.' -ForegroundColor Yellow }
        }
    }

    $portSpec = $null
    if ($protocol -in @('TCP', 'UDP', 'All')) {
        do {
            $portSpec = Read-Host 'Informe porta, lista ou range (ex: 443, 80,443,3389, 8000-8010)'
        } while ([string]::IsNullOrWhiteSpace($portSpec))
    }

    $report = Invoke-TargetConnectivityTest -TargetAddress $target -Protocol $protocol -PortSpec $portSpec
    Show-ConnectivityReport -Report $report
    $report
}

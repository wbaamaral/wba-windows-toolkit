function Invoke-TargetConnectivityTest {
    <#
    .SYNOPSIS
        Executa teste de conectividade contra um alvo especifico.

    .DESCRIPTION
        Testa ICMP, TCP, UDP ou todos os protocolos contra um endereco IP ou nome informado.
        Para TCP e UDP, aceita porta unica, lista de portas ou range.

    .PARAMETER TargetAddress
        IP ou nome DNS do destino.

    .PARAMETER Protocol
        Protocolo a testar: TCP, UDP, ICMP ou All.

    .PARAMETER PortSpec
        Porta unica, lista ou range. Exemplos: 443, 80,443,3389 ou 8000-8010.

    .EXAMPLE
        Invoke-TargetConnectivityTest -TargetAddress 192.168.5.1 -Protocol ICMP

    .EXAMPLE
        Invoke-TargetConnectivityTest -TargetAddress 192.168.5.10 -Protocol TCP -PortSpec '80,443,3389'

    .EXAMPLE
        Invoke-TargetConnectivityTest -TargetAddress 192.168.5.10 -Protocol All -PortSpec '53,80,443,8000-8010'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$TargetAddress,

        [Parameter(Mandatory = $true)]
        [ValidateSet('TCP', 'UDP', 'ICMP', 'All')]
        [string]$Protocol,

        [Parameter(Mandatory = $false)]
        [string]$PortSpec,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 60)]
        [int]$TimeoutSeconds = 5,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 10)]
        [int]$IcmpCount = 3,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 65535)]
        [int]$MaxPorts = 1024
    )

    # WBA-DOCS: Category=Networking; Related=Show-ConnectivityReport,Export-ConnectivityReport; Manual=Teste direcionado por alvo, protocolo e portas

    $startedAt = Get-Date
    $context = Get-NetworkContext
    $results = [System.Collections.ArrayList]::new()
    $needsPorts = $Protocol -in @('TCP', 'UDP', 'All')
    $ports = @()

    if ($needsPorts) {
        if ([string]::IsNullOrWhiteSpace($PortSpec)) {
            throw 'PortSpec e obrigatorio para testes TCP, UDP ou All.'
        }

        $ports = @(Resolve-PortSpecification -PortSpec $PortSpec -MaxPorts $MaxPorts)
    }

    if ($Protocol -in @('ICMP', 'All')) {
        $null = $results.Add((Test-IcmpConnectivity -TargetAddress $TargetAddress -Count $IcmpCount -TimeoutSeconds $TimeoutSeconds))
    }

    if ($Protocol -in @('TCP', 'All')) {
        foreach ($port in $ports) {
            $null = $results.Add((Test-TcpPortConnectivity -TargetAddress $TargetAddress -Port $port -TimeoutSeconds $TimeoutSeconds -Direction 'Outbound' -Scope 'WAN'))
        }
    }

    if ($Protocol -in @('UDP', 'All')) {
        foreach ($port in $ports) {
            $null = $results.Add((Test-UdpPortConnectivity -TargetAddress $TargetAddress -Port $port -TimeoutSeconds $TimeoutSeconds -Direction 'Outbound' -Scope 'WAN'))
        }
    }

    $finishedAt = Get-Date
    $resultItems = @($results)
    $summary = Get-ConnectivitySummary -Results $resultItems

    [pscustomobject]@{
        ReportId    = [guid]::NewGuid().ToString()
        ReportType  = 'TargetConnectivity'
        StartedAt   = $startedAt
        FinishedAt  = $finishedAt
        Target      = $TargetAddress
        Protocol    = $Protocol
        PortSpec    = $PortSpec
        Ports       = $ports
        Context     = $context
        Results     = $resultItems
        Summary     = $summary
        Blocked     = $false
        BlockReason = $null
    }
}

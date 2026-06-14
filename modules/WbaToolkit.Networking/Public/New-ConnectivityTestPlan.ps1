function New-ConnectivityTestPlan {
    <#
    .SYNOPSIS
        Cria um plano de teste de conectividade estruturado.

    .DESCRIPTION
        Retorna um objeto de configuração com os alvos e parâmetros usados por Invoke-ConnectivityTest.
        Permite customizar os IPs, domínios para DNS, domínios para ICMP/TCP e porta TCP.

    .PARAMETER IpTargets
        Lista de endereços IP para teste ICMP. Padrão: servidores DNS públicos populares.

    .PARAMETER DnsTargets
        Lista de nomes DNS a serem resolvidos. Padrão: domínios de conectividade reconhecidos.

    .PARAMETER DomainTargets
        Lista de domínios para teste ICMP e TCP. Padrão: domínios de alta disponibilidade.

    .PARAMETER TcpPort
        Porta TCP usada nos testes de domínio. Padrão: 443.

    .PARAMETER Detailed
        Ativa coleta detalhada no relatório.

    .EXAMPLE
        $plan = New-ConnectivityTestPlan
        Invoke-ConnectivityTest @plan

    .EXAMPLE
        $plan = New-ConnectivityTestPlan -IpTargets @('10.0.0.1') -TcpPort 80
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string[]]$IpTargets = @('8.8.8.8', '8.8.4.4', '1.1.1.1', '9.9.9.9'),

        [Parameter(Mandatory = $false)]
        [string[]]$DnsTargets = @('www.google.com', 'www.microsoft.com', 'www.cloudflare.com', 'www.msftconnecttest.com'),

        [Parameter(Mandatory = $false)]
        [string[]]$DomainTargets = @('www.google.com', 'www.microsoft.com', 'www.cloudflare.com', 'www.amazon.com'),

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 65535)]
        [int]$TcpPort = 443,

        [Parameter(Mandatory = $false)]
        [switch]$Detailed
    )

    [pscustomobject]@{
        IpTargets     = @($IpTargets)
        DnsTargets    = @($DnsTargets)
        DomainTargets = @($DomainTargets)
        TcpPort       = $TcpPort
        Detailed      = [bool]$Detailed
    }
}

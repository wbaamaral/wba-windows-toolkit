function Test-GatewayConnectivity {
    <#
    .SYNOPSIS
        Executa teste de conectividade com o gateway padrão.

    .DESCRIPTION
        Executa Test-IcmpConnectivity no endereço de gateway informado e retorna um resultado com
        categoria e recomendação específicas de gateway.

    .PARAMETER GatewayAddress
        Endereço IP do gateway padrão a ser testado.

    .PARAMETER Count
        Número de pacotes ICMP a enviar. Padrão: 2.

    .EXAMPLE
        Test-GatewayConnectivity -GatewayAddress '192.168.1.1'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$GatewayAddress,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 10)]
        [int]$Count = 2
    )

    $icmp = Test-IcmpConnectivity -TargetAddress $GatewayAddress -Count $Count
    $recommendation = if ($icmp.Success) { 'Gateway responde ao ICMP.' } else { 'Verifique roteador, VLAN ou rota padrão.' }

    New-ConnectivityResult -TestName 'Gateway padrão' -Category 'Gateway' -Protocol $icmp.Protocol `
        -Direction $icmp.Direction -Scope $icmp.Scope -Target $GatewayAddress `
        -Success $icmp.Success -Status $icmp.Status -Classification $icmp.Classification `
        -LatencyMs $icmp.LatencyMs -ErrorMessage $icmp.ErrorMessage `
        -Recommendation $recommendation -StartedAt $icmp.StartedAt -FinishedAt $icmp.FinishedAt
}

function Test-GatewayConnectivity {
    <#
    .SYNOPSIS
        Executa teste de conectividade com o gateway padrão.
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

    $result = Test-IcmpConnectivity -TargetAddress $GatewayAddress -Count $Count
    $result.TestName = 'Gateway padrão'
    $result.Category = 'Gateway'
    $result.Target = $GatewayAddress
    $result.Recommendation = if ($result.Success) { 'Gateway responde ao ICMP.' } else { 'Verifique roteador, VLAN ou rota padrão.' }
    $result
}

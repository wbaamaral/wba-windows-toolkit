function Test-UdpPortConnectivity {
    <#
    .SYNOPSIS
        Executa teste UDP básico e classifica o resultado como inconclusivo quando não há confirmação.

    .DESCRIPTION
        Envia um datagrama UDP mínimo ao destino. Como UDP é sem conexão, a ausência de erro apenas
        indica que o envio ocorreu — não há confirmação de que a porta está aberta. O resultado
        é sempre classificado como Inconclusive (sucesso de envio) ou Failed (erro de socket).

    .PARAMETER TargetAddress
        Endereço IP ou nome DNS do destino.

    .PARAMETER Port
        Porta UDP a testar. Valores permitidos: 1–65535.

    .PARAMETER TimeoutSeconds
        Reservado para compatibilidade futura. Atualmente não aplica timeout de resposta UDP.

    .PARAMETER Direction
        Direção do teste: Inbound ou Outbound. Padrão: Outbound.

    .PARAMETER Scope
        Escopo da conectividade: LAN ou WAN. Padrão: WAN.

    .EXAMPLE
        Test-UdpPortConnectivity -TargetAddress '10.0.0.1' -Port 53

    .EXAMPLE
        Test-UdpPortConnectivity -TargetAddress '192.168.1.1' -Port 161 -Scope LAN
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$TargetAddress,

        [Parameter(Mandatory = $true)]
        [ValidateRange(1, 65535)]
        [int]$Port,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 60)]
        [int]$TimeoutSeconds = 5,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Inbound', 'Outbound')]
        [string]$Direction = 'Outbound',

        [Parameter(Mandatory = $false)]
        [ValidateSet('LAN', 'WAN')]
        [string]$Scope = 'WAN'
    )

    $startedAt = Get-Date
    try {
        $udp = [System.Net.Sockets.UdpClient]::new()
        try {
            [void]$udp.Send([byte[]](1,2,3,4), 4, $TargetAddress, $Port)
            New-ConnectivityResult -TestName 'Teste UDP' -Category 'Porta' -Protocol 'UDP' -Direction $Direction -Scope $Scope `
                -Target $TargetAddress -Port $Port -Success $true -Status 'Enviado' -Classification 'Inconclusive' `
                -Recommendation 'UDP enviado sem confirmação de abertura; resultado pode ser inconclusivo.' -StartedAt $startedAt -FinishedAt (Get-Date)
        }
        finally {
            $udp.Close()
        }
    }
    catch {
        New-ConnectivityResult -TestName 'Teste UDP' -Category 'Porta' -Protocol 'UDP' -Direction $Direction -Scope $Scope `
            -Target $TargetAddress -Port $Port -Success $false -Status 'Falha' -Classification 'Failed' -ErrorMessage $_.Exception.Message `
            -Recommendation 'Verifique conectividade de rede e filtragem UDP.' -StartedAt $startedAt -FinishedAt (Get-Date)
    }
}

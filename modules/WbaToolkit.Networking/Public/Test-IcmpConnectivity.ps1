function Test-IcmpConnectivity {
    <#
    .SYNOPSIS
        Executa teste ICMP contra um destino informado.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$TargetAddress,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 10)]
        [int]$Count = 3,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 60)]
        [int]$TimeoutSeconds = 5
    )

    $startedAt = Get-Date
    try {
        $reply = Test-Connection -ComputerName $TargetAddress -Count $Count -ErrorAction Stop
        $latency = $null
        if ($reply) {
            $latency = [math]::Round((($reply | Measure-Object -Property ResponseTime -Average).Average), 1)
        }

        New-ConnectivityResult -TestName 'Teste ICMP' -Category 'ICMP' -Protocol 'ICMP' -Direction 'Outbound' -Scope 'WAN' `
            -Target $TargetAddress -Success $true -Status 'Respondendo' -Classification 'Success' -LatencyMs $latency `
            -Recommendation 'Conectividade ICMP validada com sucesso.' -StartedAt $startedAt -FinishedAt (Get-Date)
    }
    catch {
        New-ConnectivityResult -TestName 'Teste ICMP' -Category 'ICMP' -Protocol 'ICMP' -Direction 'Outbound' -Scope 'WAN' `
            -Target $TargetAddress -Success $false -Status 'Sem resposta' -Classification 'Failed' -ErrorMessage $_.Exception.Message `
            -Recommendation 'Verifique firewall, rota ou indisponibilidade do destino.' -StartedAt $startedAt -FinishedAt (Get-Date)
    }
}

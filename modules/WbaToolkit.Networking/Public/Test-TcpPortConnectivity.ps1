function Test-TcpPortConnectivity {
    <#
    .SYNOPSIS
        Executa teste de conectividade TCP em porta informada.
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
    $client = $null
    try {
        $client = [System.Net.Sockets.TcpClient]::new()
        $async = $client.BeginConnect($TargetAddress, $Port, $null, $null)
        if (-not $async.AsyncWaitHandle.WaitOne($TimeoutSeconds * 1000, $false)) {
            $client.Close()
            return New-ConnectivityResult -TestName 'Teste TCP' -Category 'Porta' -Protocol 'TCP' -Direction $Direction -Scope $Scope `
                -Target $TargetAddress -Port $Port -Success $false -Status 'Timeout' -Classification 'Failed' `
                -Recommendation 'Timeout: verifique firewall, rota, NAT ou serviço indisponível.' -StartedAt $startedAt -FinishedAt (Get-Date)
        }

        $client.EndConnect($async)
        $latency = [math]::Round((Get-Date).Subtract($startedAt).TotalMilliseconds, 1)
        New-ConnectivityResult -TestName 'Teste TCP' -Category 'Porta' -Protocol 'TCP' -Direction $Direction -Scope $Scope `
            -Target $TargetAddress -Port $Port -Success $true -Status 'Aberta' -Classification 'Success' -LatencyMs $latency `
            -Recommendation 'Conectividade TCP validada com sucesso.' -StartedAt $startedAt -FinishedAt (Get-Date)
    }
    catch {
        New-ConnectivityResult -TestName 'Teste TCP' -Category 'Porta' -Protocol 'TCP' -Direction $Direction -Scope $Scope `
            -Target $TargetAddress -Port $Port -Success $false -Status 'Falha' -Classification 'Failed' -ErrorMessage $_.Exception.Message `
            -Recommendation 'Verifique firewall, serviço de destino e rota.' -StartedAt $startedAt -FinishedAt (Get-Date)
    }
    finally {
        if ($client) { $client.Close() }
    }
}

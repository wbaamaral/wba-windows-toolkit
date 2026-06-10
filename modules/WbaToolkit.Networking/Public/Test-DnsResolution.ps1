function Test-DnsResolution {
    <#
    .SYNOPSIS
        Valida resolução DNS para um nome informado.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        [ValidateSet('A', 'AAAA', 'SRV', 'CNAME', 'TXT')]
        [string]$Type = 'A'
    )

    $startedAt = Get-Date
    try {
        $records = Resolve-DnsName -Name $Name -Type $Type -ErrorAction Stop
        $ips = @($records | Where-Object { $_.IPAddress } | Select-Object -ExpandProperty IPAddress)
        New-ConnectivityResult -TestName 'Teste DNS' -Category 'DNS' -Protocol 'DNS' -Direction 'Outbound' -Scope 'WAN' `
            -Target $Name -Success $true -Status 'Resolvido' -Classification 'Success' -Details $records `
            -Recommendation 'Resolução DNS validada com sucesso.' -StartedAt $startedAt -FinishedAt (Get-Date) `
            -LatencyMs $null
    }
    catch {
        New-ConnectivityResult -TestName 'Teste DNS' -Category 'DNS' -Protocol 'DNS' -Direction 'Outbound' -Scope 'WAN' `
            -Target $Name -Success $false -Status 'Falha de resolução' -Classification 'Failed' -ErrorMessage $_.Exception.Message `
            -Recommendation 'Verifique servidores DNS, rota e domínio consultado.' -StartedAt $startedAt -FinishedAt (Get-Date)
    }
}

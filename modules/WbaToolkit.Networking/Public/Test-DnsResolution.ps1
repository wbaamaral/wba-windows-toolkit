function Test-DnsResolution {
    <#
    .SYNOPSIS
        Valida resolução DNS para um nome informado.

    .DESCRIPTION
        Executa Resolve-DnsName para o nome e tipo de registro informados e retorna um objeto de resultado
        padronizado com os registros obtidos em Details.

    .PARAMETER Name
        Nome DNS a ser resolvido.

    .PARAMETER Type
        Tipo de registro DNS. Valores suportados: A, AAAA, SRV, CNAME, TXT. Padrão: A.

    .EXAMPLE
        Test-DnsResolution -Name 'www.google.com'

    .EXAMPLE
        Test-DnsResolution -Name '_ldap._tcp.dominio.local' -Type SRV
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

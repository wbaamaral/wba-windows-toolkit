function Test-LocalTcpListener {
    <#
    .SYNOPSIS
        Verifica se há listener TCP local em uma porta.

    .DESCRIPTION
        Consulta os listeners TCP ativos do sistema usando IPGlobalProperties e verifica se a porta
        especificada está em escuta. Não requer conexão de rede.

    .PARAMETER Port
        Porta TCP local a verificar. Valores permitidos: 1–65535.

    .EXAMPLE
        Test-LocalTcpListener -Port 3389

    .EXAMPLE
        Test-LocalTcpListener -Port 445
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateRange(1, 65535)]
        [int]$Port
    )

    $startedAt = Get-Date
    try {
        $listeners = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().GetActiveTcpListeners()
        $found = @($listeners | Where-Object { $_.Port -eq $Port })
        New-ConnectivityResult -TestName 'Listener TCP local' -Category 'Porta local' -Protocol 'TCP' -Direction 'Inbound' -Scope 'LAN' `
            -Target $env:COMPUTERNAME -Port $Port -Success ([bool]$found) -Status ($(if ($found) { 'Escutando' } else { 'Não encontrado' })) `
            -Classification ($(if ($found) { 'Success' } else { 'Failed' })) -Recommendation ($(if ($found) { 'Porta local em escuta.' } else { 'Nenhum processo escutando nesta porta.' })) `
            -StartedAt $startedAt -FinishedAt (Get-Date)
    }
    catch {
        New-ConnectivityResult -TestName 'Listener TCP local' -Category 'Porta local' -Protocol 'TCP' -Direction 'Inbound' -Scope 'LAN' `
            -Target $env:COMPUTERNAME -Port $Port -Success $false -Status 'Erro' -Classification 'Error' -ErrorMessage $_.Exception.Message `
            -Recommendation 'Não foi possível verificar listeners TCP locais.' -StartedAt $startedAt -FinishedAt (Get-Date)
    }
}

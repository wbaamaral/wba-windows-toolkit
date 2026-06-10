function Test-LocalUdpListener {
    <#
    .SYNOPSIS
        Verifica se há endpoint UDP local em uma porta.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateRange(1, 65535)]
        [int]$Port
    )

    $startedAt = Get-Date
    try {
        $listeners = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().GetActiveUdpListeners()
        $found = @($listeners | Where-Object { $_.Port -eq $Port })
        New-ConnectivityResult -TestName 'Listener UDP local' -Category 'Porta local' -Protocol 'UDP' -Direction 'Inbound' -Scope 'LAN' `
            -Target $env:COMPUTERNAME -Port $Port -Success ([bool]$found) -Status ($(if ($found) { 'Ativo' } else { 'Não encontrado' })) `
            -Classification ($(if ($found) { 'Success' } else { 'Failed' })) -Recommendation ($(if ($found) { 'Porta local ativa.' } else { 'Nenhum endpoint UDP local nesta porta.' })) `
            -StartedAt $startedAt -FinishedAt (Get-Date)
    }
    catch {
        New-ConnectivityResult -TestName 'Listener UDP local' -Category 'Porta local' -Protocol 'UDP' -Direction 'Inbound' -Scope 'LAN' `
            -Target $env:COMPUTERNAME -Port $Port -Success $false -Status 'Erro' -Classification 'Error' -ErrorMessage $_.Exception.Message `
            -Recommendation 'Não foi possível verificar listeners UDP locais.' -StartedAt $startedAt -FinishedAt (Get-Date)
    }
}

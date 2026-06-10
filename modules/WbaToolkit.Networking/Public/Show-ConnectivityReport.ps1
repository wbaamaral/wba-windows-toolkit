function Show-ConnectivityReport {
    <#
    .SYNOPSIS
        Exibe o relatório de conectividade em tela.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [object]$Report
    )

    Write-Host ''
    Write-Host ('=' * 79) -ForegroundColor Cyan
    Write-Host 'RELATORIO DE CONECTIVIDADE' -ForegroundColor Cyan
    Write-Host ('=' * 79) -ForegroundColor Cyan

    Write-Host (ConvertTo-ConsoleText ("Gerado em: {0}" -f $Report.FinishedAt.ToString('dd/MM/yyyy HH:mm:ss'))) -ForegroundColor DarkGray
    Write-Host (ConvertTo-ConsoleText ("Computador: {0}" -f $Report.Context.Hostname)) -ForegroundColor DarkGray
    Write-Host (ConvertTo-ConsoleText ("Usuario:    {0}" -f $Report.Context.Username)) -ForegroundColor DarkGray
    Write-Host (ConvertTo-ConsoleText ("Interface:  {0}" -f $Report.Context.InterfaceAlias)) -ForegroundColor DarkGray
    Write-Host (ConvertTo-ConsoleText ("IPv4:       {0}/{1}" -f $Report.Context.IPv4Address, $Report.Context.PrefixLength)) -ForegroundColor DarkGray
    Write-Host (ConvertTo-ConsoleText ("Gateway:    {0}" -f $Report.Context.Gateway)) -ForegroundColor DarkGray
    Write-Host (ConvertTo-ConsoleText ("DNS:        {0}" -f (@($Report.Context.DnsServers) -join ', '))) -ForegroundColor DarkGray

    Write-Host ''
    Write-Host 'RESUMO' -ForegroundColor Yellow
    Write-Host ("Total        : {0}" -f $Report.Summary.Total)
    Write-Host ("Sucesso      : {0}" -f $Report.Summary.Success) -ForegroundColor Green
    Write-Host ("Falhas       : {0}" -f $Report.Summary.Failed) -ForegroundColor Red
    Write-Host ("Avisos       : {0}" -f $Report.Summary.Warning) -ForegroundColor Yellow
    Write-Host ("Inconclusivo : {0}" -f $Report.Summary.Inconclusive) -ForegroundColor Cyan

    if ($Report.Blocked) {
        Write-Host ''
        Write-Host (ConvertTo-ConsoleText ("BLOQUEADO: {0}" -f $Report.BlockReason)) -ForegroundColor Red
    }

    Write-Host ''
    Write-Host 'RESULTADOS' -ForegroundColor Yellow
    foreach ($result in $Report.Results) {
        $label = "[{0}] {1}" -f $result.Classification, $result.TestName
        $color = switch ($result.Classification) {
            'Success' { 'Green' }
            'Warning' { 'Yellow' }
            'Inconclusive' { 'Cyan' }
            'Error' { 'Red' }
            default { 'White' }
        }

        Write-Host (ConvertTo-ConsoleText $label) -ForegroundColor $color
        $target = if ($result.Target) { $result.Target } else { '-' }
        Write-Host (ConvertTo-ConsoleText ("  Destino: {0}" -f $target)) -ForegroundColor DarkGray
        Write-Host (ConvertTo-ConsoleText ("  Status : {0}" -f $result.Status)) -ForegroundColor DarkGray
        if ($null -ne $result.Port) {
            Write-Host (ConvertTo-ConsoleText ("  Porta  : {0}" -f $result.Port)) -ForegroundColor DarkGray
        }
        if ($null -ne $result.LatencyMs) {
            Write-Host (ConvertTo-ConsoleText ("  Latencia: {0:N1} ms" -f $result.LatencyMs)) -ForegroundColor DarkGray
        }
        if ($result.ErrorMessage) {
            Write-Host (ConvertTo-ConsoleText ("  Erro   : {0}" -f $result.ErrorMessage)) -ForegroundColor DarkGray
        }
        if ($result.Recommendation) {
            Write-Host (ConvertTo-ConsoleText ("  Dica   : {0}" -f $result.Recommendation)) -ForegroundColor DarkGray
        }
        Write-Host ''
    }
}

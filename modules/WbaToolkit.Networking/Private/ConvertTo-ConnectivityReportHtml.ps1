function ConvertTo-ConnectivityReportHtml {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [object]$Report
    )

    $context = $Report.Context
    $summary  = $Report.Summary
    $results  = @($Report.Results)

    $cards = @(
        @{ Label = 'Total'; Value = $summary.Total; Color = 'slate' },
        @{ Label = 'Sucesso'; Value = $summary.Success; Color = 'green' },
        @{ Label = 'Falhas'; Value = $summary.Failed; Color = 'red' },
        @{ Label = 'Avisos'; Value = $summary.Warning; Color = 'amber' },
        @{ Label = 'Inconclusivo'; Value = $summary.Inconclusive; Color = 'blue' }
    )

    $cardHtml = foreach ($card in $cards) {
        $value = ConvertTo-HtmlSafe -Value $card.Value
        @"
        <div class="card card-$($card.Color)">
          <div class="card-label">$($card.Label)</div>
          <div class="card-value">$value</div>
        </div>
"@
    }

    $resultRows = foreach ($result in $results) {
        $target = if ($result.Target) { ConvertTo-HtmlSafe -Value $result.Target } else { '&mdash;' }
        $port   = if ($null -ne $result.Port) { [string]$result.Port } else { '&mdash;' }
        $lat    = if ($null -ne $result.LatencyMs) { '{0:N1} ms' -f $result.LatencyMs } else { '&mdash;' }
        $error  = if ($result.ErrorMessage) { ConvertTo-HtmlSafe -Value $result.ErrorMessage } else { '&mdash;' }
        $rec    = if ($result.Recommendation) { ConvertTo-HtmlSafe -Value $result.Recommendation } else { '&mdash;' }

        @"
        <tr>
          <td>$([string](ConvertTo-HtmlSafe -Value $result.TestName))</td>
          <td>$([string](ConvertTo-HtmlSafe -Value $result.Protocol))</td>
          <td>$([string](ConvertTo-HtmlSafe -Value $result.Classification))</td>
          <td>$target</td>
          <td>$port</td>
          <td>$lat</td>
          <td>$error</td>
          <td>$rec</td>
        </tr>
"@
    }

    $dnsServers = if ($context.DnsServers) { ($context.DnsServers -join ', ') } else { '&mdash;' }

    @"
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Relatório de Conectividade</title>
  <style>
    @page { size: A4; margin: 15mm; }
    :root {
      --bg: #f3f4f6;
      --panel: #ffffff;
      --border: #d1d5db;
      --text: #1f2937;
      --muted: #6b7280;
      --head: #0f172a;
      --slate: #e2e8f0;
      --green: #dcfce7;
      --red: #fee2e2;
      --amber: #fef3c7;
      --blue: #dbeafe;
    }
    body { font-family: Arial, Helvetica, sans-serif; background: var(--bg); color: var(--text); margin: 0; }
    .page { max-width: 1120px; margin: 24px auto; padding: 32px; background: var(--panel); box-shadow: 0 10px 25px rgba(15, 23, 42, 0.08); }
    .header { display: flex; justify-content: space-between; gap: 24px; border-bottom: 1px solid var(--border); padding-bottom: 16px; margin-bottom: 24px; }
    .title { font-size: 28px; font-weight: 700; color: var(--head); margin: 0; }
    .subtitle { color: var(--muted); font-size: 13px; margin-top: 4px; }
    .meta { text-align: right; font-size: 13px; color: var(--muted); }
    .meta strong { color: var(--text); display: block; font-size: 14px; }
    .cards { display: grid; grid-template-columns: repeat(5, minmax(0, 1fr)); gap: 12px; margin: 20px 0 28px; }
    .card { border: 1px solid var(--border); border-radius: 8px; padding: 14px 16px; background: #fff; }
    .card-label { color: var(--muted); font-size: 11px; text-transform: uppercase; letter-spacing: .05em; }
    .card-value { font-size: 26px; font-weight: 700; margin-top: 8px; color: var(--head); }
    .card-slate { background: var(--slate); }
    .card-green { background: var(--green); }
    .card-red { background: var(--red); }
    .card-amber { background: var(--amber); }
    .card-blue { background: var(--blue); }
    .section { border: 1px solid var(--border); border-radius: 8px; margin-top: 18px; overflow: hidden; break-inside: avoid; }
    .section-h { background: #f9fafb; border-bottom: 1px solid var(--border); padding: 12px 16px; font-weight: 700; }
    .section-b { padding: 16px; }
    .grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 16px; }
    .kv p { margin: 0 0 10px; }
    .kv .label { color: var(--muted); font-size: 12px; }
    .kv .value { font-weight: 600; color: var(--text); }
    table { width: 100%; border-collapse: collapse; font-size: 13px; }
    thead th { text-align: left; background: #f9fafb; border-bottom: 1px solid var(--border); padding: 10px 8px; font-size: 11px; text-transform: uppercase; color: var(--muted); }
    tbody td { border-bottom: 1px solid #eef2f7; padding: 10px 8px; vertical-align: top; }
    .footer { margin-top: 18px; padding-top: 12px; border-top: 1px solid var(--border); color: var(--muted); font-size: 11px; text-align: center; }
    .no-print { margin: 24px auto 0; max-width: 1120px; text-align: right; }
    .btn { background: #2563eb; color: white; border: 0; padding: 10px 14px; font-weight: 700; cursor: pointer; }
    @media print {
      body { background: white; }
      .page { box-shadow: none; margin: 0; padding: 0; max-width: 100%; }
      .no-print { display: none !important; }
      * { -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }
    }
  </style>
</head>
<body>
  <div class="no-print"><button class="btn" onclick="window.print()">Imprimir relatório</button></div>
  <div class="page">
    <div class="header">
      <div>
        <h1 class="title">Relatório de Conectividade</h1>
        <div class="subtitle">Gerado em: $([string](ConvertTo-HtmlSafe -Value $Report.FinishedAt.ToString('dd/MM/yyyy HH:mm:ss')))</div>
      </div>
      <div class="meta">
        <strong>$([string](ConvertTo-HtmlSafe -Value $context.Hostname))</strong>
        Usuário: $([string](ConvertTo-HtmlSafe -Value $context.Username))<br>
        Interface: $([string](ConvertTo-HtmlSafe -Value $context.InterfaceAlias))<br>
        IPv4: $([string](ConvertTo-HtmlSafe -Value $context.IPv4Address))/$([string](ConvertTo-HtmlSafe -Value $context.PrefixLength))<br>
        Gateway: $([string](ConvertTo-HtmlSafe -Value $context.Gateway))
      </div>
    </div>

    <div class="cards">
$($cardHtml -join "`n")
    </div>

    <div class="section">
      <div class="section-h">Contexto de rede</div>
      <div class="section-b">
        <div class="grid kv">
          <div>
            <p><span class="label">Hostname</span><br><span class="value">$([string](ConvertTo-HtmlSafe -Value $context.Hostname))</span></p>
            <p><span class="label">Usuário</span><br><span class="value">$([string](ConvertTo-HtmlSafe -Value $context.Username))</span></p>
            <p><span class="label">Interface</span><br><span class="value">$([string](ConvertTo-HtmlSafe -Value $context.InterfaceAlias))</span></p>
          </div>
          <div>
            <p><span class="label">IPv4</span><br><span class="value">$([string](ConvertTo-HtmlSafe -Value $context.IPv4Address))/$([string](ConvertTo-HtmlSafe -Value $context.PrefixLength))</span></p>
            <p><span class="label">Gateway</span><br><span class="value">$([string](ConvertTo-HtmlSafe -Value $context.Gateway))</span></p>
            <p><span class="label">DNS</span><br><span class="value">$dnsServers</span></p>
          </div>
        </div>
      </div>
    </div>

    <div class="section">
      <div class="section-h">Resultados</div>
      <div class="section-b" style="padding:0;">
        <table>
          <thead>
            <tr>
              <th>Teste</th>
              <th>Proto</th>
              <th>Status</th>
              <th>Destino</th>
              <th>Porta</th>
              <th>Latência</th>
              <th>Erro</th>
              <th>Recomendação</th>
            </tr>
          </thead>
          <tbody>
$($resultRows -join "`n")
          </tbody>
        </table>
      </div>
    </div>

    <div class="footer">
      Documento gerado internamente - $([string](ConvertTo-HtmlSafe -Value $Report.ReportId))
    </div>
  </div>
</body>
</html>
"@
}

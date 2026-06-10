function ConvertTo-StaticDocsHtml {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Title,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Body,

        [Parameter(Mandatory = $false)]
        [string]$RelativePrefix = ''
    )

    @"
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$([string](ConvertTo-HtmlSafe -Value $Title))</title>
  <style>
    @page { size: A4; margin: 15mm; }
    :root {
      --bg: #f3f4f6;
      --panel: #ffffff;
      --border: #d1d5db;
      --text: #1f2937;
      --muted: #6b7280;
      --head: #0f172a;
      --accent: #2563eb;
      --code: #f8fafc;
    }
    body { margin: 0; background: var(--bg); color: var(--text); font-family: Arial, Helvetica, sans-serif; }
    .page { max-width: 1120px; margin: 24px auto; padding: 32px; background: var(--panel); box-shadow: 0 10px 25px rgba(15,23,42,.08); }
    header { border-bottom: 1px solid var(--border); padding-bottom: 16px; margin-bottom: 24px; }
    h1 { margin: 0; color: var(--head); font-size: 28px; }
    h2 { margin-top: 28px; color: var(--head); font-size: 18px; border-bottom: 1px solid var(--border); padding-bottom: 8px; }
    h3 { margin-top: 18px; color: var(--head); font-size: 15px; }
    p, li { line-height: 1.5; }
    a { color: var(--accent); text-decoration: none; }
    a:hover { text-decoration: underline; }
    .muted { color: var(--muted); }
    .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 12px; }
    .card { border: 1px solid var(--border); border-radius: 8px; padding: 14px 16px; background: #fff; break-inside: avoid; }
    .card-title { font-weight: 700; color: var(--head); }
    .card-meta { margin-top: 6px; color: var(--muted); font-size: 13px; }
    code, pre { background: var(--code); border: 1px solid var(--border); border-radius: 6px; }
    code { padding: 1px 4px; }
    pre { padding: 12px; overflow-x: auto; white-space: pre-wrap; }
    table { width: 100%; border-collapse: collapse; margin-top: 12px; }
    th, td { border-bottom: 1px solid var(--border); padding: 8px; text-align: left; vertical-align: top; }
    th { background: #f9fafb; color: var(--muted); font-size: 12px; text-transform: uppercase; }
    nav { margin-top: 8px; color: var(--muted); font-size: 13px; }
    footer { margin-top: 28px; padding-top: 12px; border-top: 1px solid var(--border); color: var(--muted); font-size: 12px; text-align: center; }
    @media print {
      body { background: white; }
      .page { box-shadow: none; margin: 0; padding: 0; max-width: 100%; }
      * { -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }
    }
  </style>
</head>
<body>
  <div class="page">
    <header>
      <h1>$([string](ConvertTo-HtmlSafe -Value $Title))</h1>
      <nav><a href="${RelativePrefix}index.html">Indice principal</a></nav>
    </header>
$Body
    <footer>WBA Windows Toolkit - documentacao local estatica</footer>
  </div>
</body>
</html>
"@
}

#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Gera inventario completo de hardware e software em HTML e PDF.

.DESCRIPTION
    Coleta informacoes detalhadas do equipamento e do ambiente Windows e produz
    um relatorio HTML com design moderno salvo na pasta de saida escolhida.
    Opcionalmente converte o HTML para PDF usando o Chrome ou Edge em modo
    headless (sem abrir janela).

    Informacoes coletadas:
      - Sistema Operacional  : nome, versao, build, arquitetura, uptime
      - Processador          : modelo, nucleos, threads, velocidade, cache
      - Memoria RAM          : total, modulos (slot, tipo, velocidade, fabricante)
      - Placa-mae e BIOS     : fabricante, modelo, versao, data, numero de serie
      - Armazenamento        : discos fisicos e volumes logicos com barra de uso
      - Placa de video       : modelo, VRAM, driver, resolucao atual
      - Rede                 : MAC, IP, mascara, gateway, DNS e status DHCP
      - Monitores            : modelos detectados via PnP
      - Software instalado   : lista completa com versao, fabricante e data
      - Atualizacoes         : hotfixes instalados com data
      - Servicos             : todos os servicos com status Running

    Pre-requisitos:
      - PowerShell 5.1 ou superior
      - Execucao como Administrador (obrigatorio)
      - Para gerar PDF: Google Chrome ou Microsoft Edge instalado
        Chrome  : %ProgramFiles%\Google\Chrome\Application\chrome.exe
        Edge    : %ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe
        Se nenhum for encontrado, o script gera apenas o HTML e instrui o
        usuario a usar Ctrl+P > Salvar como PDF no navegador.

    Arquivos gerados em -OutputDir:
      Inventario-<COMPUTERNAME>-<YYYYMMDD-HHmmss>.html  Relatorio principal
      Inventario-<COMPUTERNAME>-<YYYYMMDD-HHmmss>.pdf   Versao em PDF (se disponivel)
      Inventario-<YYYYMMDD-HHmmss>.log                  Transcript de execucao

.PARAMETER OutputDir
    Caminho da pasta onde os arquivos HTML, PDF e log serao salvos.
    A pasta e criada automaticamente caso nao exista.
    Padrao: C:\TI

    Exemplos de valores validos:
      C:\TI
      D:\Relatorios\TI
      \\servidor\compartilhamento\inventarios

.PARAMETER NaoPDF
    Quando informado, o script gera apenas o relatorio HTML e nao tenta
    converter para PDF. Util quando:
      - Chrome e Edge nao estao instalados no equipamento
      - A conversao PDF nao e necessaria (envio por e-mail do HTML)
      - Execucao em ambientes sem interface grafica (Server Core)

.EXAMPLE
    .\Inventario-Hardware-Software.ps1

    Execucao padrao. Gera HTML e PDF em C:\TI com deteccao automatica
    de Chrome ou Edge para a conversao.

.EXAMPLE
    .\Inventario-Hardware-Software.ps1 -OutputDir "D:\Relatorios"

    Gera os arquivos na pasta D:\Relatorios (criada automaticamente
    se nao existir).

.EXAMPLE
    .\Inventario-Hardware-Software.ps1 -NaoPDF

    Gera apenas o HTML em C:\TI, sem tentativa de conversao para PDF.

.EXAMPLE
    .\Inventario-Hardware-Software.ps1 -OutputDir "\\srv-files\TI\Inventarios" -NaoPDF

    Salva o relatorio HTML diretamente em um compartilhamento de rede,
    sem gerar PDF.

.NOTES
    Autor  : WBA Windows Toolkit
    Versao : 1.0
    Requer : PowerShell 5.1+, Administrador local
    PDF    : Google Chrome 60+ ou Microsoft Edge 80+ (headless)

    Em caso de erro na conversao PDF, verifique:
      1. Se o navegador esta instalado no caminho padrao
      2. Se o usuario tem permissao de escrita em -OutputDir
      3. Consulte o arquivo .log gerado para detalhes completos

.LINK
    https://codeberg.org/wbaamaral/wba-windows-toolkit
#>

[CmdletBinding()]
param(
    [string]$OutputDir = 'C:\TI',
    [switch]$NaoPDF
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Continue'

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding']    = 'utf8'
$PSDefaultParameterValues['Set-Content:Encoding'] = 'utf8'
$PSDefaultParameterValues['Add-Content:Encoding'] = 'utf8'
chcp 65001 | Out-Null

$ToolkitRoot = Split-Path -Parent $PSScriptRoot
$ToolkitModulePath = Join-Path $ToolkitRoot 'modules/WbaToolkit.Core/WbaToolkit.Core.psd1'
Import-Module $ToolkitModulePath -Force -ErrorAction Stop

# ---------------------------------------------------------------------------
# Helpers visuais
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# Helpers de formatacao e HTML
# ---------------------------------------------------------------------------
function Format-RegDate {
    param([string]$d)
    if ($d -match '^(\d{4})(\d{2})(\d{2})$') { return "$($Matches[3])/$($Matches[2])/$($Matches[1])" }
    return ConvertTo-HtmlSafe $d
}

function Get-BarClass {
    param([double]$Pct)
    if ($Pct -ge 85) { return 'bar-danger' }
    if ($Pct -ge 70) { return 'bar-warn'   }
    return 'bar-ok'
}

function Get-PctBadge {
    param([double]$Pct)
    if ($Pct -ge 85) { return "badge badge-red"    }
    if ($Pct -ge 70) { return "badge badge-yellow" }
    return "badge badge-green"
}

function New-KvRow {
    param([string]$Key, [string]$Val)
    return "<tr><th>$Key</th><td>$Val</td></tr>"
}

# ---------------------------------------------------------------------------
# Preparacao de paths
# ---------------------------------------------------------------------------
$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$DataHora  = Get-Date -Format 'dd/MM/yyyy HH:mm:ss'
$DataCurta = Get-Date -Format 'dd/MM/yyyy'

if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }

$HtmlFile = Join-Path $OutputDir "Inventario-$env:COMPUTERNAME-$Timestamp.html"
$PdfFile  = Join-Path $OutputDir "Inventario-$env:COMPUTERNAME-$Timestamp.pdf"
$LogFile  = Join-Path $OutputDir "Inventario-$Timestamp.log"

Start-Transcript -Path $LogFile -Force | Out-Null

# ---------------------------------------------------------------------------
# COLETA DE DADOS
# ---------------------------------------------------------------------------
Write-Title 'INVENTARIO DE HARDWARE E SOFTWARE'
Write-Info  "Computador : $env:COMPUTERNAME"
Write-Info  "Data/Hora  : $DataHora"
Write-Info  "Destino    : $OutputDir"

Write-Info 'Coletando sistema operacional...'
$os  = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
$cs  = Get-CimInstance Win32_ComputerSystem  -ErrorAction SilentlyContinue

Write-Info 'Coletando hardware...'
$bios    = Get-CimInstance Win32_BIOS             -ErrorAction SilentlyContinue
$mb      = Get-CimInstance Win32_BaseBoard        -ErrorAction SilentlyContinue
$cpus    = @(Get-CimInstance Win32_Processor      -ErrorAction SilentlyContinue)
$ramMods = @(Get-CimInstance Win32_PhysicalMemory -ErrorAction SilentlyContinue)
$phyDisk = @(Get-CimInstance Win32_DiskDrive      -ErrorAction SilentlyContinue)
$logDisk = @(Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction SilentlyContinue)
$gpus    = @(Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue)
$nets    = @(Get-CimInstance Win32_NetworkAdapterConfiguration -Filter "IPEnabled=True" -ErrorAction SilentlyContinue)
$mons    = @(Get-PnpDevice -Class Monitor -Status OK -ErrorAction SilentlyContinue)

Write-Info 'Coletando software instalado...'
$regPaths = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
)
$software = $regPaths | ForEach-Object {
    Get-ItemProperty $_ -ErrorAction SilentlyContinue
} | Where-Object { $_.PSObject.Properties['DisplayName'] -and -not [string]::IsNullOrWhiteSpace($_.DisplayName) } |
    Sort-Object DisplayName |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate -Unique

Write-Info 'Coletando atualizacoes e servicos...'
$hotfixes = @(Get-HotFix -ErrorAction SilentlyContinue | Sort-Object InstalledOn -Descending -ErrorAction SilentlyContinue)
$services = @(Get-Service -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Running' } | Sort-Object DisplayName)

# Calculos derivados
$totalRamGB  = if ($cs) { [math]::Round($cs.TotalPhysicalMemory / 1GB, 2) } else { 0 }
$uptime      = if ($os) { (Get-Date) - $os.LastBootUpTime } else { $null }
$uptimeStr   = if ($uptime) { "{0}d {1}h {2}m" -f $uptime.Days, $uptime.Hours, $uptime.Minutes } else { '&mdash;' }
$cpu1        = if ($cpus.Count -gt 0) { $cpus[0] } else { $null }

Write-Ok "Coleta concluida — Software: $($software.Count) | Hotfixes: $($hotfixes.Count) | Servicos: $($services.Count)"

# ---------------------------------------------------------------------------
# GERACAO DO HTML
# ---------------------------------------------------------------------------
Write-Info 'Gerando relatorio HTML...'

# --- CSS -------------------------------------------------------------------
$css = @'
<style>
:root {
    --primary:    #1e3a5f;
    --primary-lt: #2d5986;
    --accent:     #2563eb;
    --success:    #16a34a;
    --warning:    #d97706;
    --danger:     #dc2626;
    --bg:         #f0f4f8;
    --surface:    #ffffff;
    --border:     #e2e8f0;
    --text:       #1e293b;
    --muted:      #64748b;
    --radius:     8px;
}
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
html { scroll-behavior: smooth; }
body { font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
       background: var(--bg); color: var(--text); font-size: 14px; line-height: 1.5; }

/* ---- Header ---- */
header {
    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-lt) 100%);
    color: white; padding: 2rem 2.5rem;
    display: flex; justify-content: space-between; align-items: flex-end;
    flex-wrap: wrap; gap: 1rem;
}
header .title-block h1 { font-size: 1.6rem; font-weight: 700; letter-spacing: -0.02em; }
header .title-block p  { opacity: .75; font-size: .85rem; margin-top: .25rem; }
header .meta-block     { text-align: right; font-size: .8rem; opacity: .8; line-height: 1.8; }

/* ---- Nav ---- */
nav {
    background: var(--surface); border-bottom: 2px solid var(--accent);
    position: sticky; top: 0; z-index: 100;
    box-shadow: 0 2px 8px rgba(0,0,0,.08);
    overflow-x: auto; white-space: nowrap;
}
nav a {
    display: inline-block; padding: .65rem 1rem;
    color: var(--primary); text-decoration: none;
    font-size: .8rem; font-weight: 600;
    border-bottom: 2px solid transparent; transition: color .15s, border-color .15s;
}
nav a:hover { color: var(--accent); border-color: var(--accent); }

/* ---- Layout ---- */
main { max-width: 1400px; margin: 1.5rem auto; padding: 0 1.5rem; }

/* ---- Cards de resumo ---- */
.cards {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(190px, 1fr));
    gap: 1rem; margin-bottom: 1.5rem;
}
.card {
    background: var(--surface); border-radius: var(--radius);
    padding: 1.1rem 1.25rem;
    box-shadow: 0 1px 6px rgba(0,0,0,.07);
    border-left: 4px solid var(--accent);
    transition: box-shadow .15s;
}
.card:hover { box-shadow: 0 4px 14px rgba(0,0,0,.12); }
.card-icon  { font-size: 1.4rem; margin-bottom: .4rem; }
.card-label { font-size: .7rem; text-transform: uppercase;
              letter-spacing: .06em; color: var(--muted); font-weight: 600; }
.card-value { font-size: 1.05rem; font-weight: 700; color: var(--primary); margin-top: .2rem; }
.card-sub   { font-size: .75rem; color: var(--muted); margin-top: .15rem; }

/* ---- Secoes ---- */
.section {
    background: var(--surface); border-radius: var(--radius);
    box-shadow: 0 1px 6px rgba(0,0,0,.07);
    margin-bottom: 1.25rem; overflow: hidden;
}
.section-hdr {
    background: var(--primary); color: white;
    padding: .75rem 1.5rem; font-size: .9rem; font-weight: 700;
    display: flex; align-items: center; gap: .5rem;
}
.section-body { padding: 1.25rem 1.5rem; }

/* ---- Sub-titulo ---- */
.sub { font-weight: 700; color: var(--primary); font-size: .85rem;
       border-bottom: 1px solid var(--border); padding-bottom: .35rem;
       margin: 1.1rem 0 .6rem; }
.sub:first-child { margin-top: 0; }

/* ---- Tabelas de kv (propriedades) ---- */
.kv-table { width: 100%; border-collapse: collapse; }
.kv-table th {
    width: 220px; font-weight: 600; font-size: .8rem;
    color: var(--muted); text-align: left; padding: .4rem .75rem .4rem 0;
    border-bottom: 1px solid var(--border); vertical-align: top;
}
.kv-table td {
    font-size: .85rem; padding: .4rem 0;
    border-bottom: 1px solid var(--border);
}
.kv-table tr:last-child th, .kv-table tr:last-child td { border-bottom: none; }

/* ---- Grid de kv em 2 colunas ---- */
.kv-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 0 2rem; }

/* ---- Tabelas de dados ---- */
.data-table { width: 100%; border-collapse: collapse; font-size: .82rem; }
.data-table thead th {
    background: #f8fafc; color: var(--primary); font-weight: 700;
    padding: .55rem 1rem; text-align: left;
    border-bottom: 2px solid var(--border); white-space: nowrap;
}
.data-table tbody td { padding: .5rem 1rem; border-bottom: 1px solid #f1f5f9; }
.data-table tbody tr:last-child td { border-bottom: none; }
.data-table tbody tr:hover td { background: #f8faff; }

/* ---- Scroll container p/ tabelas longas ---- */
.scroll-wrap { overflow-x: auto; }
.tall-wrap   { max-height: 420px; overflow-y: auto; }

/* ---- Barra de disco ---- */
.disk-bar { background: #e2e8f0; border-radius: 4px; height: 8px; min-width: 80px; overflow: hidden; }
.disk-fill { height: 100%; border-radius: 4px; transition: width .3s; }
.bar-ok     { background: var(--success); }
.bar-warn   { background: var(--warning); }
.bar-danger { background: var(--danger);  }

/* ---- Badges ---- */
.badge {
    display: inline-block; padding: .15em .55em;
    border-radius: 4px; font-size: .72rem; font-weight: 700; white-space: nowrap;
}
.badge-green  { background: #dcfce7; color: #15803d; }
.badge-yellow { background: #fef9c3; color: #92400e; }
.badge-red    { background: #fee2e2; color: #991b1b; }
.badge-blue   { background: #dbeafe; color: #1e40af; }
.badge-gray   { background: #f1f5f9; color: #475569; }

/* ---- Filtro de software ---- */
.filter-wrap { margin-bottom: .75rem; display: flex; gap: .5rem; align-items: center; }
.filter-input {
    flex: 1; max-width: 400px; padding: .45rem .75rem;
    border: 1px solid var(--border); border-radius: var(--radius);
    font-size: .85rem; color: var(--text);
    outline: none; transition: border-color .15s;
}
.filter-input:focus { border-color: var(--accent); }
.filter-count { font-size: .78rem; color: var(--muted); }

/* ---- Utilitarios ---- */
.muted { color: var(--muted); }
.mono  { font-family: 'Consolas', 'Cascadia Code', monospace; font-size: .8rem; }
.nowrap { white-space: nowrap; }
.right  { text-align: right; }

/* ---- Footer ---- */
footer { text-align: center; color: var(--muted);
         font-size: .78rem; padding: 1.5rem; margin-top: .5rem; }

/* ---- Print / PDF ---- */
@page { size: A4; margin: 1.2cm 1.5cm; }
@media print {
    body  { background: white; font-size: 11px; }
    nav   { display: none; }
    .section { box-shadow: none; border: 1px solid var(--border);
               break-inside: avoid; margin-bottom: .75rem; }
    .tall-wrap { max-height: none; overflow: visible; }
    .filter-wrap { display: none; }
    header { print-color-adjust: exact; -webkit-print-color-adjust: exact; }
    .section-hdr { print-color-adjust: exact; -webkit-print-color-adjust: exact; }
}
</style>
'@

# --- Header + nav ----------------------------------------------------------
$manufacturerModel = "$(ConvertTo-HtmlSafe $cs.Manufacturer) $(ConvertTo-HtmlSafe $cs.Model)"
$domainInfo = if ($cs.PartOfDomain) { "Dominio: $(ConvertTo-HtmlSafe $cs.Domain)" } else { "Grupo de trabalho: $(ConvertTo-HtmlSafe $cs.Workgroup)" }

$htmlTop = @"
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Inventario — $env:COMPUTERNAME — $DataCurta</title>
$css
</head>
<body>
<header>
  <div class="title-block">
    <h1>&#128187; Inventario de TI</h1>
    <p>$manufacturerModel</p>
  </div>
  <div class="meta-block">
    <div><strong>$env:COMPUTERNAME</strong></div>
    <div>$domainInfo</div>
    <div>Gerado em: $DataHora</div>
    <div>Usuario: $(ConvertTo-HtmlSafe $env:USERNAME)</div>
  </div>
</header>
<nav>
  <a href="#so">&#128196; Sistema</a>
  <a href="#cpu">&#9881; Processador</a>
  <a href="#ram">&#128190; Memoria</a>
  <a href="#placa-mae">&#128268; Placa-mae</a>
  <a href="#storage">&#128009; Disco</a>
  <a href="#gpu">&#127918; Video</a>
  <a href="#rede">&#127760; Rede</a>
  <a href="#monitores">&#128247; Monitores</a>
  <a href="#software">&#128230; Software</a>
  <a href="#hotfixes">&#128274; Atualizacoes</a>
  <a href="#servicos">&#9881; Servicos</a>
</nav>
<main>
"@

# --- Cards de resumo -------------------------------------------------------
$cpuCard   = if ($cpu1) { ConvertTo-HtmlSafe $cpu1.Name } else { '&mdash;' }
$cpuSub    = if ($cpu1) { "$(ConvertTo-HtmlSafe $cpu1.NumberOfCores) nucleos / $(ConvertTo-HtmlSafe $cpu1.NumberOfLogicalProcessors) threads" } else { '' }
$osCard    = if ($os) { ConvertTo-HtmlSafe ($os.Caption -replace 'Microsoft ', '') } else { '&mdash;' }
$osSub     = if ($os) { "Build $(ConvertTo-HtmlSafe $os.BuildNumber)" } else { '' }
$ramCard   = "${totalRamGB} GB"
$ramSub    = "$($ramMods.Count) modulo(s)"
$diskCard  = if ($logDisk.Count -gt 0) { Format-FileSize ($logDisk | Measure-Object -Property Size -Sum).Sum } else { '&mdash;' }
$bootCard  = if ($os) { $os.LastBootUpTime.ToString('dd/MM/yyyy HH:mm') } else { '&mdash;' }

$htmlCards = @"
<div class="cards">
  <div class="card">
    <div class="card-icon">&#128187;</div>
    <div class="card-label">Computador</div>
    <div class="card-value">$env:COMPUTERNAME</div>
    <div class="card-sub">$(ConvertTo-HtmlSafe $cs.Model)</div>
  </div>
  <div class="card">
    <div class="card-icon">&#128196;</div>
    <div class="card-label">Sistema Operacional</div>
    <div class="card-value">$osCard</div>
    <div class="card-sub">$osSub</div>
  </div>
  <div class="card">
    <div class="card-icon">&#9881;</div>
    <div class="card-label">Processador</div>
    <div class="card-value">$cpuCard</div>
    <div class="card-sub">$cpuSub</div>
  </div>
  <div class="card">
    <div class="card-icon">&#128190;</div>
    <div class="card-label">Memoria RAM</div>
    <div class="card-value">$ramCard</div>
    <div class="card-sub">$ramSub</div>
  </div>
  <div class="card">
    <div class="card-icon">&#128009;</div>
    <div class="card-label">Armazenamento Total</div>
    <div class="card-value">$diskCard</div>
    <div class="card-sub">$($logDisk.Count) particao(oes)</div>
  </div>
  <div class="card">
    <div class="card-icon">&#128336;</div>
    <div class="card-label">Ultimo Boot</div>
    <div class="card-value">$bootCard</div>
    <div class="card-sub">$uptimeStr de uptime</div>
  </div>
  <div class="card">
    <div class="card-icon">&#128230;</div>
    <div class="card-label">Software Instalado</div>
    <div class="card-value">$($software.Count)</div>
    <div class="card-sub">$($hotfixes.Count) atualizacoes</div>
  </div>
  <div class="card">
    <div class="card-icon">&#9881;</div>
    <div class="card-label">Servicos Ativos</div>
    <div class="card-value">$($services.Count)</div>
    <div class="card-sub">Status: Running</div>
  </div>
</div>
"@

# --- Sistema Operacional ---------------------------------------------------
$archStr    = ConvertTo-HtmlSafe $os.OSArchitecture
$serialOS   = ConvertTo-HtmlSafe $os.SerialNumber
$installDt  = if ($os) { $os.InstallDate.ToString('dd/MM/yyyy') } else { '&mdash;' }
$freeMemGB  = if ($os) { [math]::Round($os.FreePhysicalMemory / 1MB, 2) } else { 0 }
$usedMemGB  = [math]::Round($totalRamGB - $freeMemGB, 2)

$htmlSO = @"
<div class="section" id="so">
  <div class="section-hdr">&#128196; Sistema Operacional</div>
  <div class="section-body">
    <div class="kv-grid">
      <table class="kv-table">
        $(New-KvRow 'Nome' (ConvertTo-HtmlSafe $os.Caption))
        $(New-KvRow 'Versao' (ConvertTo-HtmlSafe $os.Version))
        $(New-KvRow 'Build' (ConvertTo-HtmlSafe $os.BuildNumber))
        $(New-KvRow 'Arquitetura' $archStr)
        $(New-KvRow 'Idioma' (ConvertTo-HtmlSafe $os.MUILanguages))
        $(New-KvRow 'Instalado em' $installDt)
      </table>
      <table class="kv-table">
        $(New-KvRow 'Ultimo boot' $(if ($os) { $os.LastBootUpTime.ToString('dd/MM/yyyy HH:mm:ss') } else { '&mdash;' }))
        $(New-KvRow 'Uptime' $uptimeStr)
        $(New-KvRow 'Diretorio Windows' (ConvertTo-HtmlSafe $os.WindowsDirectory))
        $(New-KvRow 'Total RAM (OS)' "$totalRamGB GB")
        $(New-KvRow 'RAM em uso' "$usedMemGB GB / $totalRamGB GB")
        $(New-KvRow 'Nr. de serie OS' $serialOS)
      </table>
    </div>
  </div>
</div>
"@

# --- Processador -----------------------------------------------------------
$cpuRows = ($cpus | ForEach-Object {
    $speedGHz = [math]::Round($_.MaxClockSpeed / 1000, 2)
    $l2  = if ($_.L2CacheSize)  { "$($_.L2CacheSize) KB"  } else { '&mdash;' }
    $l3  = if ($_.L3CacheSize)  { "$($_.L3CacheSize) KB"  } else { '&mdash;' }
    @"
    <div class="sub">$(ConvertTo-HtmlSafe $_.Name)</div>
    <table class="kv-table">
      $(New-KvRow 'Fabricante'           (ConvertTo-HtmlSafe $_.Manufacturer))
      $(New-KvRow 'Socket'               (ConvertTo-HtmlSafe $_.SocketDesignation))
      $(New-KvRow 'Nucleos fisicos'      (ConvertTo-HtmlSafe $_.NumberOfCores))
      $(New-KvRow 'Processadores logicos'(ConvertTo-HtmlSafe $_.NumberOfLogicalProcessors))
      $(New-KvRow 'Velocidade maxima'    "$speedGHz GHz")
      $(New-KvRow 'Cache L2'             $l2)
      $(New-KvRow 'Cache L3'             $l3)
    </table>
"@
}) -join ''

$htmlCPU = @"
<div class="section" id="cpu">
  <div class="section-hdr">&#9881; Processador(es)</div>
  <div class="section-body">$cpuRows</div>
</div>
"@

# --- Memoria RAM -----------------------------------------------------------
$ramTypeMap = @{ 0='Desconhecido'; 20='DDR'; 21='DDR2'; 22='DDR2 FB-DIMM'; 24='DDR3'; 26='DDR4'; 34='DDR5' }
$ramRows = ($ramMods | ForEach-Object {
    $tipo = if ($ramTypeMap.ContainsKey([int]$_.SMBIOSMemoryType)) { $ramTypeMap[[int]$_.SMBIOSMemoryType] } else { "Tipo $($_.SMBIOSMemoryType)" }
    $cap  = if ($_.Capacity) { Format-FileSize ([long]$_.Capacity) } else { '&mdash;' }
    "<tr><td class='mono'>$(ConvertTo-HtmlSafe $_.DeviceLocator)</td><td>$(ConvertTo-HtmlSafe $_.Manufacturer)</td><td><strong>$cap</strong></td><td>$(ConvertTo-HtmlSafe $_.Speed) MHz</td><td><span class='badge badge-blue'>$tipo</span></td><td class='mono'>$(ConvertTo-HtmlSafe $_.PartNumber)</td></tr>"
}) -join ''

$htmlRAM = @"
<div class="section" id="ram">
  <div class="section-hdr">&#128190; Memoria RAM &mdash; Total: ${totalRamGB} GB</div>
  <div class="section-body">
    <div class="scroll-wrap">
      <table class="data-table">
        <thead><tr><th>Slot</th><th>Fabricante</th><th>Capacidade</th><th>Velocidade</th><th>Tipo</th><th>Numero de serie</th></tr></thead>
        <tbody>$ramRows</tbody>
      </table>
    </div>
  </div>
</div>
"@

# --- Placa-mae / BIOS ------------------------------------------------------
$biosDate = if ($bios -and $bios.ReleaseDate) { $bios.ReleaseDate.ToString('dd/MM/yyyy') } else { '&mdash;' }

$htmlMB = @"
<div class="section" id="placa-mae">
  <div class="section-hdr">&#128268; Placa-mae e BIOS</div>
  <div class="section-body">
    <div class="kv-grid">
      <div>
        <div class="sub">Placa-mae</div>
        <table class="kv-table">
          $(New-KvRow 'Fabricante'    (ConvertTo-HtmlSafe $mb.Manufacturer))
          $(New-KvRow 'Produto'       (ConvertTo-HtmlSafe $mb.Product))
          $(New-KvRow 'Versao'        (ConvertTo-HtmlSafe $mb.Version))
          $(New-KvRow 'Nr. de serie'  (ConvertTo-HtmlSafe $mb.SerialNumber))
        </table>
      </div>
      <div>
        <div class="sub">BIOS</div>
        <table class="kv-table">
          $(New-KvRow 'Fabricante'     (ConvertTo-HtmlSafe $bios.Manufacturer))
          $(New-KvRow 'Versao'         (ConvertTo-HtmlSafe $bios.SMBIOSBIOSVersion))
          $(New-KvRow 'Data de lancamento' $biosDate)
          $(New-KvRow 'Nr. de serie'   (ConvertTo-HtmlSafe $bios.SerialNumber))
        </table>
      </div>
    </div>
  </div>
</div>
"@

# --- Armazenamento ---------------------------------------------------------
$phyRows = ($phyDisk | ForEach-Object {
    $sz = if ($_.Size) { Format-FileSize ([long]$_.Size) } else { '&mdash;' }
    "<tr><td>$(ConvertTo-HtmlSafe $_.Model)</td><td><span class='badge badge-blue'>$(ConvertTo-HtmlSafe $_.InterfaceType)</span></td><td class='nowrap'><strong>$sz</strong></td><td>$(ConvertTo-HtmlSafe $_.Partitions)</td><td class='mono'>$(ConvertTo-HtmlSafe $_.SerialNumber)</td></tr>"
}) -join ''

$logRows = ($logDisk | ForEach-Object {
    $total = [long]$_.Size
    $free  = [long]$_.FreeSpace
    $used  = $total - $free
    $pct   = if ($total -gt 0) { [math]::Round(($used / $total) * 100, 1) } else { 0 }
    $barClass   = Get-BarClass $pct
    $badgeClass = Get-PctBadge $pct
    @"
<tr>
  <td><strong>$($_.DeviceID)</strong></td>
  <td>$(ConvertTo-HtmlSafe $_.VolumeName)</td>
  <td>$(ConvertTo-HtmlSafe $_.FileSystem)</td>
  <td class='nowrap'>$(Format-FileSize $total)</td>
  <td class='nowrap'>$(Format-FileSize $free)</td>
  <td>
    <div style="display:flex;align-items:center;gap:.5rem;">
      <div class="disk-bar" style="width:100px"><div class="disk-fill $barClass" style="width:${pct}%"></div></div>
      <span class="$badgeClass">${pct}%</span>
    </div>
  </td>
</tr>
"@
}) -join ''

$htmlStorage = @"
<div class="section" id="storage">
  <div class="section-hdr">&#128009; Armazenamento</div>
  <div class="section-body">
    <div class="sub">Discos Fisicos</div>
    <div class="scroll-wrap">
      <table class="data-table">
        <thead><tr><th>Modelo</th><th>Interface</th><th>Capacidade</th><th>Particoes</th><th>Nr. serie</th></tr></thead>
        <tbody>$phyRows</tbody>
      </table>
    </div>
    <div class="sub">Volumes / Particoes</div>
    <div class="scroll-wrap">
      <table class="data-table">
        <thead><tr><th>Drive</th><th>Rotulo</th><th>Sistema de arquivos</th><th>Total</th><th>Livre</th><th>Uso</th></tr></thead>
        <tbody>$logRows</tbody>
      </table>
    </div>
  </div>
</div>
"@

# --- GPU -------------------------------------------------------------------
$gpuRows = ($gpus | ForEach-Object {
    $vram = if ($_.AdapterRAM -and [long]$_.AdapterRAM -gt 0) { Format-FileSize ([long]$_.AdapterRAM) } else { '&mdash;' }
    $res  = if ($_.CurrentHorizontalResolution) { "$($_.CurrentHorizontalResolution) x $($_.CurrentVerticalResolution)" } else { '&mdash;' }
    @"
    <div class="sub">$(ConvertTo-HtmlSafe $_.Name)</div>
    <table class="kv-table">
      $(New-KvRow 'VRAM'             $vram)
      $(New-KvRow 'Resolucao atual'  $res)
      $(New-KvRow 'Driver'           (ConvertTo-HtmlSafe $_.DriverVersion))
      $(New-KvRow 'Status'           (ConvertTo-HtmlSafe $_.Status))
    </table>
"@
}) -join ''

$htmlGPU = @"
<div class="section" id="gpu">
  <div class="section-hdr">&#127918; Placa(s) de Video</div>
  <div class="section-body">$gpuRows</div>
</div>
"@

# --- Rede ------------------------------------------------------------------
$netRows = ($nets | ForEach-Object {
    $ips   = if ($_.IPAddress)       { ($_.IPAddress   | Where-Object { $_ -match '\.' }) -join ', ' } else { '&mdash;' }
    $masks = if ($_.IPSubnet)        { ($_.IPSubnet     | Where-Object { $_ -match '\.' }) -join ', ' } else { '&mdash;' }
    $gws   = if ($_.DefaultIPGateway){ $_.DefaultIPGateway -join ', ' } else { '&mdash;' }
    $dns   = if ($_.DNSServerSearchOrder){ $_.DNSServerSearchOrder -join ', ' } else { '&mdash;' }
    $dhcp  = if ($_.DHCPEnabled) { "<span class='badge badge-green'>Sim</span>" } else { "<span class='badge badge-gray'>Nao</span>" }
    @"
    <div class="sub">$(ConvertTo-HtmlSafe $_.Description)</div>
    <table class="kv-table">
      $(New-KvRow 'MAC'          "<span class='mono'>$(ConvertTo-HtmlSafe $_.MACAddress)</span>")
      $(New-KvRow 'IP(s)'        "<span class='mono'>$ips</span>")
      $(New-KvRow 'Mascara(s)'   "<span class='mono'>$masks</span>")
      $(New-KvRow 'Gateway'      "<span class='mono'>$gws</span>")
      $(New-KvRow 'DNS'          "<span class='mono'>$dns</span>")
      $(New-KvRow 'DHCP'         $dhcp)
    </table>
"@
}) -join ''

$htmlNet = @"
<div class="section" id="rede">
  <div class="section-hdr">&#127760; Rede</div>
  <div class="section-body">$netRows</div>
</div>
"@

# --- Monitores -------------------------------------------------------------
if ($mons.Count -gt 0) {
    $monRows = ($mons | ForEach-Object {
        "<tr><td>$(ConvertTo-HtmlSafe $_.FriendlyName)</td><td><span class='badge badge-blue'>$(ConvertTo-HtmlSafe $_.Class)</span></td><td class='mono'>$(ConvertTo-HtmlSafe $_.InstanceId)</td></tr>"
    }) -join ''
    $monBody = @"
    <div class="scroll-wrap">
      <table class="data-table">
        <thead><tr><th>Modelo</th><th>Classe</th><th>ID</th></tr></thead>
        <tbody>$monRows</tbody>
      </table>
    </div>
"@
} else {
    $monBody = '<p class="muted">Nenhum monitor detectado via PnP.</p>'
}

$htmlMonitors = @"
<div class="section" id="monitores">
  <div class="section-hdr">&#128247; Monitores</div>
  <div class="section-body">$monBody</div>
</div>
"@

# --- Software instalado ----------------------------------------------------
$swRows = ($software | ForEach-Object {
    $dt = Format-RegDate $_.InstallDate
    "<tr><td>$(ConvertTo-HtmlSafe $_.DisplayName)</td><td>$(ConvertTo-HtmlSafe $_.DisplayVersion)</td><td>$(ConvertTo-HtmlSafe $_.Publisher)</td><td class='nowrap'>$dt</td></tr>"
}) -join ''

$htmlSoftware = @"
<div class="section" id="software">
  <div class="section-hdr">&#128230; Software Instalado &mdash; $($software.Count) programas</div>
  <div class="section-body">
    <div class="filter-wrap">
      <input class="filter-input" id="swFilter" type="text" placeholder="Filtrar por nome, versao ou fabricante..." oninput="filtrarSw()">
      <span class="filter-count" id="swCount">$($software.Count) itens</span>
    </div>
    <div class="scroll-wrap tall-wrap">
      <table class="data-table" id="swTable">
        <thead><tr><th>Nome</th><th>Versao</th><th>Fabricante</th><th>Instalado em</th></tr></thead>
        <tbody>$swRows</tbody>
      </table>
    </div>
  </div>
</div>
"@

# --- Hotfixes --------------------------------------------------------------
$hfRows = ($hotfixes | ForEach-Object {
    $dt = if ($_.InstalledOn) { $_.InstalledOn.ToString('dd/MM/yyyy') } else { '&mdash;' }
    "<tr><td><span class='badge badge-blue mono'>$(ConvertTo-HtmlSafe $_.HotFixID)</span></td><td>$(ConvertTo-HtmlSafe $_.Description)</td><td>$(ConvertTo-HtmlSafe $_.InstalledBy)</td><td class='nowrap'>$dt</td></tr>"
}) -join ''

$htmlHotfixes = @"
<div class="section" id="hotfixes">
  <div class="section-hdr">&#128274; Atualizacoes / Hotfixes &mdash; $($hotfixes.Count) instalados</div>
  <div class="section-body">
    <div class="scroll-wrap tall-wrap">
      <table class="data-table">
        <thead><tr><th>ID</th><th>Descricao</th><th>Instalado por</th><th>Data</th></tr></thead>
        <tbody>$hfRows</tbody>
      </table>
    </div>
  </div>
</div>
"@

# --- Servicos em execucao --------------------------------------------------
$svcRows = ($services | ForEach-Object {
    $startType = ConvertTo-HtmlSafe $_.StartType
    "<tr><td class='mono'>$(ConvertTo-HtmlSafe $_.Name)</td><td>$(ConvertTo-HtmlSafe $_.DisplayName)</td><td><span class='badge badge-green'>Running</span></td><td><span class='badge badge-gray'>$startType</span></td></tr>"
}) -join ''

$htmlServices = @"
<div class="section" id="servicos">
  <div class="section-hdr">&#9881; Servicos em Execucao &mdash; $($services.Count) ativos</div>
  <div class="section-body">
    <div class="scroll-wrap tall-wrap">
      <table class="data-table">
        <thead><tr><th>Nome do servico</th><th>Nome de exibicao</th><th>Status</th><th>Inicializacao</th></tr></thead>
        <tbody>$svcRows</tbody>
      </table>
    </div>
  </div>
</div>
"@

# --- Footer + JS -----------------------------------------------------------
$htmlBottom = @"
</main>
<footer>
  Relatorio gerado em $DataHora &nbsp;|&nbsp; $env:COMPUTERNAME &nbsp;|&nbsp; Usuario: $env:USERNAME
</footer>
<script>
function filtrarSw() {
    var filtro = document.getElementById('swFilter').value.toLowerCase();
    var linhas = document.getElementById('swTable').getElementsByTagName('tr');
    var visiveis = 0;
    for (var i = 1; i < linhas.length; i++) {
        var texto = linhas[i].innerText.toLowerCase();
        var exibe = texto.indexOf(filtro) > -1;
        linhas[i].style.display = exibe ? '' : 'none';
        if (exibe) visiveis++;
    }
    document.getElementById('swCount').innerText = visiveis + ' itens';
}
</script>
</body>
</html>
"@

# --- Montar e salvar HTML --------------------------------------------------
$fullHtml = $htmlTop + $htmlCards + $htmlSO + $htmlCPU + $htmlRAM + $htmlMB +
            $htmlStorage + $htmlGPU + $htmlNet + $htmlMonitors +
            $htmlSoftware + $htmlHotfixes + $htmlServices + $htmlBottom

Set-Content -Path $HtmlFile -Value $fullHtml -Encoding UTF8
Write-Ok "HTML salvo: $HtmlFile"

# ---------------------------------------------------------------------------
# CONVERSAO PARA PDF
# ---------------------------------------------------------------------------
if (-not $NaoPDF) {
    Write-Info 'Procurando Chrome ou Edge para conversao PDF...'

    $chromePaths = @(
        "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
        "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
        "$env:LocalAppData\Google\Chrome\Application\chrome.exe"
    )
    $edgePaths = @(
        "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
        "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
    )

    $browserExe  = $null
    $browserName = ''

    foreach ($p in $chromePaths) {
        if (Test-Path $p) { $browserExe = $p; $browserName = 'Chrome'; break }
    }
    if (-not $browserExe) {
        foreach ($p in $edgePaths) {
            if (Test-Path $p) { $browserExe = $p; $browserName = 'Edge'; break }
        }
    }

    if ($browserExe) {
        Write-Info "Convertendo para PDF via $browserName — aguarde..."
        $fileUrl = "file:///$($HtmlFile -replace '\\', '/')"
        $pdfArgs = @(
            '--headless',
            '--disable-gpu',
            '--no-pdf-header-footer',
            '--print-to-pdf-no-header',
            "--print-to-pdf=$PdfFile",
            $fileUrl
        )
        try {
            $proc = Start-Process -FilePath $browserExe -ArgumentList $pdfArgs `
                                  -Wait -PassThru -WindowStyle Hidden -ErrorAction Stop
            if (Test-Path $PdfFile) {
                $pdfSize = [math]::Round((Get-Item $PdfFile).Length / 1KB, 1)
                Write-Ok "PDF gerado: $PdfFile ($pdfSize KB)"
            } else {
                Write-Warn "Conversao concluiu (ExitCode $($proc.ExitCode)) mas PDF nao encontrado"
                Write-Warn "Abra o HTML manualmente e use Ctrl+P para imprimir em PDF"
            }
        } catch {
            Write-Fail "Erro ao iniciar $browserName : $($_.Exception.Message)"
        }
    } else {
        Write-Warn 'Chrome e Edge nao encontrados — PDF nao gerado'
        Write-Warn "Abra o HTML e use Ctrl+P > Salvar como PDF: $HtmlFile"
    }
}

# ---------------------------------------------------------------------------
# RESUMO FINAL
# ---------------------------------------------------------------------------
Write-Title 'RELATORIO CONCLUIDO'
Write-Ok  "HTML  : $HtmlFile"
if (-not $NaoPDF -and (Test-Path $PdfFile)) {
    Write-Ok  "PDF   : $PdfFile"
}
Write-Info "Log   : $LogFile"
Write-Host ''
Write-Info "Software catalogado : $($software.Count) programas"
Write-Info "Hotfixes            : $($hotfixes.Count)"
Write-Info "Servicos ativos     : $($services.Count)"
Write-Host ''

Stop-Transcript | Out-Null

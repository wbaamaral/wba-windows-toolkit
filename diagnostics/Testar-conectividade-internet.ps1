#Requires -Version 5.1
<#
.SYNOPSIS
    Diagnóstico completo de conectividade com a internet.

.DESCRIPTION
    Executa em sequência obrigatória:
      1. Validação dos parâmetros de rede local (adaptador, IP, gateway, DNS)
      2. Conectividade via IP direto (sem resolução de nomes)
      3. Resolução de nomes via DNS
      4. Conectividade via nomes de domínio

    As etapas 2-4 só são executadas se a etapa 1 for aprovada sem erros críticos.

.PARAMETER Detalhado
    Exibe informações adicionais em cada teste.

.EXAMPLE
    .\Testar-conectividade-internet.ps1

.EXAMPLE
    .\Testar-conectividade-internet.ps1 -Detalhado

.NOTES
    Toolkit : WBA Windows Toolkit
    Módulo  : Diagnósticos
    Versão  : 1.0.0
#>

[CmdletBinding()]
param(
    [switch]$Detalhado
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'SilentlyContinue'

# Garante exibição correta de caracteres especiais (pt-BR) no console do Windows
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8

$PSDefaultParameterValues['Out-File:Encoding']     = 'utf8'
$PSDefaultParameterValues['Set-Content:Encoding']  = 'utf8'
$PSDefaultParameterValues['Add-Content:Encoding']  = 'utf8'

chcp 65001 | Out-Null

# ---------------------------------------------------------------------------
# Configuração dos alvos de teste
# ---------------------------------------------------------------------------
$script:AlvosIP = @(
    [PSCustomObject]@{ Endereco = '8.8.8.8';   Descricao = 'Google DNS Primário'    }
    [PSCustomObject]@{ Endereco = '8.8.4.4';   Descricao = 'Google DNS Secundário'  }
    [PSCustomObject]@{ Endereco = '1.1.1.1';   Descricao = 'Cloudflare DNS'         }
    [PSCustomObject]@{ Endereco = '9.9.9.9';   Descricao = 'Quad9 DNS'              }
)

$script:AlvosDNS = @(
    [PSCustomObject]@{ Nome = 'www.google.com';     Descricao = 'Google'     }
    [PSCustomObject]@{ Nome = 'www.microsoft.com';  Descricao = 'Microsoft'  }
    [PSCustomObject]@{ Nome = 'www.cloudflare.com'; Descricao = 'Cloudflare' }
    [PSCustomObject]@{ Nome = 'conectividade.microsoft.com'; Descricao = 'MS Connectivity Check' }
)

$script:AlvosResolucao = @('www.google.com', 'www.microsoft.com', 'dns.cloudflare.com')

# ---------------------------------------------------------------------------
# Contadores globais
# ---------------------------------------------------------------------------
$script:ErroCritico = 0
$script:Avisos      = 0
$script:TotalOK     = 0
$script:TotalErro   = 0

# ---------------------------------------------------------------------------
# Funções de saída formatada
# ---------------------------------------------------------------------------
function Write-Cabecalho {
    param([string]$Titulo)
    $linha = '=' * 65
    Write-Host ''
    Write-Host $linha -ForegroundColor Cyan
    Write-Host "  $Titulo" -ForegroundColor Cyan
    Write-Host $linha -ForegroundColor Cyan
}

function Write-SubCabecalho {
    param([string]$Titulo)
    Write-Host ''
    Write-Host "  [ $Titulo ]" -ForegroundColor Yellow
    Write-Host "  $('-' * ($Titulo.Length + 4))" -ForegroundColor DarkYellow
}

function Write-Teste {
    param(
        [string]$Label,
        [string]$Valor,
        [ValidateSet('OK','ERRO','AVISO','INFO')][string]$Status = 'INFO',
        [string]$Detalhe = ''
    )

    $cor    = @{ OK = 'Green'; ERRO = 'Red'; AVISO = 'Yellow'; INFO = 'Cyan'  }[$Status]
    $icone  = @{ OK = ' OK  '; ERRO = 'ERRO '; AVISO = 'AVISO'; INFO = 'INFO ' }[$Status]

    Write-Host ("  [{0}]  {1,-40} {2}" -f $icone, $Label, $Valor) -ForegroundColor $cor

    if ($Detalhe -and $Detalhado) {
        Write-Host ("          $Detalhe") -ForegroundColor DarkGray
    }

    switch ($Status) {
        'OK'    { $script:TotalOK++   }
        'ERRO'  { $script:TotalErro++ }
        'AVISO' { $script:Avisos++    }
    }
}

function Write-Bloqueio {
    param([string]$Motivo)
    Write-Host ''
    Write-Host ('  ' + ('!' * 61)) -ForegroundColor Red
    Write-Host "  !! BLOQUEADO: $Motivo" -ForegroundColor Red
    Write-Host "  !! Corrija os erros acima antes de continuar." -ForegroundColor Red
    Write-Host ('  ' + ('!' * 61)) -ForegroundColor Red
    Write-Host ''
}

# ---------------------------------------------------------------------------
# CABEÇALHO DA EXECUÇÃO
# ---------------------------------------------------------------------------
Write-Host ''
Write-Host ('  ' + ('=' * 63)) -ForegroundColor DarkCyan
Write-Host '  DIAGNÓSTICO DE CONECTIVIDADE COM A INTERNET' -ForegroundColor White
Write-Host ('  ' + ('=' * 63)) -ForegroundColor DarkCyan
Write-Host "  Computador : $env:COMPUTERNAME" -ForegroundColor DarkGray
Write-Host "  Usuário    : $env:USERDOMAIN\$env:USERNAME" -ForegroundColor DarkGray
Write-Host "  Início     : $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor DarkGray

# ===========================================================================
# ETAPA 1 — VALIDAÇÃO DA REDE LOCAL
# ===========================================================================
Write-Cabecalho 'ETAPA 1 de 4 — Configuração de Rede Local'

# --- 1.1 Adaptadores ativos --------------------------------------------------
$adaptadores = Get-NetAdapter |
    Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notmatch 'Loopback' } |
    Sort-Object -Property InterfaceMetric

if (-not $adaptadores) {
    Write-Teste 'Adaptadores de rede' 'NENHUM ATIVO ENCONTRADO' 'ERRO'
    $script:ErroCritico++
    Write-Bloqueio 'Nenhum adaptador de rede ativo. Verifique o hardware ou driver de rede.'
    exit 1
}

Write-Teste "Adaptadores ativos" "$($adaptadores.Count) encontrado(s)" 'INFO'

foreach ($adaptador in $adaptadores) {

    Write-SubCabecalho "$($adaptador.Name)  |  $($adaptador.InterfaceDescription)"

    # Status e velocidade
    Write-Teste 'Status do adaptador' $adaptador.Status 'OK'

    $velocidade = if ($adaptador.LinkSpeed -gt 0) {
        "$([math]::Round($adaptador.LinkSpeed / 1MB)) Mbps"
    } else { 'N/D' }
    Write-Teste 'Velocidade de link' $velocidade 'INFO'

    # --- 1.2 Endereço IPv4 --------------------------------------------------
    $enderecos = Get-NetIPAddress -InterfaceIndex $adaptador.InterfaceIndex `
                                  -AddressFamily IPv4 -ErrorAction SilentlyContinue |
                 Where-Object { $_.IPAddress -ne '127.0.0.1' }

    if (-not $enderecos) {
        Write-Teste 'Endereço IPv4' 'NÃO ATRIBUÍDO' 'ERRO' 'Adaptador sem endereço IP. Possível falha de DHCP ou configuração.'
        $script:ErroCritico++
        continue
    }

    foreach ($endereco in $enderecos) {
        if ($endereco.IPAddress -like '169.254.*') {
            Write-Teste 'Endereço IPv4' "$($endereco.IPAddress) — APIPA" 'ERRO' `
                'IP APIPA indica falha de DHCP. O computador não obteve um endereço válido.'
            $script:ErroCritico++
        } else {
            $origem = if ($endereco.PrefixOrigin -eq 'Dhcp') { 'DHCP' } else { 'Estático' }
            Write-Teste 'Endereço IPv4' "$($endereco.IPAddress)/$($endereco.PrefixLength)  ($origem)" 'OK'
        }
    }

    # --- 1.3 Gateway padrão --------------------------------------------------
    $ipConfig = Get-NetIPConfiguration -InterfaceIndex $adaptador.InterfaceIndex -ErrorAction SilentlyContinue
    $gateway   = $ipConfig.IPv4DefaultGateway | Select-Object -First 1

    if (-not $gateway -or -not $gateway.NextHop) {
        Write-Teste 'Gateway padrão' 'NÃO CONFIGURADO' 'ERRO' `
            'Sem rota padrão — tráfego para fora da rede local não será encaminhado.'
        $script:ErroCritico++
    } else {
        Write-Teste 'Gateway padrão' $gateway.NextHop 'OK'

        # Alcançabilidade do gateway via ICMP
        $pingGW = Test-Connection -ComputerName $gateway.NextHop -Count 2 -Quiet -ErrorAction SilentlyContinue
        if ($pingGW) {
            Write-Teste 'Ping ao gateway' "$($gateway.NextHop) — responde" 'OK'
        } else {
            Write-Teste 'Ping ao gateway' "$($gateway.NextHop) — sem resposta ICMP" 'AVISO' `
                'Gateway pode estar bloqueando ICMP. Verifique se o roteador está acessível.'
        }

        # Alcançabilidade do gateway via ARP (verifica camada 2)
        $arpEntry = Get-NetNeighbor -InterfaceIndex $adaptador.InterfaceIndex `
                                    -IPAddress $gateway.NextHop -ErrorAction SilentlyContinue |
                    Where-Object { $_.State -ne 'Unreachable' }
        if ($arpEntry) {
            Write-Teste 'ARP (camada 2)' "MAC $($arpEntry.LinkLayerAddress)" 'OK'
        } else {
            Write-Teste 'ARP (camada 2)' 'Gateway sem entrada ARP válida' 'AVISO' `
                'Pode indicar problema de camada 2 (switch, VLAN, cabo).'
        }
    }

    # --- 1.4 Servidores DNS --------------------------------------------------
    $dnsConf    = Get-DnsClientServerAddress -InterfaceIndex $adaptador.InterfaceIndex `
                                             -AddressFamily IPv4 -ErrorAction SilentlyContinue
    $dnsServers = $dnsConf.ServerAddresses | Where-Object { $_ -and $_ -ne '0.0.0.0' }

    if (-not $dnsServers) {
        Write-Teste 'Servidores DNS' 'NENHUM CONFIGURADO' 'ERRO' `
            'Sem DNS configurado — resolução de nomes falhará completamente.'
        $script:ErroCritico++
    } else {
        $idx = 1
        foreach ($servidor in $dnsServers) {
            Write-Teste "DNS $idx" $servidor 'OK'
            $idx++
        }
    }

    # --- 1.5 Configuração de proxy ------------------------------------------
    $proxyReg = Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' `
                                 -ErrorAction SilentlyContinue
    if ($proxyReg -and $proxyReg.ProxyEnable -eq 1) {
        Write-Teste 'Proxy HTTP' "ATIVO — $($proxyReg.ProxyServer)" 'AVISO' `
            'Proxy ativo pode interferir em testes de conectividade HTTP/HTTPS.'
    } else {
        Write-Teste 'Proxy HTTP' 'Não configurado' 'INFO'
    }
}

# --- Barreira: sem rede local, não há como testar internet ------------------
if ($script:ErroCritico -gt 0) {
    Write-Bloqueio "$($script:ErroCritico) erro(s) crítico(s) na configuração de rede local."
    Write-Host "  Diagnóstico encerrado na Etapa 1. Resolva os problemas de rede local primeiro." -ForegroundColor Red
    Write-Host ''
    exit 1
}

Write-Host ''
Write-Host '  Rede local validada com sucesso. Prosseguindo...' -ForegroundColor Green

# ===========================================================================
# ETAPA 2 — CONECTIVIDADE VIA IP DIRETO (sem DNS)
# ===========================================================================
Write-Cabecalho 'ETAPA 2 de 4 — Conectividade via IP Direto (sem DNS)'
Write-Host '  Testa se há rota para a internet independentemente do DNS.' -ForegroundColor DarkGray

$ipSucesso = 0
$ipFalha   = 0

foreach ($alvo in $script:AlvosIP) {

    $ping = Test-Connection -ComputerName $alvo.Endereco -Count 3 -ErrorAction SilentlyContinue

    if ($ping) {
        $latMedia = [math]::Round(($ping | Measure-Object -Property ResponseTime -Average).Average, 1)
        $latMin   = ($ping | Measure-Object -Property ResponseTime -Minimum).Minimum
        $latMax   = ($ping | Measure-Object -Property ResponseTime -Maximum).Maximum
        Write-Teste "$($alvo.Descricao)  ($($alvo.Endereco))" `
                    "${latMedia}ms  (min:${latMin} max:${latMax})" 'OK'
        $ipSucesso++
    } else {
        Write-Teste "$($alvo.Descricao)  ($($alvo.Endereco))" 'Sem resposta ICMP' 'ERRO' `
            'IP inalcançável. Possível bloqueio de firewall, roteamento incorreto ou sem acesso externo.'
        $ipFalha++
    }
}

# Verificação de portas TCP por IP (independe de DNS)
Write-SubCabecalho 'Verificação TCP por IP (porta 443)'
$portasTeste = @(
    [PSCustomObject]@{ IP = '1.1.1.1'; Porta = 443; Descricao = 'Cloudflare HTTPS' }
    [PSCustomObject]@{ IP = '8.8.8.8'; Porta = 443; Descricao = 'Google HTTPS'     }
)

foreach ($t in $portasTeste) {
    $tcp = Test-NetConnection -ComputerName $t.IP -Port $t.Porta `
                              -InformationLevel Quiet -WarningAction SilentlyContinue `
                              -ErrorAction SilentlyContinue
    if ($tcp) {
        Write-Teste "$($t.Descricao)  [$($t.IP):$($t.Porta)]" 'TCP conectado' 'OK'
    } else {
        Write-Teste "$($t.Descricao)  [$($t.IP):$($t.Porta)]" 'TCP falhou' 'AVISO' `
            'Porta 443 bloqueada por firewall corporativo ou filtro de conteúdo.'
    }
}

if ($ipFalha -ge $script:AlvosIP.Count) {
    $script:ErroCritico++
    Write-Bloqueio 'Nenhum IP externo responde. Sem rota para a internet.'
    Write-Host '  Verifique o gateway, roteador, modem ou provedor.' -ForegroundColor Red
    Write-Host ''
    exit 1
}

# ===========================================================================
# ETAPA 3 — RESOLUÇÃO DE NOMES VIA DNS
# ===========================================================================
Write-Cabecalho 'ETAPA 3 de 4 — Resolução de Nomes via DNS'
Write-Host '  Verifica se os servidores DNS estão respondendo corretamente.' -ForegroundColor DarkGray

$dnsOK    = 0
$dnsFalha = 0

foreach ($nome in $script:AlvosResolucao) {
    try {
        $resolucao    = Resolve-DnsName -Name $nome -Type A -ErrorAction Stop
        $ipsResolvidos = ($resolucao | Where-Object { $_.Type -eq 'A' } |
                          Select-Object -ExpandProperty IPAddress -First 3) -join ', '

        if ($ipsResolvidos) {
            Write-Teste $nome $ipsResolvidos 'OK'
            $dnsOK++
        } else {
            Write-Teste $nome 'Sem registros A' 'AVISO'
        }
    } catch {
        $msg = $_.Exception.Message -replace "`r?`n", ' '
        Write-Teste $nome 'Falha na resolução' 'ERRO' $msg
        $dnsFalha++
    }
}

# Medir tempo de resolução DNS
Write-SubCabecalho 'Latência de resolução DNS'
foreach ($nome in ($script:AlvosResolucao | Select-Object -First 2)) {
    $inicio = [System.Diagnostics.Stopwatch]::StartNew()
    $ok     = $null
    try {
        $ok = Resolve-DnsName -Name $nome -Type A -ErrorAction Stop
    } catch {}
    $inicio.Stop()

    if ($ok) {
        Write-Teste "Resolução de $nome" "$($inicio.ElapsedMilliseconds) ms" 'INFO'
    }
}

if ($dnsFalha -ge $script:AlvosResolucao.Count) {
    $script:ErroCritico++
    Write-Bloqueio 'DNS não está resolvendo nomes. Verifique os servidores DNS configurados.'
    Write-Host ''
    exit 1
}

# ===========================================================================
# ETAPA 4 — CONECTIVIDADE VIA NOME DE DOMÍNIO
# ===========================================================================
Write-Cabecalho 'ETAPA 4 de 4 — Conectividade via Nomes de Domínio (DNS + Rede)'
Write-Host '  Confirma que o fluxo completo — resolução + roteamento — funciona.' -ForegroundColor DarkGray

foreach ($alvo in $script:AlvosDNS) {

    $ping = Test-Connection -ComputerName $alvo.Nome -Count 3 -ErrorAction SilentlyContinue

    if ($ping) {
        $latMedia = [math]::Round(($ping | Measure-Object -Property ResponseTime -Average).Average, 1)
        Write-Teste "$($alvo.Descricao)  ($($alvo.Nome))" "${latMedia}ms" 'OK'
    } else {
        # Fallback: ICMP pode estar bloqueado — testar TCP 443
        $tcp = Test-NetConnection -ComputerName $alvo.Nome -Port 443 `
                                  -InformationLevel Quiet -WarningAction SilentlyContinue `
                                  -ErrorAction SilentlyContinue
        if ($tcp) {
            Write-Teste "$($alvo.Descricao)  ($($alvo.Nome))" 'ICMP bloqueado — TCP 443 OK' 'AVISO' `
                'Host responde HTTPS mas bloqueia ICMP. Conectividade funcional.'
        } else {
            Write-Teste "$($alvo.Descricao)  ($($alvo.Nome))" 'Sem resposta (ICMP e TCP 443)' 'ERRO' `
                'Verifique firewall local, filtro de conteúdo ou proxy corporativo.'
        }
    }
}

# ===========================================================================
# RESUMO FINAL
# ===========================================================================
Write-Cabecalho 'RESUMO DO DIAGNÓSTICO'

Write-Host ''
Write-Host ("  Testes OK   : {0,3}" -f $script:TotalOK)   -ForegroundColor Green
Write-Host ("  Avisos      : {0,3}" -f $script:Avisos)     -ForegroundColor Yellow
Write-Host ("  Erros       : {0,3}" -f $script:TotalErro)  -ForegroundColor Red
Write-Host ''

if ($script:ErroCritico -eq 0 -and $script:TotalErro -eq 0 -and $script:Avisos -eq 0) {
    Write-Host '  RESULTADO: CONECTIVIDADE PLENA' -ForegroundColor Green
    Write-Host '  Todos os testes passaram sem erros ou avisos.' -ForegroundColor Green
} elseif ($script:ErroCritico -eq 0 -and $script:TotalErro -eq 0) {
    Write-Host '  RESULTADO: CONECTIVIDADE OK (com ressalvas)' -ForegroundColor Yellow
    Write-Host "  $($script:Avisos) aviso(s). Revise os itens marcados com [AVISO]." -ForegroundColor Yellow
} elseif ($script:ErroCritico -eq 0) {
    Write-Host '  RESULTADO: CONECTIVIDADE PARCIAL' -ForegroundColor Yellow
    Write-Host "  $($script:TotalErro) erro(s) não-crítico(s). Alguns destinos podem estar inacessíveis." -ForegroundColor Yellow
} else {
    Write-Host '  RESULTADO: FALHA DE CONECTIVIDADE' -ForegroundColor Red
    Write-Host "  $($script:ErroCritico) erro(s) crítico(s) impedem o acesso à internet." -ForegroundColor Red
}

Write-Host ''
Write-Host "  Concluído em: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor DarkGray
Write-Host ''

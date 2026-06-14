# Guia Rápido do Operador — WBA Windows Toolkit

Autor: **wbaamaral**

Para o manual completo, consulte [`../manual-operador-wba-windows-toolkit.md`](../../manual-operador-wba-windows-toolkit.md).

## Pré-requisitos

```powershell
# 1. Abrir PowerShell como Administrador
# 2. Navegar até a raiz do toolkit
cd C:\WBA\wba-windows-toolkit

# 3. Liberar execução de scripts (sessão atual)
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# 4. Importar módulo principal
Import-Module .\modules\WbaToolkit.Core\WbaToolkit.Core.psm1
```

## Diagnóstico de rede

```powershell
.\diagnostics\networking\Testar-Conectividade-Internet.ps1
# Com relatório HTML:
.\diagnostics\networking\Testar-Conectividade-Internet.ps1 -GerarRelatorioHtml
```

## Diagnóstico de disco (HD100)

```powershell
# Diagnóstico completo
.\maintenance\Diagnostico-Reparo-HD100.ps1

# Apenas diagnóstico, sem ações
.\maintenance\Diagnostico-Reparo-HD100.ps1 -ApenasRelatorio
```

## Diagnóstico de driver gráfico

```powershell
.\diagnostics\Diagnostico-Driver-Grafico.ps1
```

## Gerenciar inicialização

```powershell
# Abre menu interativo
.\maintenance\Gerenciar-Inicializacao-Windows.ps1
```

## Inventário de hardware/software

```powershell
# Inventário completo
.\inventory\Inventario-Hardware-Software.ps1

# Apenas hardware e drivers (resumo)
.\inventory\Inventario-Hardware-Software.ps1 -SomenteHardwareDrivers

# Com HTML
.\inventory\Inventario-Hardware-Software.ps1 -GerarHtml
```

## Limpeza do Windows

```powershell
.\maintenance\limpeza-windows.ps1
```

## Atualizar Windows

```powershell
.\updates\upgrade-windows.ps1
```

## Remover perfis inativos

```powershell
.\utilities\Remover-Perfis-Inativos.ps1
```

## Preparar imagem corporativa (sysprep)

```powershell
# Executa tweaks de perfil Default e inicia sysprep
.\maintenance\Preparar-Imagem-Windows.ps1
```

## Configurar pasta de relatórios

```powershell
Import-Module .\modules\WbaToolkit.Core\WbaToolkit.Core.psm1
Set-ToolkitReportsRoot -Path "D:\Relatorios"
Get-ToolkitReportsRoot
```

## Onde encontrar relatórios

Padrão: `C:\WBA\Relatorios\<Script>\<timestamp>\`

- Logs: `logs\`
- Relatórios HTML: `<nome-relatorio>.html`
- Backups: `backups\`

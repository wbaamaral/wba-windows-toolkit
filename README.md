# WBA Windows Toolkit

Coleção de ferramentas PowerShell para administração, manutenção, diagnóstico, atualização e automação de ambientes Windows.

## Objetivo

O WBA Windows Toolkit reúne scripts PowerShell desenvolvidos para simplificar tarefas rotineiras de administração de sistemas Microsoft Windows.

O foco do projeto é disponibilizar ferramentas seguras, documentadas e reutilizáveis para ambientes corporativos, laboratórios e uso profissional.

## Características

- Compatível com Windows PowerShell 5.1
- Compatível com PowerShell 7+
- Suporte completo a UTF-8
- Ajuda integrada via parâmetros
- Logs automáticos de execução
- Autoelevação administrativa
- Tratamento de erros
- Estrutura padronizada
- Comentários e documentação incorporados
- Foco em operações conservadoras e seguras

## Funcionalidades Disponíveis

### Manutenção

- Limpeza segura de arquivos temporários
- Limpeza de logs antigos
- Remoção de minidumps
- Limpeza de cache do Windows Update
- Limpeza de cache de miniaturas

### Integridade do Sistema

- SFC /SCANNOW
- DISM RestoreHealth
- DISM StartComponentCleanup

### Atualização

- Windows Update nativo
- Atualização via Chocolatey
- Verificações básicas de atualização

### Otimização

- CompactOS
- Configuração de Page File
- Desativação de hibernação
- Otimização de volumes

### Diagnóstico

- Coleta de informações do sistema
- Verificação de espaço em disco
- Relatórios operacionais

## Padrões Utilizados

Todos os scripts seguem as seguintes diretrizes:

### UTF-8

```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['Set-Content:Encoding'] = 'utf8'
$PSDefaultParameterValues['Add-Content:Encoding'] = 'utf8'

chcp 65001 | Out-Null
```

### Identificação do Script

```powershell
$ScriptName = if ($MyInvocation.MyCommand.Name) {
    $MyInvocation.MyCommand.Name
}
else {
    Split-Path -Leaf $PSCommandPath
}

$ScriptPath = $PSCommandPath
$ScriptDir  = $PSScriptRoot
```

## Estrutura do Projeto

```text
wba-windows-toolkit/
├── maintenance/
├── updates/
├── diagnostics/
├── optimization/
├── inventory/
├── networking/
├── active-directory/
├── printers/
├── utilities/
├── docs/
└── LICENSE
```

## Requisitos

- Windows 10 ou superior
- Windows Server 2016 ou superior
- Windows PowerShell 5.1 ou superior
- Permissões administrativas para algumas operações

## Política de Execução

Caso necessário:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
```

## Licença

Este projeto está licenciado sob a licença MIT.

Consulte o arquivo LICENSE para mais informações.

## Autor

Welyqrson Bastos Amaral

Administrador de Sistemas | Infraestrutura | Automação | PowerShell
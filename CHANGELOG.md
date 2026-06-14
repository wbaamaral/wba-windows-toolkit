# Changelog

## [Não lançado]



## [v1.0.1] — 2026-06-14

### Adicionado
- Estrutura `docs/manual/` com catálogo geral de scripts por função operacional, guia rápido do operador e referência de módulos e funções públicas

## [v1.0.0] — 2026-06-14

### Adicionado
- Módulo WbaToolkit.Startup: lista, habilita, desabilita e remove itens de inicialização do Windows (registro, pasta de inicialização e tarefas agendadas)
- Módulo WbaToolkit.Maintenance: prepara imagem corporativa para sysprep com dry-run obrigatório, backup de NTUSER.DAT e confirmação explícita do operador
- Script Gerenciar-Inicializacao-Windows.ps1: interface assistida para gerenciamento de itens de inicialização
- Script Preparar-Imagem-Windows.ps1: aplica tweaks ao perfil Default antes do sysprep, com suporte a `-ApenasDryRun` e `-SemSysprep`
- Funções WbaToolkit.Core: Read-UserInput, Write-ScriptLog, Initialize-ScriptSession, Get-CimInstanceSafe, Write-TextFileUtf8, Get-Utf8BomEncoding, Get-ToolkitConfiguration
- Exportação de resumo de drivers de hardware em inventário
- Assistente de conectividade com suporte a múltiplos protocolos por destino
- Diagnóstico de driver gráfico com relatório TXT

### Corrigido
- Criação da sessão de relatório padrão adiada para evitar diretórios vazios em execuções sem saída

### Alterado
- Scripts HD100, Gráficos e AD refatorados para usar funções compartilhadas do WbaToolkit.Core
- Sessões de saída de relatório padronizadas em todos os scripts de diagnóstico
- Todos os módulos atualizados para ModuleVersion 1.0.0

## [v0.1.0] — 2026-05-01

### Adicionado
- Módulo WbaToolkit.Core com funções utilitárias compartilhadas
- Módulo WbaToolkit.Networking com testes de conectividade TCP/UDP/ICMP/DNS
- Script Diagnostico-Reparo-HD100.ps1 com diagnóstico de disco e relatório HTML

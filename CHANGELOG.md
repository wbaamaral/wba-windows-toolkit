# Changelog

## [Não lançado]



## [v1.1.1] — 2026-06-14

### Alterado
- `docs/manual/README.md`: `Export-ToolkitDocumentation` adicionado na referência técnica; contagem de funções do Core corrigida (23→24); exemplo de geração atualizado
- `docs/manual/referencia/modulos.md`: `Export-ToolkitDocumentation` adicionado na tabela de utilitários do Core; cabeçalho atualizado
- `docs/manual/operador/guia-rapido.md`: seção de geração de portal HTML adicionada

## [v1.1.0] — 2026-06-14

### Adicionado
- `Export-ToolkitDocumentation` — comando unificado de portal HTML (ADR 0013); gera `index.html`, `operador.html` e referência técnica via `Export-ToolkitFunctionDocs`; suporta `-Mode All|Portal|TechnicalReference` e `-IncludeChangelog`
- `ConvertFrom-MarkdownSimple` (privada) — conversor Markdown→HTML em PS 5.1 puro (máquina de estados: headings, tabelas, listas, fenced code)
- `New-PortalIndexHtml` (privada) — gerador de portal index.html com cards de ação e catálogo convertido de `docs/manual/README.md`

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

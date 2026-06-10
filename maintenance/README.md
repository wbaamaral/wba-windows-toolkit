# maintenance

Scripts de manutenção preventiva e corretiva do sistema operacional Windows. Focados em liberar espaço em disco, remover resíduos acumulados, verificar integridade de arquivos do sistema e manter o ambiente saudável sem remover componentes críticos.

---

## Scripts

### `Diagnostico-Reparo-HD100.ps1`

**Função:** Diagnóstico técnico assistido para investigar o sintoma de disco em 100% no Windows 10/11.

**Versão inicial:** foco em diagnóstico seguro, coleta de evidências e geração de relatório. No modo `Diagnostico`,
o script não aplica correções permanentes; ações de reparo ficam reservadas ao modo `Assistido`.

**Principais ações:**

| Etapa | Ação |
|---|---|
| Sistema | Coleta versão do Windows, equipamento, memória, uptime, tempo do último boot e plano de energia |
| Disco | Mede uso do disco, fila média e latência por contadores quando disponíveis |
| Processos | Lista processos com maior I/O acumulado |
| Saúde | Consulta `Get-PhysicalDisk`, `Get-Disk`, `Win32_DiskDrive` e SMART quando disponível |
| Eventos | Consulta eventos recentes de `Disk`, `Ntfs`, `storahci`, `iaStor`, `volmgr`, `partmgr` e similares |
| CHKDSK | Executa `chkdsk <unidade> /scan` no modo diagnóstico |
| DISM | Executa `CheckHealth` e `ScanHealth` no modo diagnóstico |
| SFC | Executa `sfc /scannow` apenas no modo assistido |
| Inicialização | Lista Registro `Run/RunOnce`, pastas Inicializar e tarefas agendadas de logon/boot com estado ON/OFF |
| Aplicativos | Detecta indícios de plugins bancários, antivírus, OneDrive, navegadores e Adobe Reader |
| Relatórios | Gera TXT e JSON; HTML opcional |

No modo `Assistido`, o bloco de inicialização permite desabilitar uma entrada para diagnóstico, habilitar novamente
entradas desabilitadas pelo HD100 ou remover definitivamente uma entrada da lista de inicialização com confirmação
textual. O modo `Rollback` reativa entradas de inicialização que foram desabilitadas pelo próprio HD100.

**Parâmetros:**

| Parâmetro | Padrão | Descrição |
|---|---|---|
| `-Modo` | `Diagnostico` | `Diagnostico` \| `Assistido` \| `Relatorio` \| `Rollback` |
| `-DryRun` | — | Simula comandos externos como CHKDSK, DISM e SFC |
| `-GerarHtml` | — | Gera relatório HTML além de TXT/JSON |
| `-GerarJson` | — | Mantido por compatibilidade; JSON é gerado por padrão |
| `-AgendarChkdsk` | — | No modo assistido, oferece agendamento de `chkdsk /r` com confirmação textual |
| `-CriarPontoRestauracao` | — | Reservado para evolução do modo assistido |
| `-DiretorioSaida` | `C:\WBA\Relatorios\HD100` | Diretório base das execuções |

**Uso básico:**

```powershell
# Diagnóstico seguro
.\Diagnostico-Reparo-HD100.ps1

# Diagnóstico com relatório HTML
.\Diagnostico-Reparo-HD100.ps1 -GerarHtml

# Simular sem executar CHKDSK/DISM/SFC
.\Diagnostico-Reparo-HD100.ps1 -DryRun

# Modo assistido
.\Diagnostico-Reparo-HD100.ps1 -Modo Assistido -GerarHtml

# Reativar entradas de inicialização desabilitadas pelo HD100
.\Diagnostico-Reparo-HD100.ps1 -Modo Rollback

# Regerar relatório da execução mais recente
.\Diagnostico-Reparo-HD100.ps1 -Modo Relatorio -GerarHtml
```

**Saída:** `C:\WBA\Relatorios\HD100\<timestamp>\`

### `limpeza-windows.ps1`

**Função:** Limpeza segura, manutenção e otimização conservadora para Windows 10 Pro.

**Principais ações:**

| Etapa | Ação |
|---|---|
| Temporários | Remove `%TEMP%` do usuário atual e de todos os perfis locais |
| Temporários do SO | Remove `%SystemRoot%\Temp` |
| Dumps de memória | Remove minidumps (`\Minidump`) e `MEMORY.DMP` |
| WER | Remove relatórios antigos do Windows Error Reporting (> 7 dias) |
| Logs do sistema | Remove logs de `\Windows\Logs`, DISM e CBS antigos (> 15-30 dias), preservando `CBS.log` ativo |
| Cache visual | Remove `thumbcache_*.db` e `iconcache_*.db` de todos os perfis |
| Windows Update | Para serviços, limpa `SoftwareDistribution\Download` e restaura serviços apenas se estavam ativos |
| Lixeira | Esvazia a lixeira |
| cleanmgr | Executa limpeza integrada do Windows via registry sageset/sagerun (silencioso) |
| SFC / DISM | Executa `sfc /scannow`, `DISM StartComponentCleanup` e `DISM RestoreHealth` |
| Hibernação | Desativa e remove `hiberfil.sys` (opcional) |
| Pagefile | Configura arquivo de paginação com tamanho fixo (opcional) |
| CompactOS | Ativa compressão do OS (opcional) |
| Optimize-Volume | Desfragmenta/otimiza o volume do sistema |
| Chkdsk | Verifica eventos de falha no sistema de arquivos e oferece agendamento de chkdsk |
| Evento Windows | Registra evento no Visualizador (Application > LimpezaWindows) ao agendar chkdsk |
| Visualizador de Eventos | Limpa logs Application/System/Setup com opção de backup dos erros |

**Parâmetros:**

| Parâmetro | Padrão | Descrição |
|---|---|---|
| `-NoReboot` | — | Não reinicia ao final |
| `-NoSfc` | — | Não executa SFC/DISM |
| `-NoUpdateCache` | — | Não limpa cache do Windows Update |
| `-NoRecycleBin` | — | Não esvazia a lixeira |
| `-NoOptimizeVolume` | — | Não executa Optimize-Volume |
| `-DisableHibernation` | — | Desativa hibernação |
| `-SetPageFile` | — | Configura pagefile fixo |
| `-PageFileGB` | `4` | Tamanho do pagefile em GB (1–64) |
| `-EnableCompactOS` | — | Ativa CompactOS |
| `-RepararSistema` | — | Executa **apenas** SFC + DISM, ignorando toda a limpeza |
| `-ChkdskAction` | `Ask` | `Schedule` \| `Skip` — omitir = prompt interativo |
| `-EventLogCleanup` | `Ask` | `All` \| `ErrorOnly` \| `None` — omitir = prompt interativo |

**Uso básico:**

```powershell
# Execução padrão (interativa)
.\limpeza-windows.ps1

# Modo automação silenciosa sem reboot
.\limpeza-windows.ps1 -ChkdskAction Skip -EventLogCleanup None -NoReboot

# Limpeza completa com todas as opções, sem reboot
.\limpeza-windows.ps1 -DisableHibernation -SetPageFile -PageFileGB 4 -EnableCompactOS -NoReboot

# Somente SFC + DISM, sem nenhuma limpeza
.\limpeza-windows.ps1 -RepararSistema

# Somente SFC + DISM, sem reiniciar
.\limpeza-windows.ps1 -RepararSistema -NoReboot

# Agendar chkdsk automaticamente se houver falhas detectadas
.\limpeza-windows.ps1 -ChkdskAction Schedule
```

**Requisitos:** Administrador local. Windows 10 Pro. PowerShell 5.1+.

**Log:** `C:\ti\<timestamp>-limpeza-windows.log`

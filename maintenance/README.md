# maintenance

Scripts de manutenção preventiva e corretiva do sistema operacional Windows. Focados em liberar espaço em disco, remover resíduos acumulados, verificar integridade de arquivos do sistema e manter o ambiente saudável sem remover componentes críticos.

---

## Scripts

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

# inventory

Scripts de inventário de hardware e software. Coletam informações detalhadas do equipamento e do ambiente Windows, gerando relatórios estruturados para documentação de ativos, auditorias e suporte técnico.

---

## Scripts

### `Inventario-Hardware-Software.ps1`

**Função:** Gera inventário completo de hardware e software em relatório HTML com conversão opcional para PDF.

**Principais ações:**

| Seção coletada | Dados incluídos |
|---|---|
| Sistema Operacional | Nome, versão, build, arquitetura, data de instalação, uptime |
| Processador | Fabricante, modelo, núcleos físicos/lógicos, frequência, cache |
| Memória RAM | Total, módulos instalados, capacidade por slot, frequência |
| Placa-mãe | Fabricante, modelo, número de série |
| BIOS | Fabricante, versão, data de lançamento |
| Armazenamento | Discos físicos (modelo, tamanho, tipo), volumes lógicos com uso e barras de capacidade |
| GPU | Fabricante, modelo, memória dedicada, resolução atual |
| Rede | Adaptadores, IP, MAC, gateway, DNS, status |
| Monitores | Fabricante, modelo, resolução nativa |
| Software instalado | Nome, versão, fabricante, data de instalação (com filtro em tempo real) |
| Atualizações | Histórico recente de Windows Update instaladas |
| Serviços | Serviços com início automático e status atual |

**Saída gerada:**
- **HTML** — relatório com design responsivo, índice de navegação e barras de uso de disco coloridas
- **PDF** — conversão automática via Chrome ou Microsoft Edge em modo headless (quando disponível)

**Parâmetros:**

| Parâmetro | Padrão | Descrição |
|---|---|---|
| `-OutputDir` | `C:\TI` | Diretório de destino do relatório gerado |
| `-NaoPDF` | — | Gera apenas HTML, sem tentar converter para PDF |

**Uso básico:**

```powershell
# Relatório em C:\TI (HTML + PDF se Chrome/Edge disponível)
.\Inventario-Hardware-Software.ps1

# Somente HTML, sem PDF
.\Inventario-Hardware-Software.ps1 -NaoPDF

# Relatório em diretório personalizado (inclusive compartilhamento de rede)
.\Inventario-Hardware-Software.ps1 -OutputDir "\\servidor\inventario$"
```

**Requisitos:** Administrador local recomendado (dados de hardware exigem privilégios elevados). Windows 10+. PowerShell 5.1+.

**Log:** `C:\TI\<timestamp>-Inventario-Hardware-Software.log`

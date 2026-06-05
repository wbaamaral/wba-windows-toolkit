# utilities

Scripts utilitários de uso geral para administração do dia a dia. Ferramentas avulsas que não se encaixam em categorias específicas, mas são frequentemente necessárias em suporte técnico, implantação e automação de tarefas rotineiras.

---

## Scripts

### `Remover-Perfis-Inativos.ps1`

**Função:** Lista todos os perfis de usuário locais com espaço em disco e permite remover interativamente perfis antigos ou inativos.

**Principais ações:**

| Etapa | Ação |
|---|---|
| Coleta | Enumera perfis via `Win32_UserProfile` (exclui perfis de sistema automaticamente) |
| Tamanho | Calcula o espaço em disco de cada perfil |
| Classificação | Classifica cada perfil: **Ativo**, **Recente**, **Inativo**, **Sem conta** (SID órfão) ou **Carregado** (sessão ativa) |
| Apresentação | Exibe tabela interativa com seleção, total de espaço e preview do espaço recuperável |
| Seleção | Individual por número (`1 3 5`), em massa (`a` = todos os elegíveis) ou limpeza (`c`) |
| Detalhes | Comando `i <n>` exibe SID, caminho completo, último acesso, dias inativo e status |
| Remoção | Confirmação obrigatória antes de excluir; usa `Remove-CimInstance Win32_UserProfile` (remove pasta + chave de registro) |
| Modo silencioso | Auto-seleciona e remove perfis órfãos + inativos sem interação |
| Simulação | `-DryRun` mostra o que seria feito sem alterar o sistema |

**Parâmetros:**

| Parâmetro | Padrão | Descrição |
|---|---|---|
| `-InactiveDays` | `90` | Dias sem acesso para considerar o perfil inativo |
| `-Silent` | — | Remove automaticamente órfãos + inativos sem prompts |
| `-DryRun` | — | Simula a remoção sem alterar nada |
| `-ExcludeProfile` | — | Nomes de perfis a ignorar na listagem |
| `-NoLog` | — | Não cria arquivo de log |

**Uso básico:**

```powershell
# Interface interativa (padrão)
.\Remover-Perfis-Inativos.ps1

# Simulação sem remover nada
.\Remover-Perfis-Inativos.ps1 -DryRun

# Remoção automática de órfãos + inativos há mais de 90 dias
.\Remover-Perfis-Inativos.ps1 -Silent

# Alterar limiar para 180 dias e excluir conta de serviço
.\Remover-Perfis-Inativos.ps1 -InactiveDays 180 -ExcludeProfile "svc.backup"
```

**Requisitos:** Administrador local. Windows 10+. PowerShell 5.1+.

**Log:** `C:\ti\<timestamp>-Remover-Perfis-Inativos.log`

---

> **Outros scripts planejados para este diretório:**
> - Coleta de informações rápidas do sistema (versão, hostname, IP)
> - Geração de senha segura aleatória
> - Verificação e renovação de certificados locais

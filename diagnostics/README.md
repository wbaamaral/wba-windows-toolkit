# diagnostics

Scripts de diagnóstico de conectividade e saúde do ambiente de rede. Executam sequências estruturadas de testes com coleta de evidências, exibindo resultados claros por etapa para auxiliar na identificação e localização de falhas.

---

## Scripts

### `Testar-conectividade-internet.ps1`

**Função:** Invólucro operacional do módulo `WbaToolkit.Networking` para diagnóstico completo e sequencial de
conectividade com a internet.

**Principais ações:**

As etapas são executadas em sequência obrigatória — uma etapa bloqueada impede a execução das posteriores, isolando com precisão a camada da falha.

| Etapa | Camada | O que verifica |
|---|---|---|
| 1 | Rede local | Adaptador ativo, endereço IP, gateway padrão configurado e servidores DNS configurados |
| 2 | IP direto | Ping para `8.8.8.8`, `8.8.4.4`, `1.1.1.1` e `9.9.9.9` sem depender de DNS |
| 3 | DNS | Resolução de nomes para `google.com`, `microsoft.com`, `cloudflare.com` e `www.msftconnecttest.com` |
| 4 | Domínios | Ping e teste de porta TCP 443 para hosts públicos validando conectividade de ponta a ponta |

**Parâmetros:**

| Parâmetro | Descrição |
|---|---|
| `-Detalhado` | Exibe informações adicionais em cada teste (IPs resolvidos, latências individuais) |

**Uso básico:**

```powershell
# Diagnóstico padrão
.\Testar-conectividade-internet.ps1

# Com informações detalhadas
.\Testar-conectividade-internet.ps1 -Detalhado
```

**Saída:** Relatório em tela com status por teste, resumo final e bloqueio quando a rede local impede a continuação.

**Requisitos:** Não requer administrador. Windows 10+. PowerShell 5.1+.

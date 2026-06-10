# Tests

Diretorio reservado para testes automatizados do WBA Windows Toolkit.

Estrutura inicial recomendada:

```text
tests/
├── unit/
├── integration/
└── fixtures/
```

Regras:

- Testes unitarios nao devem alterar o sistema.
- Testes de integracao devem ser separados e identificados.
- Funcoes reutilizaveis devem ser priorizadas para cobertura.

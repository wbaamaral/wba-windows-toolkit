# Modules

Diretorio reservado para modulos PowerShell reutilizaveis do WBA Windows Toolkit.

Estrutura inicial recomendada:

```text
modules/
├── WbaToolkit.Core/
    ├── WbaToolkit.Core.psd1
    ├── WbaToolkit.Core.psm1
    ├── Public/
    └── Private/
└── WbaToolkit.Networking/
    ├── WbaToolkit.Networking.psd1
    ├── WbaToolkit.Networking.psm1
    ├── Public/
    └── Private/
```

Regras:

- Funcoes publicas ficam em `Public/`.
- Funcoes internas ficam em `Private/`.
- O `.psm1` carrega as funcoes e exporta apenas as publicas.
- Funcoes publicas devem ter `Comment-Based Help`.

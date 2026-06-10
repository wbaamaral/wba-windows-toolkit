# Projeto: wba-toolkit
# Autor: wbaamaral

BeforeAll {
    $repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    $script:scriptPaths = @(
        (Join-Path $repoRoot 'configuration/Configurar-Idioma-Regional.ps1'),
        (Join-Path $repoRoot 'maintenance/Diagnostico-Reparo-HD100.ps1'),
        (Join-Path $repoRoot 'maintenance/limpeza-windows.ps1'),
        (Join-Path $repoRoot 'updates/upgrade-windows.ps1'),
        (Join-Path $repoRoot 'active-directory/Diagnostico-GPO-Client.ps1'),
        (Join-Path $repoRoot 'active-directory/Testa-Repara-ContaMaquinaAD.ps1'),
        (Join-Path $repoRoot 'inventory/Inventario-Hardware-Software.ps1'),
        (Join-Path $repoRoot 'utilities/Analise-Espaco-Disco.ps1'),
        (Join-Path $repoRoot 'utilities/Remover-Perfis-Inativos.ps1')
    )
}

Describe 'Uso do modulo compartilhado' {
    It 'Scripts principais devem importar o modulo WbaToolkit.Core' {
        foreach ($path in $scriptPaths) {
            Get-Content -LiteralPath $path -Raw | Should -Match 'WbaToolkit\.Core\.psd1'
        }
    }

    It 'Scripts principais devem ter sintaxe PowerShell valida' {
        foreach ($path in $scriptPaths) {
            $tokens = $null
            $errors = $null
            [System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$tokens, [ref]$errors) | Out-Null

            @($errors).Count | Should -Be 0
        }
    }

    It 'Script de diagnostico deve importar WbaToolkit.Networking' {
        Get-Content -LiteralPath (Join-Path $repoRoot 'diagnostics/Testar-conectividade-internet.ps1') -Raw |
            Should -Match 'WbaToolkit\.Networking\.psd1'
    }

    It 'Scripts refatorados nao devem manter Test-Admin local' {
        foreach ($path in $scriptPaths) {
            Get-Content -LiteralPath $path -Raw | Should -Not -Match 'function\s+Test-Admin\s*\{'
        }
    }

    It 'Scripts refatorados nao devem manter Invoke-Safe local' {
        foreach ($path in $scriptPaths) {
            Get-Content -LiteralPath $path -Raw | Should -Not -Match 'function\s+Invoke-Safe\s*\{'
        }
    }

    It 'Scripts refatorados nao devem manter helpers visuais duplicados' {
        foreach ($path in $scriptPaths) {
            $content = Get-Content -LiteralPath $path -Raw
            $content | Should -Not -Match 'function\s+Write-Ok\s*\{'
            $content | Should -Not -Match 'function\s+Write-Fail\s*\{'
            $content | Should -Not -Match 'function\s+Write-Warn\s*\{'
            $content | Should -Not -Match 'function\s+Write-Info\s*\{'
            $content | Should -Not -Match 'function\s+Write-Title\s*\{'
            $content | Should -Not -Match 'function\s+Write-Section\s*\{'
            $content | Should -Not -Match 'function\s+Write-WarnMsg\s*\{'
            $content | Should -Not -Match 'function\s+Write-InfoMsg\s*\{'
            $content | Should -Not -Match 'function\s+Read-YesNo\s*\{'
            $content | Should -Not -Match 'function\s+Invoke-ExternalCommand\s*\{'
            $content | Should -Not -Match 'function\s+Invoke-Ext\s*\{'
            $content | Should -Not -Match 'function\s+Safe\s*\{'
            $content | Should -Not -Match 'function\s+ConvertTo-HtmlSafe\s*\{'
            $content | Should -Not -Match 'function\s+Format-FileSize\s*\{'
        }
    }
}

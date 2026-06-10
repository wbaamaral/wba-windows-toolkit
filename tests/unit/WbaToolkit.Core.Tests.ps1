# Projeto: wba-toolkit
# Autor: wbaamaral

BeforeAll {
    $repoRoot   = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    $modulePath = Join-Path $repoRoot 'modules/WbaToolkit.Core/WbaToolkit.Core.psd1'

    Import-Module $modulePath -Force -ErrorAction Stop
}

Describe 'WbaToolkit.Core' {
    Context 'Exportacao do modulo' {
        It 'Deve exportar Test-IsAdministrator' {
            (Get-Command Test-IsAdministrator -ErrorAction Stop).CommandType | Should -Be 'Function'
        }

        It 'Deve exportar Invoke-Safe' {
            (Get-Command Invoke-Safe -ErrorAction Stop).CommandType | Should -Be 'Function'
        }

        It 'Deve exportar Format-FileSize' {
            (Get-Command Format-FileSize -ErrorAction Stop).CommandType | Should -Be 'Function'
        }

        It 'Deve exportar Write-Ok' {
            (Get-Command Write-Ok -ErrorAction Stop).CommandType | Should -Be 'Function'
        }

        It 'Deve exportar Write-Fail' {
            (Get-Command Write-Fail -ErrorAction Stop).CommandType | Should -Be 'Function'
        }

        It 'Deve exportar Write-Warn' {
            (Get-Command Write-Warn -ErrorAction Stop).CommandType | Should -Be 'Function'
        }

        It 'Deve exportar Write-Info' {
            (Get-Command Write-Info -ErrorAction Stop).CommandType | Should -Be 'Function'
        }

        It 'Deve exportar Write-Title' {
            (Get-Command Write-Title -ErrorAction Stop).CommandType | Should -Be 'Function'
        }

        It 'Deve exportar Write-Section' {
            (Get-Command Write-Section -ErrorAction Stop).CommandType | Should -Be 'Function'
        }

        It 'Deve exportar Read-YesNo' {
            (Get-Command Read-YesNo -ErrorAction Stop).CommandType | Should -Be 'Function'
        }

        It 'Deve exportar Invoke-ExternalCommand' {
            (Get-Command Invoke-ExternalCommand -ErrorAction Stop).CommandType | Should -Be 'Function'
        }

        It 'Deve exportar ConvertTo-HtmlSafe' {
            (Get-Command ConvertTo-HtmlSafe -ErrorAction Stop).CommandType | Should -Be 'Function'
        }

        It 'Deve exportar Export-ToolkitFunctionDocs' {
            (Get-Command Export-ToolkitFunctionDocs -ErrorAction Stop).CommandType | Should -Be 'Function'
        }

        It 'Deve exportar funcoes de padronizacao de relatorios' {
            (Get-Command Get-ToolkitReportsRoot -ErrorAction Stop).CommandType | Should -Be 'Function'
            (Get-Command Set-ToolkitReportsRoot -ErrorAction Stop).CommandType | Should -Be 'Function'
            (Get-Command Initialize-ToolkitReportSession -ErrorAction Stop).CommandType | Should -Be 'Function'
        }
    }

    Context 'Formatacao de tamanho' {
        It 'Deve formatar bytes pequenos em KB' {
            Format-FileSize -Bytes 1536 | Should -Be '1.5 KB'
        }

        It 'Deve formatar gigabytes corretamente' {
            Format-FileSize -Bytes ([long]2GB) | Should -Be '2.00 GB'
        }
    }

    Context 'Execucao segura' {
        It 'Deve retornar verdadeiro quando o bloco executa com sucesso' {
            Invoke-Safe -Description 'Teste' -Command { return $true } | Should -BeTrue
        }

        It 'Deve retornar falso quando o bloco falha' {
            Invoke-Safe -Description 'Teste de falha' -Command { throw 'falha simulada' } | Should -BeFalse
        }
    }

    Context 'Comandos externos' {
        It 'Deve sinalizar comando inexistente' {
            $result = Invoke-ExternalCommand -FilePath 'comando-inexistente-do-wba' -ArgumentList @()
            $result.ExitCode | Should -Be 127
            $result.Output | Should -Match 'Comando não encontrado'
        }
    }

    Context 'Escape HTML' {
        It 'Deve escapar caracteres especiais' {
            ConvertTo-HtmlSafe -Value '<a>&b' | Should -Be '&lt;a&gt;&amp;b'
        }

        It 'Deve retornar default quando valor e vazio' {
            ConvertTo-HtmlSafe -Value '' | Should -Be '<span class="muted">&mdash;</span>'
        }
    }

    Context 'Elevacao' {
        It 'Deve retornar valor booleano' {
            Test-IsAdministrator | Should -BeOfType [bool]
        }
    }

    Context 'Saida padronizada de relatorios' {
        It 'Deve usar caminho informado pelo usuario com prioridade' {
            $configPath = Join-Path ([System.IO.Path]::GetTempPath()) ('wba-config-' + [guid]::NewGuid().ToString() + '.json')
            $userPath = Join-Path ([System.IO.Path]::GetTempPath()) ('wba-reports-' + [guid]::NewGuid().ToString())

            Get-ToolkitReportsRoot -Path $userPath -ConfigPath $configPath | Should -Be $userPath
        }

        It 'Deve usar ReportsRoot persistente quando parametro nao for informado' {
            $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ('wba-config-' + [guid]::NewGuid().ToString())
            $configPath = Join-Path $tempDir 'config.json'
            $reportsRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('wba-reports-' + [guid]::NewGuid().ToString())

            try {
                Set-ToolkitReportsRoot -Path $reportsRoot -ConfigPath $configPath | Out-Null
                Get-ToolkitReportsRoot -ConfigPath $configPath | Should -Be $reportsRoot
            }
            finally {
                if (Test-Path -LiteralPath $tempDir) {
                    Remove-Item -LiteralPath $tempDir -Recurse -Force
                }
            }
        }

        It 'Deve criar sessao com agrupamento por modulo e timestamp' {
            $reportsRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('wba-reports-' + [guid]::NewGuid().ToString())

            try {
                $session = Initialize-ToolkitReportSession -ReportsRoot $reportsRoot -ModuleName 'HD100' -ExecutionName '2026-06-10_103000'
                $session.Path | Should -Be (Join-Path (Join-Path $reportsRoot 'HD100') '2026-06-10_103000')
                Test-Path -LiteralPath $session.LogsPath | Should -BeTrue
                Test-Path -LiteralPath $session.BackupsPath | Should -BeTrue
            }
            finally {
                if (Test-Path -LiteralPath $reportsRoot) {
                    Remove-Item -LiteralPath $reportsRoot -Recurse -Force
                }
            }
        }
    }

    Context 'Documentacao estatica' {
        It 'Deve gerar indice HTML local' {
            $repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
            $outputPath = Join-Path ([System.IO.Path]::GetTempPath()) ('wba-docs-' + [guid]::NewGuid().ToString())
            $modulePath = Join-Path $repoRoot 'modules/WbaToolkit.Core/WbaToolkit.Core.psd1'

            $result = Export-ToolkitFunctionDocs -ModulePath $modulePath -OutputPath $outputPath -Force

            Test-Path -LiteralPath $result.Path | Should -BeTrue
            [System.IO.Path]::IsPathRooted($result.Path) | Should -BeTrue
            Test-Path -LiteralPath (Join-Path $outputPath 'functions/Export-ToolkitFunctionDocs.html') | Should -BeTrue
            Test-Path -LiteralPath (Join-Path $outputPath 'functions/Get-StaticDocsMetadata.html') | Should -BeFalse
            Test-Path -LiteralPath (Join-Path $outputPath 'scripts/Diagnostico-Reparo-HD100.ps1.html') | Should -BeTrue
            Test-Path -LiteralPath (Join-Path $outputPath 'scripts/limpeza-windows.ps1.html') | Should -BeTrue
            $result.ScriptCount | Should -BeGreaterThan 0

            $content = Get-Content -LiteralPath $result.Path -Raw
            $content | Should -Match 'Manual de Funcoes'
            $content | Should -Match 'Export-ToolkitFunctionDocs'
            $content | Should -Match 'Indice de scripts'
            $content | Should -Match 'Diagnostico-Reparo-HD100.ps1'
            $content | Should -Match 'limpeza-windows.ps1'

            $functionContent = Get-Content -LiteralPath (Join-Path $outputPath 'functions/Export-ToolkitFunctionDocs.html') -Raw
            $functionContent | Should -Match 'Metadados do manual'
            $functionContent | Should -Match 'Documentacao'

            $scriptContent = Get-Content -LiteralPath (Join-Path $outputPath 'scripts/limpeza-windows.ps1.html') -Raw
            $scriptContent | Should -Match 'Limpeza segura'
            $scriptContent | Should -Match 'Como executar'
        }

        It 'Deve resolver caminho relativo de saida a partir da localizacao atual do PowerShell' {
            $repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
            $modulePath = Join-Path $repoRoot 'modules/WbaToolkit.Core/WbaToolkit.Core.psd1'
            $relativeOutputPath = '.wba-docs-test-' + [guid]::NewGuid().ToString()

            Push-Location $repoRoot
            try {
                $result = Export-ToolkitFunctionDocs -ModulePath $modulePath -OutputPath $relativeOutputPath -Force

                [System.IO.Path]::IsPathRooted($result.Path) | Should -BeTrue
                $result.Path | Should -Match ([regex]::Escape($repoRoot))
                Test-Path -LiteralPath $result.Path | Should -BeTrue
                Test-Path -LiteralPath (Join-Path $repoRoot (Join-Path $relativeOutputPath 'index.html')) | Should -BeTrue
            }
            finally {
                Pop-Location
                $cleanupPath = Join-Path $repoRoot $relativeOutputPath
                if (Test-Path -LiteralPath $cleanupPath) {
                    Remove-Item -LiteralPath $cleanupPath -Recurse -Force
                }
            }
        }
    }
}

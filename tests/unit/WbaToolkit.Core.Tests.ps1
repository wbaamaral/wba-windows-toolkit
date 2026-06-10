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
}

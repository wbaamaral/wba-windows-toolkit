# Projeto: wba-toolkit
# Autor: wbaamaral

BeforeAll {
    $repoRoot   = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    $modulePath = Join-Path $repoRoot 'modules/WbaToolkit.Networking/WbaToolkit.Networking.psd1'

    Import-Module $modulePath -Force -ErrorAction Stop
}

Describe 'WbaToolkit.Networking' {
    Context 'Exportacao do modulo' {
        It 'Deve exportar Get-NetworkContext' {
            (Get-Command Get-NetworkContext -ErrorAction Stop).CommandType | Should -Be 'Function'
        }

        It 'Deve exportar Invoke-ConnectivityTest' {
            (Get-Command Invoke-ConnectivityTest -ErrorAction Stop).CommandType | Should -Be 'Function'
        }

        It 'Deve exportar Show-ConnectivityReport' {
            (Get-Command Show-ConnectivityReport -ErrorAction Stop).CommandType | Should -Be 'Function'
        }

        It 'Deve exportar Export-ConnectivityReport' {
            (Get-Command Export-ConnectivityReport -ErrorAction Stop).CommandType | Should -Be 'Function'
        }
    }

    Context 'Contrato dos testes' {
        It 'Get-NetworkContext deve retornar objeto' {
            $context = Get-NetworkContext
            $context | Should -BeOfType [psobject]
        }

        It 'Test-TcpPortConnectivity deve retornar objeto de resultado' {
            $result = Test-TcpPortConnectivity -TargetAddress '127.0.0.1' -Port 1 -TimeoutSeconds 1
            $result | Should -BeOfType [psobject]
            $result.PSObject.Properties.Name | Should -Contain 'Classification'
        }

        It 'Test-UdpPortConnectivity deve retornar objeto de resultado' {
            $result = Test-UdpPortConnectivity -TargetAddress '127.0.0.1' -Port 1 -TimeoutSeconds 1
            $result | Should -BeOfType [psobject]
            $result.PSObject.Properties.Name | Should -Contain 'Classification'
        }
    }

    Context 'Exportacao HTML' {
        It 'Deve gerar um arquivo HTML com o relatório' {
            $report = [pscustomobject]@{
                ReportId   = 'TEST-REPORT'
                FinishedAt = Get-Date
                Context    = [pscustomobject]@{
                    Hostname        = 'HOST'
                    Username        = 'USER'
                    InterfaceAlias  = 'Ethernet'
                    IPv4Address     = '192.168.1.10'
                    PrefixLength    = 24
                    Gateway         = '192.168.1.1'
                    DnsServers      = @('1.1.1.1', '8.8.8.8')
                }
                Summary    = [pscustomobject]@{
                    Total = 1
                    Success = 1
                    Failed = 0
                    Warning = 0
                    Inconclusive = 0
                }
                Results    = @(
                    [pscustomobject]@{
                        TestName       = 'Teste ICMP'
                        Protocol       = 'ICMP'
                        Classification = 'Success'
                        Target         = '8.8.8.8'
                        Port           = $null
                        LatencyMs      = 12.3
                        ErrorMessage   = $null
                        Recommendation = 'OK'
                    }
                )
                Blocked    = $false
                BlockReason = $null
            }

            $temp = Join-Path ([System.IO.Path]::GetTempPath()) 'wba-connectivity-test.html'
            if (Test-Path $temp) { Remove-Item $temp -Force }

            $export = Export-ConnectivityReport -Report $report -Path $temp
            Test-Path $export.Path | Should -BeTrue

            $content = Get-Content -LiteralPath $export.Path -Raw
            $content | Should -Match 'Relat[óo]rio de Conectividade'
            $content | Should -Match 'charset=utf-8'

            $bytes = [System.IO.File]::ReadAllBytes($export.Path)
            $bytes[0] | Should -Be 0xEF
            $bytes[1] | Should -Be 0xBB
            $bytes[2] | Should -Be 0xBF
        }
    }
}

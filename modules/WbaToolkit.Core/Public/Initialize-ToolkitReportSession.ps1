function Initialize-ToolkitReportSession {
    <#
    .SYNOPSIS
        Cria uma sessao padronizada de relatorio.

    .DESCRIPTION
        Resolve a raiz de relatorios, cria a pasta agrupadora do modulo, cria a subpasta da execucao com timestamp
        e devolve caminhos padronizados para relatorios, logs e backups.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ModuleName,

        [Parameter(Mandatory = $false)]
        [string]$ReportsRoot,

        [Parameter(Mandatory = $false)]
        [string]$ExecutionName = (Get-Date -Format 'yyyy-MM-dd_HHmmss'),

        [Parameter(Mandatory = $false)]
        [string]$ConfigPath
    )

    $root = Get-ToolkitReportsRoot -Path $ReportsRoot -ConfigPath $ConfigPath
    $modulePath = Join-Path $root $ModuleName
    $sessionPath = Join-Path $modulePath $ExecutionName
    $logsPath = Join-Path $sessionPath 'logs'
    $backupsPath = Join-Path $sessionPath 'backups'

    New-Item -Path $logsPath -ItemType Directory -Force | Out-Null
    New-Item -Path $backupsPath -ItemType Directory -Force | Out-Null

    return [pscustomobject]@{
        ReportsRoot = $root
        ModuleName = $ModuleName
        ModulePath = $modulePath
        ExecutionName = $ExecutionName
        Path = $sessionPath
        LogsPath = $logsPath
        BackupsPath = $backupsPath
    }
}

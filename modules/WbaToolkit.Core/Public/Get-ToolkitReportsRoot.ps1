function Get-ToolkitReportsRoot {
    <#
    .SYNOPSIS
        Resolve a raiz global de relatorios do toolkit.

    .DESCRIPTION
        Aplica a precedencia padronizada: caminho informado pelo usuario, configuracao persistente ReportsRoot e,
        por fim, C:\WBA\Relatorios.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [string]$ConfigPath
    )

    if (-not [string]::IsNullOrWhiteSpace($Path)) {
        return $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
    }

    $config = Get-ToolkitConfiguration -ConfigPath $ConfigPath
    if ($config.PSObject.Properties.Name -contains 'ReportsRoot' -and -not [string]::IsNullOrWhiteSpace($config.ReportsRoot)) {
        return $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath([string]$config.ReportsRoot)
    }

    return 'C:\WBA\Relatorios'
}

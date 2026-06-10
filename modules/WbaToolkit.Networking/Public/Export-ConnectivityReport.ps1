function Export-ConnectivityReport {
    <#
    .SYNOPSIS
        Exporta o relatório de conectividade para HTML.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [object]$Report,

        [Parameter(Mandatory = $false)]
        [string]$Path = (Get-Location).Path
    )

    if (Test-Path -LiteralPath $Path -PathType Container) {
        $fileName = 'Connectivity-{0}.html' -f $Report.ReportId
        $Path = Join-Path $Path $fileName
    }

    $html = ConvertTo-ConnectivityReportHtml -Report $Report
    $encoding = [System.Text.UTF8Encoding]::new($true)
    [System.IO.File]::WriteAllText($Path, $html, $encoding)

    [pscustomobject]@{
        Success = $true
        Path    = $Path
        Type    = 'HTML'
    }
}

function Export-ConnectivityReportPdf {
    <#
    .SYNOPSIS
        Exporta o relatório HTML para PDF quando houver navegador compatível.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$HtmlPath,

        [Parameter(Mandatory = $false)]
        [string]$PdfPath = ([System.IO.Path]::ChangeExtension($HtmlPath, '.pdf'))
    )

    $browser = @('msedge', 'msedge.exe', 'chromium', 'chromium-browser', 'google-chrome', 'google-chrome-stable') |
        ForEach-Object { Get-Command $_ -ErrorAction SilentlyContinue | Select-Object -First 1 } |
        Select-Object -First 1

    if (-not $browser) {
        return [pscustomobject]@{
            Success = $false
            Path    = $PdfPath
            Type    = 'PDF'
            Message = 'Nenhum navegador compatível foi encontrado para a exportação PDF.'
        }
    }

    $args = @(
        '--headless'
        '--disable-gpu'
        "--print-to-pdf=$PdfPath"
        $HtmlPath
    )

    try {
        $browserPath = if ($browser.Path) { $browser.Path } else { $browser.Source }
        & $browserPath @args | Out-Null
        [pscustomobject]@{
            Success = $true
            Path    = $PdfPath
            Type    = 'PDF'
        }
    }
    catch {
        [pscustomobject]@{
            Success = $false
            Path    = $PdfPath
            Type    = 'PDF'
            Message = $_.Exception.Message
        }
    }
}

function New-StaticDocsSlug {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    ($Name -replace '[^A-Za-z0-9_.-]', '-').Trim('-')
}

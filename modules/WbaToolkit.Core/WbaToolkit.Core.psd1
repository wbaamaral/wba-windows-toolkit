@{
    RootModule        = 'WbaToolkit.Core.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = '6b7a86d1-0d50-4d3a-88f3-25ad0f0f58bc'
    Author            = 'wbaamaral'
    CompanyName       = 'wbaamaral'
    Copyright         = '(c) wbaamaral. All rights reserved.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Test-IsAdministrator',
        'Invoke-Safe',
        'Format-FileSize',
        'Write-Ok',
        'Write-Fail',
        'Write-Warn',
        'Write-Info',
        'Write-Title',
        'Write-Section',
        'Read-YesNo',
        'Invoke-ExternalCommand',
        'ConvertTo-HtmlSafe'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
}

function Test-IsAdministrator {
    <#
    .SYNOPSIS
        Verifica se o processo atual possui elevacao administrativa.

    .DESCRIPTION
        Retorna $true quando o token atual esta no grupo de Administradores e $false
        quando o contexto nao estiver elevado ou quando a verificacao nao puder ser
        executada no ambiente atual.

    .EXAMPLE
        Test-IsAdministrator
    #>
    [CmdletBinding()]
    param()

    try {
        $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = [Security.Principal.WindowsPrincipal]::new($currentIdentity)

        return $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
    }
    catch {
        return $false
    }
}

function New-ConnectivityTestPlan {
    <#
    .SYNOPSIS
        Cria um plano de teste de conectividade estruturado.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string[]]$IpTargets = @('8.8.8.8', '8.8.4.4', '1.1.1.1', '9.9.9.9'),

        [Parameter(Mandatory = $false)]
        [string[]]$DnsTargets = @('www.google.com', 'www.microsoft.com', 'www.cloudflare.com', 'www.msftconnecttest.com'),

        [Parameter(Mandatory = $false)]
        [int]$TcpPort = 443,

        [Parameter(Mandatory = $false)]
        [switch]$Detailed
    )

    [pscustomobject]@{
        IpTargets  = @($IpTargets)
        DnsTargets = @($DnsTargets)
        TcpPort    = $TcpPort
        Detailed   = [bool]$Detailed
    }
}

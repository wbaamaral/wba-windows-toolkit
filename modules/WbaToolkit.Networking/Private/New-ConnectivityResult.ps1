function New-ConnectivityResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$TestName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Category,

        [Parameter(Mandatory = $false)]
        [string]$Protocol = 'N/A',

        [Parameter(Mandatory = $false)]
        [string]$Direction = 'N/A',

        [Parameter(Mandatory = $false)]
        [string]$Scope = 'N/A',

        [Parameter(Mandatory = $false)]
        [string]$Source = $env:COMPUTERNAME,

        [Parameter(Mandatory = $false)]
        [string]$Target = $null,

        [Parameter(Mandatory = $false)]
        [Nullable[int]]$Port = $null,

        [Parameter(Mandatory = $true)]
        [bool]$Success,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Status,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Classification,

        [Parameter(Mandatory = $false)]
        [Nullable[double]]$LatencyMs = $null,

        [Parameter(Mandatory = $false)]
        [string]$ErrorMessage = $null,

        [Parameter(Mandatory = $false)]
        [string]$Recommendation = $null,

        [Parameter(Mandatory = $false)]
        [datetime]$StartedAt = (Get-Date),

        [Parameter(Mandatory = $false)]
        [datetime]$FinishedAt = (Get-Date),

        [Parameter(Mandatory = $false)]
        [object]$Details = $null
    )

    [pscustomobject]@{
        TestId         = [guid]::NewGuid().ToString()
        TestName       = $TestName
        Category       = $Category
        Protocol       = $Protocol
        Direction      = $Direction
        Scope          = $Scope
        Source         = $Source
        Target         = $Target
        Port           = $Port
        Success        = $Success
        Status         = $Status
        Classification = $Classification
        LatencyMs      = $LatencyMs
        ErrorMessage   = $ErrorMessage
        Recommendation = $Recommendation
        StartedAt      = $StartedAt
        FinishedAt     = $FinishedAt
        Details        = $Details
    }
}

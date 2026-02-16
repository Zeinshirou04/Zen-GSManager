$Script:LogFile = $null

function Initialize-Logging {
    $logFolder = Join-Path $PSScriptRoot "..\Logs"

    if (!(Test-Path $logFolder)) {
        New-Item -ItemType Directory -Path $logFolder | Out-Null
    }

    $Script:LogFile = Join-Path $logFolder ("SwapLog_{0}.log" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
}

function Write-Log {
    param($Message, $Level = "INFO")
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $Script:LogFile -Value "[$time][$Level] $Message"
}

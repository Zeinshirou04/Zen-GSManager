. "$PSScriptRoot\Modules\Logging.ps1"
. "$PSScriptRoot\Modules\GameLoader.ps1"
. "$PSScriptRoot\Modules\GameState.ps1"
. "$PSScriptRoot\Modules\MoveEngine.ps1"
. "$PSScriptRoot\Modules\SwapWorkflow.ps1"
Get-Command Start-SwapProcess

. "$PSScriptRoot\Modules\ConsoleUI.ps1"

$Config = . "$PSScriptRoot\config.ps1"

Initialize-Logging

try {
    Show-Header -Version $Config.Application.Version
    Show-DriveStats -Active $Config.Slots.Active -Storage $Config.Slots.Storage

    Start-SwapProcess -Config $Config
}
catch {
    Write-Log "Fatal error: $_" "ERROR"
    Write-Host "A fatal error occurred. Check logs."
    exit 1
}

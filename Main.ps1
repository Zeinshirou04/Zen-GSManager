. "$PSScriptRoot\Modules\Logging.ps1"
. "$PSScriptRoot\Modules\GameLoader.ps1"
. "$PSScriptRoot\Modules\GameState.ps1"
. "$PSScriptRoot\Modules\MoveEngine.ps1"
. "$PSScriptRoot\Modules\SwapWorkflow.ps1"

. "$PSScriptRoot\Modules\ConsoleUI.ps1"

$Config = . "$PSScriptRoot\Config.ps1"
$RpReleasePath = Join-Path $PSScriptRoot "Releases\RichPresence\RichPresenceHelper.exe"
$Global:PresenceFile = Join-Path $PSScriptRoot "Releases\RichPresence\presence.json"

Initialize-Logging

try {
    $helperProcess = $null
    if (Test-Path $RpReleasePath) {
        $helperProcess = Start-Process $RpReleasePath -PassThru
        $tempFile = "$Global:PresenceFile.tmp"

        @{
            state          = "Idle"
            details        = "Waiting for game lists..."
            smallImageKey  = $g.SmallImageKey
            smallImageText = $g.Name
            startTimestamp = (Get-Date).ToUniversalTime().ToString("o")
        } | ConvertTo-Json -Compress |
        Set-Content -Path $tempFile -Encoding UTF8 -NoNewline

        Move-Item -Path $tempFile -Destination $Global:PresenceFile -Force
    }

    Show-Header -Version $Config.Application.Version
    Show-DriveStats -Active $Config.Slots.Active -Storage $Config.Slots.Storage

    Start-SwapProcess -Config $Config
    if ($helperProcess -and !$helperProcess.HasExited) {
        $helperProcess.Kill()
    }
}
catch {
    Write-Log "Fatal error: $_" "ERROR"
    Write-Host "A fatal error occurred. Check logs."
    exit 1
}

function Show-Status {
    param($Games)

    Write-Host ""
    Write-Host "Active in E:" -ForegroundColor Cyan

    $active = $Games | Where-Object { $_.State -eq "E" }

    if ($active.Count -eq 0) {
        Write-Host "  (No active games)" -ForegroundColor DarkGray
    }
    else {
        foreach ($g in $active) {
            $size = [math]::Round((Get-GameSize $g.EPath) / 1GB, 2)
            Write-Host ("  - {0} ({1}GB)" -f $g.Name, $size) -ForegroundColor White
        }
    }

    Write-Host ""
}

function Select-Game {
    param($Games)

    $stored = $Games | Where-Object { $_.State -eq "F" }

    if ($stored.Count -eq 0) {
        Write-Host ""
        Write-Host "No games available in storage." -ForegroundColor Yellow
        exit 0
    }

    Write-Host ""
    Write-Host "============================================" -ForegroundColor DarkCyan
    Write-Host "       Available Games (Storage)" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor DarkCyan
    Write-Host ""

    for ($i = 0; $i -lt $stored.Count; $i++) {
        $size = [math]::Round((Get-GameSize $stored[$i].FPath) / 1GB, 2)
        $name = $stored[$i].Name
        Write-Host ("  [{0}]  {1,-25} {2,8} GB" -f ($i + 1), $name, $size) -ForegroundColor White
    }

    Write-Host ""
    Write-Host "Please choose the number of the game you want to play:" -ForegroundColor Green
    Write-Host -NoNewline "> " -ForegroundColor Cyan

    $choice = Read-Host

    if (-not ($choice -match '^\d+$')) {
        Write-Host "Invalid selection." -ForegroundColor Red
        exit 1
    }

    return $stored[[int]$choice - 1]
}

function Start-SwapProcess {
    param($Config)

    Write-Log "Script started"

    $games = Get-Games $Config
    $games = Get-GameState $games

    Show-Status $games

    $selected = Select-Game $games

    $currentFree = Get-FreeSpace $Config.Slots.Active

    $currentEGames = $games | Where-Object { $_.State -eq "E" }

    $eSize = 0
    foreach ($g in $currentEGames) {
        $eSize += Get-GameSize $g.EPath
    }

    $capacity = $currentFree + $eSize

    $selectedSize = Get-GameSize $selected.FPath

    if ($selectedSize -gt $capacity) {
        throw "Selected game cannot fit into E."
    }

    $toMove = @($selected)
    $remaining = $capacity - $selectedSize

    while ($true) {

        $candidates = $games |
        Where-Object {
            $_.State -eq "F" -and
            $_.Name -notin $toMove.Name
        }

        $available = @()

        foreach ($g in $candidates) {
            $size = Get-GameSize $g.FPath
            if ($size -lt $remaining) {
                $available += $g
            }
        }

        if ($available.Count -eq 0) {
            break
        }

        Write-Host ""
        Write-Host ("Remaining capacity: {0} GB" -f ([math]::Round($remaining / 1GB, 2))) -ForegroundColor Cyan
        Write-Host ""

        for ($i = 0; $i -lt $available.Count; $i++) {
            $size = [math]::Round((Get-GameSize $available[$i].FPath) / 1GB, 2)
            Write-Host ("[{0}] {1,-25} {2,8} GB" -f ($i + 1), $available[$i].Name, $size)
        }

        Write-Host ""
        Write-Host "Choose number to add, S = Skip, C = Cancel"
        $input = (Read-Host ">").ToUpper()

        if ($input -eq "S") {
            break
        }

        if ($input -eq "C") {
            Write-Host "Operation cancelled."
            return
        }

        if ($input -match '^\d+$') {
            $index = [int]$input - 1

            if ($index -ge 0 -and $index -lt $available.Count) {
                $chosen = $available[$index]
                $size = Get-GameSize $chosen.FPath

                $toMove += $chosen
                $remaining -= $size
            }
        }
    }

    Write-Host ""
    Write-Host "Planned Moves:" -ForegroundColor Cyan

    foreach ($g in $toMove) {
        $size = [math]::Round((Get-GameSize $g.FPath) / 1GB, 2)
        Write-Host (" - {0} ({1}GB)" -f $g.Name, $size)
    }

    Write-Host ""
    Write-Host "Proceed? (Y/N)"
    $confirm = (Read-Host).ToUpper()

    if ($confirm -ne "Y") {
        Write-Host "Operation cancelled."
        return
    }

    Flush-E $games

    foreach ($g in $toMove) {
        Move-Game $g.FPath $g.EPath $g.Name $Config
    }

    Write-Log "Script finished successfully"
    Write-Host "Operation completed."
}

function Show-Status {
    param($Games)

    Write-Host ""
    Write-Host "Active in E:" -ForegroundColor Cyan

    $active = @($Games | Where-Object { $_.State -eq "E" })

    if ($active.Count -eq 0) {
        Write-Host "  (No active games)" -ForegroundColor DarkGray
    }
    else {
        foreach ($g in $active) {
            $size = [math]::Round(($g.SizeBytes / 1GB), 2)
            Write-Host ("  - {0} ({1}GB)" -f $g.Name, $size) -ForegroundColor White
        }
    }

    Write-Host ""
}

function Select-Game {
    param($Games)

    $stored = @($Games | Where-Object { $_.State -eq "F" })

    if ($stored.Count -eq 0) {
        Write-Host ""
        Write-Host "No games available in storage." -ForegroundColor Yellow
        return $null
    }

    Write-Host ""
    Write-Host "============================================" -ForegroundColor DarkCyan
    Write-Host "       Available Games (Storage)" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor DarkCyan
    Write-Host ""

    for ($i = 0; $i -lt $stored.Count; $i++) {
        $size = [math]::Round(($stored[$i].SizeBytes / 1GB), 2)
        $name = $stored[$i].Name
        Write-Host ("  [{0}]  {1,-25} {2,8} GB" -f ($i + 1), $name, $size) -ForegroundColor White
    }

    Write-Host ""
    Write-Host "Please choose the number of the game you want to play (Q to quit):" -ForegroundColor Green
    Write-Host -NoNewline "> " -ForegroundColor Cyan

    $choice = Read-Host

    if ($choice.ToUpper() -eq "Q") {
        return $null
    }

    if (-not ($choice -match '^\d+$')) {
        throw "Invalid selection '$choice'."
    }

    $index = [int]$choice - 1
    if ($index -lt 0 -or $index -ge $stored.Count) {
        throw "Selection '$choice' is out of range."
    }

    return $stored[$index]
}

function Invoke-MoveWithRecovery {
    param(
        $Source,
        $Destination,
        $Name,
        $Config
    )

    while ($true) {
        try {
            Move-Game -Source $Source -Destination $Destination -Name $Name -Config $Config
            return $true
        }
        catch {
            $errorText = $_.Exception.Message
            Write-Host ""
            Write-Host ("Move failed for '{0}': {1}" -f $Name, $errorText) -ForegroundColor Red
            Write-Host "Fix the issue (close game/launcher, free space, permissions) then choose:" -ForegroundColor Yellow
            Write-Host "  CONTINUE = retry move  |  SKIP = skip this game  |  ABORT = stop operation"

            $action = (Read-Host "> ").Trim().ToUpper()

            switch ($action) {
                "CONTINUE" {
                    Write-Log "Continue requested for $Name after failure"
                    continue
                }
                "SKIP" {
                    Write-Log "Skipped move for $Name after failure" "WARN"
                    return $false
                }
                "ABORT" {
                    throw "Operation aborted by user after move failure for $Name"
                }
                default {
                    Write-Host "Invalid option. Type CONTINUE, SKIP, or ABORT." -ForegroundColor Yellow
                }
            }
        }
    }
}

function Start-SwapProcess {
    param($Config)

    Write-Log "Script started"

    $games = Get-Games $Config
    $games = Get-GameState $games

    foreach ($g in $games) {
        $sizePath = if ($g.State -eq "E") { $g.EPath } else { $g.FPath }
        $size = Get-GameSize $sizePath
        $g | Add-Member -NotePropertyName SizeBytes -NotePropertyValue $size -Force
    }

    Show-Status $games

    $selected = Select-Game $games
    if ($null -eq $selected) {
        Write-Log "User exited without selecting a game"
        Write-Host "No game selected. Exiting."
        return
    }

    $currentFree = Get-FreeSpace $Config.Slots.Active
    $currentEGames = @($games | Where-Object { $_.State -eq "E" })

    $eSize = ($currentEGames | Measure-Object SizeBytes -Sum).Sum
    if ($null -eq $eSize) { $eSize = 0 }

    $capacity = $currentFree + $eSize

    $selectedSize = $selected.SizeBytes

    if ($selectedSize -gt $capacity) {
        throw ("Selected game cannot fit into E. Needed {0:N2} GB, available {1:N2} GB." -f ($selectedSize / 1GB), ($capacity / 1GB))
    }

    $toMove = @($selected)
    $remaining = $capacity - $selectedSize

    while ($true) {

        $candidates = @($games |
            Where-Object {
                $_.State -eq "F" -and
                $_.Name -notin $toMove.Name
            })

        $available = @($candidates | Where-Object { $_.SizeBytes -le $remaining })

        if ($available.Count -eq 0) {
            break
        }

        Write-Host ""
        Write-Host ("Remaining capacity: {0} GB" -f ([math]::Round($remaining / 1GB, 2))) -ForegroundColor Cyan
        Write-Host ""

        for ($i = 0; $i -lt $available.Count; $i++) {
            $size = [math]::Round(($available[$i].SizeBytes / 1GB), 2)
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
            Write-Log "Operation cancelled during selection"
            return
        }

        if ($input -match '^\d+$') {
            $index = [int]$input - 1

            if ($index -ge 0 -and $index -lt $available.Count) {
                $chosen = $available[$index]
                $toMove += $chosen
                $remaining -= $chosen.SizeBytes
            }
        }
    }

    Write-Host ""
    Write-Host "Planned Moves:" -ForegroundColor Cyan

    foreach ($g in $toMove) {
        $size = [math]::Round(($g.SizeBytes / 1GB), 2)
        Write-Host (" - {0} ({1}GB)" -f $g.Name, $size)
    }

    Write-Host ""
    Write-Host "Proceed? (Y/N)"
    $confirm = (Read-Host).ToUpper()

    if ($confirm -ne "Y") {
        Write-Host "Operation cancelled."
        Write-Log "Operation cancelled at confirmation"
        return
    }

    $requiredSpace = ($toMove | Measure-Object SizeBytes -Sum).Sum - $currentFree
    if ($requiredSpace -lt 0) { $requiredSpace = 0 }

    $toFlush = @()
    if ($requiredSpace -gt 0) {
        $freed = 0
        foreach ($g in ($currentEGames | Sort-Object SizeBytes -Descending)) {
            $toFlush += $g
            $freed += $g.SizeBytes
            if ($freed -ge $requiredSpace) { break }
        }

        if ($freed -lt $requiredSpace) {
            throw "Unable to free enough space in E for selected moves."
        }
    }

    foreach ($g in $toFlush) {
        Invoke-MoveWithRecovery -Source $g.EPath -Destination $g.FPath -Name $g.Name -Config $Config | Out-Null
    }

    foreach ($g in $toMove) {
        Invoke-MoveWithRecovery -Source $g.FPath -Destination $g.EPath -Name $g.Name -Config $Config | Out-Null
    }

    Write-Log "Script finished successfully"
    Write-Host "Operation completed."
}

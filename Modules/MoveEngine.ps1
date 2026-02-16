function Move-Game {
    param($Source, $Destination, $Name, $Config)

    try {
        Write-Log "Moving $Name from $Source to $Destination"

        $retry = $Config.Robocopy.RetryCount
        $wait  = $Config.Robocopy.WaitSeconds
        $mt    = $Config.Robocopy.MultiThread
        $verbose = $Config.Robocopy.VerboseByDefault

        $args = @(
            $Source
            $Destination
            "/E"
            "/MOVE"
            "/R:$retry"
            "/W:$wait"
            "/MT:$mt"
        )

        if (-not $verbose) {
            $args += "/NFL"
            $args += "/NDL"
        }

        $rcOutput = robocopy @args
        $rcOutput | ForEach-Object { Write-Log $_ }

        if ($LASTEXITCODE -ge 8) {
            throw "Robocopy failed with exit code $LASTEXITCODE"
        }

        Write-Log "Move completed for $Name"
    }
    catch {
        Write-Log "Move failed for $Name : $_" "ERROR"
        Write-Host "Move failed for $Name. Check logs."
        exit 1
    }
}


function Flush-E {
    param($Games, $Config)

    $activeGames = $Games | Where-Object { $_.State -eq "E" }

    foreach ($g in $activeGames) {
        Move-Game $g.EPath $g.FPath $g.Name $Config
    }
}

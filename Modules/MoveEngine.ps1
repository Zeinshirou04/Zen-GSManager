function Move-Game {
    param($Source, $Destination, $Name, $Config)

    Write-Log "Moving $Name from $Source to $Destination"

    $retry = $Config.Robocopy.RetryCount
    $wait  = $Config.Robocopy.WaitSeconds
    $mt    = $Config.Robocopy.MultiThread
    $verbose = $Config.Robocopy.Verbose
    if ($null -eq $verbose) { $verbose = $Config.Robocopy.VerboseByDefault }
    if ($null -eq $verbose) { $verbose = $true }
    $verbose = [bool]$verbose

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

    $output = robocopy @args
    foreach ($line in $output) {
        if ($verbose) {
            Write-Host $line
        }

        Write-Log $line
    }

    $exitCode = $LASTEXITCODE
    if ($exitCode -ge 8) {
        $message = "Robocopy failed for $Name with exit code $exitCode"
        Write-Log $message "ERROR"
        throw $message
    }

    Write-Log "Move completed for $Name"
}


function Flush-E {
    param($Games, $Config)

    $activeGames = $Games | Where-Object { $_.State -eq "E" }

    foreach ($g in $activeGames) {
        Move-Game $g.EPath $g.FPath $g.Name $Config
    }
}

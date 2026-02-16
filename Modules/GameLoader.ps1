function Get-Games {
    param($Config)

    $gameFolder = Join-Path $PSScriptRoot "..\Games"

    $games = @()

    Get-ChildItem $gameFolder -Filter *.ps1 | ForEach-Object {
        $game = & $_.FullName $Config
        $games += [pscustomobject]$game
    }

    return $games
}

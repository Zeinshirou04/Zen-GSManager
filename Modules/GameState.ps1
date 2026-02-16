function Get-GameState {
    param($Games)

    foreach ($g in $Games) {
        if (Test-Path $g.EPath) {
            $g | Add-Member -NotePropertyName State -NotePropertyValue "E" -Force
        }
        elseif (Test-Path $g.FPath) {
            $g | Add-Member -NotePropertyName State -NotePropertyValue "F" -Force
        }
        else {
            $g | Add-Member -NotePropertyName State -NotePropertyValue "Missing" -Force
        }
    }

    return $Games
}

function Get-GameSize {
    param($Path)

    if (!(Test-Path $Path)) { return 0 }

    return (Get-ChildItem -LiteralPath $Path -Recurse -Force |
            Measure-Object Length -Sum).Sum
}

function Get-FreeSpace {
    param($DriveLetter)

    return (Get-PSDrive $DriveLetter).Free
}

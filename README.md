```{=html}
<h1 align="center">
```
Game Swap Manager
```{=html}
</h1>
```
```{=html}
<p align="center">
```
Modular PowerShell storage orchestration tool for managing large game
libraries across multiple drives.
```{=html}
</p>
```
```{=html}
<p align="center">
```
`<img src="https://img.shields.io/badge/PowerShell-5.1+-5391FE?logo=powershell&logoColor=white" />`{=html}
`<img src="https://img.shields.io/badge/Platform-Windows-blue" />`{=html}
`<img src="https://img.shields.io/badge/License-MIT-green" />`{=html}
`<img src="https://img.shields.io/badge/Version-1.2.0-orange" />`{=html}
```{=html}
</p>
```

------------------------------------------------------------------------

## Overview

Game Swap Manager is a modular PowerShell-based tool designed to manage
large game libraries across multiple drives.

It enables controlled swapping between:

-   **Active Drive (E Slot)** -- Performance drive for currently played
    games\
-   **Storage Drive (F Slot)** -- Archive drive for unused games

The system performs capacity simulation before execution, ensuring safe
and predictable batch transfers.

------------------------------------------------------------------------

## Key Features

-   Modular architecture
-   Configuration-driven design
-   Interactive capacity planning
-   Batch execution (no partial swaps)
-   Automatic Active slot flush before activation
-   Smart remaining capacity calculation
-   Full process logging
-   Configurable Robocopy behavior
-   Safe failure termination

------------------------------------------------------------------------

## How It Works

1.  Loads all game definitions from the `Games` folder.

2.  Detects which games are currently Active or in Storage.

3.  Displays active games.

4.  Prompts user to select a primary game.

5.  Calculates:

    Total Capacity = Free Space (Active) + Size of Games Currently in
    Active

6.  Allows interactive addition of more games within remaining capacity.

7.  Displays a planned execution summary.

8.  Upon confirmation:

    -   Flushes Active → Storage
    -   Moves selected games Storage → Active

9.  Logs everything.

------------------------------------------------------------------------

## Project Structure

    GameSwapManager/
    │
    ├── Main.ps1
    ├── config.ps1
    │
    ├── Modules/
    │   ├── Logging.ps1
    │   ├── ConsoleUI.ps1
    │   ├── GameLoader.ps1
    │   ├── GameState.ps1
    │   ├── MoveEngine.ps1
    │   └── SwapWorkflow.ps1
    │
    ├── Games/
    │   ├── Game1.ps1
    │   ├── Game2.ps1
    │   └── ...
    │
    └── Logs/

------------------------------------------------------------------------

## Configuration Example

``` powershell
@{
    Application = @{
        Version = "1.2.0"
    }

    Slots = @{
        Active  = "E"
        Storage = "F"
    }

    Robocopy = @{
        RetryCount       = 2
        WaitSeconds      = 2
        MultiThread      = 8
        VerboseByDefault = $false
    }
}
```

------------------------------------------------------------------------

## Game Definition Template

``` powershell
param($Config)

$active  = $Config.Slots.Active
$storage = $Config.Slots.Storage

$activeRoot  = "$($active):\SteamLibrary\steamapps\common"
$storageRoot = "$($storage):\SteamLibrary\steamapps\common"

@{
    Name  = "Game Name"
    EPath = Join-Path $activeRoot  "Game Name"
    FPath = Join-Path $storageRoot "Game Name"
}
```

------------------------------------------------------------------------

## Requirements

-   Windows
-   PowerShell 5.1+
-   Robocopy (built-in)

------------------------------------------------------------------------

## Running

``` powershell
.\Main.ps1
```

If execution policy blocks:

``` powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

------------------------------------------------------------------------

## Logging

Logs are written to:

    Logs/SwapLog_YYYYMMDD_HHMMSS.log

Log levels:

-   INFO
-   ERROR

------------------------------------------------------------------------

## Safety Design

-   Terminates on Robocopy failure (exit code ≥ 8)
-   No partial execution
-   Capacity planning before any file operations
-   Explicit confirmation required

------------------------------------------------------------------------

## License

MIT License

Copyright (c) 2026 Farras Adhani Zayn

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

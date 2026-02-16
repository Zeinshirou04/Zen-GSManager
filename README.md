# Game Swap Manager

A modular PowerShell-based storage orchestration tool for managing large
game libraries across multiple drives.

Game Swap Manager allows you to intelligently plan and execute game
transfers between:

-   **Active Drive (E Slot)** -- Performance drive for currently played
    games\
-   **Storage Drive (F Slot)** -- Archive drive for unused games

The system calculates total usable capacity, lets you interactively
select which games to activate, and safely performs batch transfers
using Robocopy with full logging and failure protection.

------------------------------------------------------------------------

## Features

-   Modular architecture
-   Configuration-driven behavior
-   Interactive capacity planning
-   Batch execution (no partial swap execution)
-   Automatic E-slot flush before activation
-   Smart remaining capacity calculation
-   Full logging of operations, warnings, and errors
-   Configurable Robocopy behavior
-   Safe failure handling (terminates on error)

------------------------------------------------------------------------

## How It Works

1.  Loads all game definitions from the `Games` folder.

2.  Detects current state (games in Active and Storage).

3.  Displays currently active games.

4.  Prompts user to select a primary game to activate.

5.  Calculates total usable capacity:

    Total Capacity = Free Space on Active Drive + Size of Games
    Currently in Active

6.  Allows interactive selection of additional games that fit within
    remaining capacity.

7.  Displays a final planned move summary.

8.  Upon confirmation:

    -   Flushes all games from Active to Storage.
    -   Moves selected games from Storage to Active.

9.  Logs the entire process.

------------------------------------------------------------------------

## Project Structure

GameSwapManager/ │ ├── Main.ps1 ├── config.ps1 │ ├── Modules/ │ ├──
Logging.ps1 │ ├── ConsoleUI.ps1 │ ├── GameLoader.ps1 │ ├── GameState.ps1
│ ├── MoveEngine.ps1 │ └── SwapWorkflow.ps1 │ ├── Games/ │ ├── Game1.ps1
│ ├── Game2.ps1 │ └── ... │ └── Logs/

------------------------------------------------------------------------

## Configuration

`config.ps1` must return a hashtable:

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

## Game Definition Format

Each file inside `Games/` must return:

``` powershell
param($Config)

$active  = $Config.Slots.Active
$storage = $Config.Slots.Storage

$activeRoot  = "$($active):\SteamLibrary\steamapps\common"
$storageRoot = "$($storage):\SteamLibrary\steamapps\common"

@{
    Name  = "Counter-Strike Global Offensive"
    EPath = Join-Path $activeRoot  "Counter-Strike Global Offensive"
    FPath = Join-Path $storageRoot "Counter-Strike Global Offensive"
}
```

------------------------------------------------------------------------

## Requirements

-   Windows
-   PowerShell 5.1 or later
-   Robocopy (included with Windows)

------------------------------------------------------------------------

## Running the Program

Open PowerShell in the project directory:

``` powershell
.\Main.ps1
```

If execution policy blocks scripts:

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

-   Script terminates on Robocopy failure (exit code ≥ 8)
-   No partial swap execution
-   Capacity planning occurs before any file operations
-   Confirmation required before execution

------------------------------------------------------------------------

## License

### MIT License (Recommended)

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

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

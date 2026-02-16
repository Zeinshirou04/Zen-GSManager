function Show-Header {
    param($Version)

    Clear-Host

    $width = [console]::WindowWidth
    $title = "Zen Game Swap Manager"
    $ver   = "v$Version"

    Write-Host ("=" * $width) -ForegroundColor DarkCyan
    Write-Host ($title.PadLeft(($width + $title.Length)/2).PadRight($width)) -ForegroundColor Cyan
    Write-Host ($ver.PadLeft(($width + $ver.Length)/2).PadRight($width)) -ForegroundColor Gray
    Write-Host ("=" * $width) -ForegroundColor DarkCyan
    Write-Host ""
}

function Show-DriveStats {
    param($Active, $Storage)

    $e = Get-PSDrive $Active
    $f = Get-PSDrive $Storage

    $eFree  = [math]::Round($e.Free/1GB,2)
    $eUsed  = [math]::Round(($e.Used)/1GB,2)
    $eTotal = [math]::Round(($e.Used + $e.Free)/1GB,2)

    $fFree  = [math]::Round($f.Free/1GB,2)
    $fUsed  = [math]::Round(($f.Used)/1GB,2)
    $fTotal = [math]::Round(($f.Used + $f.Free)/1GB,2)

    Write-Host ("Detected: E slot looks empty / not managed") -ForegroundColor Green
    Write-Host ""

    Write-Host ("{0,-3} Free {1,8} GB | Used {2,8} GB | Total {3,8} GB" -f "($Active):\", $eFree, $eUsed, $eTotal) -ForegroundColor White
    Write-Host ("{0,-3} Free {1,8} GB | Used {2,8} GB | Total {3,8} GB" -f "($Storage):\", $fFree, $fUsed, $fTotal) -ForegroundColor White

    Write-Host ""
    Write-Host ("=" * [console]::WindowWidth) -ForegroundColor DarkCyan
}

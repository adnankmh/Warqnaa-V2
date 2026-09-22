param([switch]$NoBrowser)
$ErrorActionPreference='Stop'
$Root=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..'))
$Settings=Get-Content -LiteralPath (Join-Path $Root 'install-settings.local.json') -Raw | ConvertFrom-Json
$Registry=Join-Path $Root 'runtime.local.json'
$Records=New-Object System.Collections.Generic.List[object]
$Utf8=New-Object System.Text.UTF8Encoding($false)
$Backend=Join-Path $Root 'backend-laravel'
$Logs=Join-Path $Backend 'storage\logs'
New-Item -ItemType Directory -Path $Logs -Force | Out-Null
function Read-Records([string]$Path) {
    $parsed=Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    # Windows PowerShell 5.1 returns a top-level JSON array as one pipeline
    # object. Enumerate explicitly so every loop receives one record at a time.
    @($parsed | ForEach-Object { $_ })
}
if (Test-Path $Registry) {
    foreach ($record in @(Read-Records $Registry)) {
        $existing=Get-CimInstance Win32_Process -Filter "ProcessId=$([int]$record.pid)" -ErrorAction SilentlyContinue
        if ($existing -and $existing.ExecutablePath -eq $record.executable -and $existing.CreationDate.ToUniversalTime().ToString('o') -eq $record.created) {
            throw 'Warqnaa is already running. Use STOP_WARQNA_WINDOWS.bat before starting it again.'
        }
    }
}
function Launch([string]$Name,[string]$File,[string]$Arguments,[string]$At,[string]$Marker) {
    $stdout=Join-Path $Logs "$Name-out.log"
    $stderr=Join-Path $Logs "$Name-error.log"
    $launcher=Join-Path $Logs "$Name-service.cmd"
    $launcherText="@echo off`r`ncd /d `"$At`"`r`n`"$File`" $Arguments 1>>`"$stdout`" 2>>`"$stderr`"`r`n"
    [IO.File]::WriteAllText($launcher,$launcherText,$Utf8)
    # Win32_Process.Create starts the long-lived wrapper outside this
    # PowerShell process. This prevents inherited pipeline handles from
    # keeping the installer open while preserving per-service log files.
    $commandLine="cmd.exe /d /s /c `"`"$launcher`"`""
    $created=Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{CommandLine=$commandLine;CurrentDirectory=$At}
    if ([int]$created.ReturnValue -ne 0 -or [int]$created.ProcessId -le 0) { throw "$Name could not be started (Win32 error $($created.ReturnValue))." }
    Start-Sleep -Milliseconds 500
    $cim=Get-CimInstance Win32_Process -Filter "ProcessId=$([int]$created.ProcessId)" -ErrorAction SilentlyContinue
    if (!$cim) { throw "$Name exited immediately. See storage/logs." }
    $Records.Add(@{pid=[int]$created.ProcessId;executable=$cim.ExecutablePath;created=$cim.CreationDate.ToUniversalTime().ToString('o');marker=$launcher})
    [IO.File]::WriteAllText($Registry,(ConvertTo-Json -InputObject @($Records.ToArray()) -Depth 4),$Utf8)
    Write-Host "$Name started."
}
try {
    $router=Join-Path $Backend 'vendor\laravel\framework\src\Illuminate\Foundation\resources\server.php'
    if (!(Test-Path $router)) { throw 'Laravel router is missing; run the installer.' }
    $public=Join-Path $Backend 'public'
    Launch 'backend' $Settings.php "-S 127.0.0.1:$($Settings.port) -t `"$public`" `"$router`"" $public $router
    $web=Join-Path $Root 'flutter_app\build\web'
    if (!(Test-Path (Join-Path $web 'index.html'))) { throw 'Flutter web build is missing.' }
    Launch 'flutter-web' $Settings.python "-m http.server $($Settings.webPort) --bind 127.0.0.1 --directory `"$web`"" $web $web
    $artisan=Join-Path $Backend 'artisan'
    Launch 'scheduler' $Settings.php "`"$artisan`" schedule:work" $Backend $artisan
    if (!$NoBrowser) {
        Start-Process "http://127.0.0.1:$($Settings.port)"
        Start-Process "http://127.0.0.1:$($Settings.webPort)"
    }
} catch {
    foreach ($record in $Records) { & taskkill.exe /PID ([int]$record.pid) /T /F 2>$null | Out-Null }
    Write-Error $_
    exit 1
}

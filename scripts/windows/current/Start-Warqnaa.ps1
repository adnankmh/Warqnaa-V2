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
if (Test-Path $Registry) {
    foreach ($record in @(Get-Content $Registry -Raw | ConvertFrom-Json)) {
        $existing=Get-CimInstance Win32_Process -Filter "ProcessId=$([int]$record.pid)" -ErrorAction SilentlyContinue
        if ($existing -and $existing.ExecutablePath -eq $record.executable -and $existing.CreationDate.ToUniversalTime().ToString('o') -eq $record.created) {
            throw 'Warqnaa is already running. Use STOP_WARQNA_WINDOWS.bat before starting it again.'
        }
    }
}
function Launch([string]$Name,[string]$File,[string]$Arguments,[string]$At,[string]$Marker) {
    $process=Start-Process -FilePath $File -ArgumentList $Arguments -WorkingDirectory $At -PassThru -WindowStyle Hidden -RedirectStandardOutput (Join-Path $Logs "$Name-out.log") -RedirectStandardError (Join-Path $Logs "$Name-error.log")
    Start-Sleep -Milliseconds 500
    $cim=Get-CimInstance Win32_Process -Filter "ProcessId=$($process.Id)" -ErrorAction Stop
    if (!$cim) { throw "$Name exited immediately. See storage/logs." }
    $Records.Add(@{pid=$process.Id;executable=$cim.ExecutablePath;created=$cim.CreationDate.ToUniversalTime().ToString('o');marker=$Marker})
    [IO.File]::WriteAllText($Registry,(ConvertTo-Json -InputObject @($Records.ToArray()) -Depth 4),$Utf8)
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
    foreach ($record in $Records) { Stop-Process -Id $record.pid -ErrorAction SilentlyContinue }
    Write-Error $_
    exit 1
}

$ErrorActionPreference='Stop'
$Root=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..'))
$Registry=Join-Path $Root 'runtime.local.json'
if (!(Test-Path $Registry)) { Write-Host 'No registered Warqnaa services.'; exit 0 }
foreach ($record in @(Get-Content $Registry -Raw | ConvertFrom-Json)) {
    $proc=Get-CimInstance Win32_Process -Filter "ProcessId=$([int]$record.pid)" -ErrorAction SilentlyContinue
    if (!$proc) { continue }
    if ($proc.ExecutablePath -ne $record.executable -or $proc.CreationDate.ToUniversalTime().ToString('o') -ne $record.created -or !$proc.CommandLine.Contains($record.marker)) { throw 'Process identity changed. No unrelated process will be stopped.' }
    Stop-Process -Id $proc.ProcessId -ErrorAction Stop
}
Write-Host 'Warqnaa services stopped.'

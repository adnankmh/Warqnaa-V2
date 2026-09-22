$ErrorActionPreference='Stop'
$Root=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..'))
$Registry=Join-Path $Root 'runtime.local.json'
if (!(Test-Path $Registry)) { Write-Host 'No registered Warqnaa services.'; exit 0 }
function Read-Records([string]$Path) {
    $parsed=Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    @($parsed | ForEach-Object { $_ })
}
foreach ($record in @(Read-Records $Registry)) {
    $proc=Get-CimInstance Win32_Process -Filter "ProcessId=$([int]$record.pid)" -ErrorAction SilentlyContinue
    if (!$proc) { continue }
    if ($proc.ExecutablePath -ne $record.executable -or $proc.CreationDate.ToUniversalTime().ToString('o') -ne $record.created -or !$proc.CommandLine.Contains($record.marker)) { throw 'Process identity changed. No unrelated process will be stopped.' }
    & taskkill.exe /PID ([int]$proc.ProcessId) /T /F | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Could not stop registered service process $($proc.ProcessId)." }
}
Remove-Item -LiteralPath $Registry -Force
Write-Host 'Warqnaa services stopped.'

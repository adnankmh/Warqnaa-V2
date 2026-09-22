[CmdletBinding()]
param([switch]$ValidateOnly,[switch]$NoBrowser)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$Target = 'D:\warq'
$Stamp = Get-Date -Format 'yyyyMMdd-HHmmss-fff'
$Stage = "D:\warq-stage-$Stamp"
$Backup = "D:\warq-backup-$Stamp"
$Failed = "D:\warq-failed-$Stamp"
$Log = Join-Path $PSScriptRoot 'INSTALLATION_LOG.txt'
$Result = Join-Path $PSScriptRoot 'INSTALLATION_RESULT.json'
$Swapped = $false
$OldDown = $false
$OldStopped = $false
$OldMoved = $false
$Started = @()
$Gates = [ordered]@{}
$Utf8 = New-Object System.Text.UTF8Encoding($false)

function Step([string]$Message) {
    $line = "[$(Get-Date -Format HH:mm:ss)] $Message"
    Write-Host $line -ForegroundColor Cyan
    Add-Content -LiteralPath $Log -Value $line -Encoding UTF8
}
function Run([string]$Name, [string]$File, [string[]]$ArgsList, [string]$At) {
    Step $Name
    Push-Location $At
    try {
        $oldPreference = $ErrorActionPreference
        try {
            $ErrorActionPreference = 'Continue'
            & $File @ArgsList 2>&1 | Out-File -LiteralPath $Log -Append -Encoding UTF8
            $nativeExit = $LASTEXITCODE
        } finally { $ErrorActionPreference = $oldPreference }
        if ($nativeExit -ne 0) { $Gates[$Name] = 'FAILED'; throw "$Name failed; see INSTALLATION_LOG.txt" }
        $Gates[$Name] = 'PASS'
    } finally { Pop-Location }
}
function Exe([string[]]$Names, [string[]]$Paths) {
    foreach ($name in $Names) {
        $found = Get-Command $name -ErrorAction SilentlyContinue
        if ($found) { return $found.Source }
    }
    foreach ($path in $Paths) { if (Test-Path -LiteralPath $path -PathType Leaf) { return $path } }
    return $null
}
function EnvValue([string]$Path, [string]$Key, [string]$Fallback) {
    if (!(Test-Path -LiteralPath $Path)) { return $Fallback }
    $match = [regex]::Match((Get-Content -LiteralPath $Path -Raw), '(?m)^\s*'+[regex]::Escape($Key)+'\s*=\s*(.*?)\s*$')
    if (!$match.Success) { return $Fallback }
    return $match.Groups[1].Value.Trim().Trim('"').Trim("'")
}
function SetEnv([string]$Path, [string]$Key, [string]$Value) {
    $text = Get-Content -LiteralPath $Path -Raw
    $pattern = '(?m)^'+[regex]::Escape($Key)+'=.*$'
    $replacement = $Key+'='+$Value
    if ([regex]::IsMatch($text,$pattern)) {
        $text = [regex]::Replace($text,$pattern,[System.Text.RegularExpressions.MatchEvaluator]{param($m) $replacement})
    } else { $text += "`r`n$replacement`r`n" }
    [IO.File]::WriteAllText($Path,$text,$Utf8)
}
function CopyTree([string]$From,[string]$To) {
    if (!(Test-Path -LiteralPath $From)) { return }
    & robocopy $From $To /E /R:2 /W:1 /NFL /NDL /NJH /NJS /NP | Out-Null
    if ($LASTEXITCODE -gt 7) { throw 'Copy failed. Original files are retained.' }
}
function FreePort([int]$First,[int]$Last) {
    foreach ($candidate in $First..$Last) {
        $listener = $null
        try {
            $listener = New-Object System.Net.Sockets.TcpListener([Net.IPAddress]::Loopback,$candidate)
            $listener.Start(); return $candidate
        } catch { } finally { if ($listener) { $listener.Stop() } }
    }
    throw "No free local port between $First and $Last."
}
function StopOwned([string]$Root) {
    $registry = Join-Path $Root 'runtime.local.json'
    if (!(Test-Path -LiteralPath $registry)) { return }
    $records = @(Get-Content -LiteralPath $registry -Raw | ConvertFrom-Json)
    foreach ($record in $records) {
        $proc = Get-CimInstance Win32_Process -Filter "ProcessId=$([int]$record.pid)" -ErrorAction SilentlyContinue
        if (!$proc) { continue }
        # PID reuse cannot authorize termination: verify executable, creation time and marker.
        if ($proc.ExecutablePath -ne $record.executable -or $proc.CreationDate.ToUniversalTime().ToString('o') -ne $record.created -or !$proc.CommandLine.Contains($record.marker)) {
            throw 'A saved process identity changed; close the old Warqnaa windows manually before retrying.'
        }
        Stop-Process -Id $proc.ProcessId -ErrorAction Stop
    }
}

try {
    Set-Content -LiteralPath $Log -Value 'Warqnaa staged installer' -Encoding UTF8
    $package = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'release-package.json') -Raw | ConvertFrom-Json
    $ArchiveRoot = if ($package.root) { [string]$package.root } else { 'Warqnaa-V2-R6.5' }
    if ($ArchiveRoot -notmatch '^Warqnaa-V2-[A-Za-z0-9][A-Za-z0-9._-]*$') { throw 'Invalid archive root.' }
    if ($package.file -ne [IO.Path]::GetFileName($package.file)) { throw 'Invalid archive filename.' }
    $Archive = Join-Path $PSScriptRoot $package.file
    if ((Get-FileHash -LiteralPath $Archive -Algorithm SHA256).Hash -ne $package.sha256) { throw 'Archive checksum mismatch.' }
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [IO.Compression.ZipFile]::OpenRead($Archive)
    try {
        foreach ($entry in $zip.Entries) {
            $entryPath = $entry.FullName.Replace('\','/')
            if ($entryPath -match '(^|[/\\])\.\.([/\\]|$)|^[\\/]|:' -or !$entryPath.StartsWith($ArchiveRoot+'/')) { throw 'Unsafe archive path.' }
        }
        $metadataEntry = $zip.Entries | Where-Object { $_.FullName.Replace('\','/') -eq ($ArchiveRoot+'/RELEASE_VERSION.json') }
        if (@($metadataEntry).Count -ne 1) { throw 'Missing or duplicated release metadata.' }
        $reader = New-Object IO.StreamReader($metadataEntry.Open())
        try { $Release = $reader.ReadToEnd() | ConvertFrom-Json } finally { $reader.Dispose() }
        if ($Release.version -notmatch '^\d+\.\d+\.\d+$' -or [int]$Release.build -lt 650 -or $Release.full -ne ($Release.version+'+'+$Release.build)) { throw 'Invalid release metadata.' }
    } finally { $zip.Dispose() }
    $Gates['Package integrity'] = 'PASS'
    if ($ValidateOnly) { Step 'Package validation passed; no installation performed.'; exit 0 }
    foreach ($key in @('DB_URL','DB_DATABASE','DB_CONNECTION','APP_ENV','APP_KEY')) {
        if ([Environment]::GetEnvironmentVariable($key,'Process')) { throw "Remove inherited $key from this installer process before retrying; environment overrides could target the wrong database." }
    }
    if (!(Test-Path 'D:\')) { throw 'Drive D: is required.' }
    if ($PSScriptRoot.StartsWith($Target+'\',[StringComparison]::OrdinalIgnoreCase) -or $PSScriptRoot -eq $Target) { throw 'Extract the installer outside D:\warq before running it.' }
    if ((Get-PSDrive D).Free -lt 6442450944) { throw 'At least 6 GB free space is required on D:.' }
    $Php = Exe @('php.exe','php') @('C:\xampp\php\php.exe','D:\xampp\php\php.exe')
    $Python = Exe @('python.exe','python3.exe') @()
    $Git = Exe @('git.exe') @('C:\Program Files\Git\cmd\git.exe')
    if (!$Php -or !$Python) { throw 'Install PHP 8.2+ (XAMPP) and Python 3.10+ with PATH enabled, then rerun. Existing installation untouched.' }
    Run 'PHP and extensions' $Php @('-r','exit(PHP_VERSION_ID >= 80200 && extension_loaded("pdo_sqlite") && extension_loaded("sqlite3") && extension_loaded("mbstring") && extension_loaded("dom") && extension_loaded("openssl") ? 0 : 1);') $PSScriptRoot
    Run 'Python runtime' $Python @('-c','import sys;sys.exit(0 if sys.version_info >= (3,10) else 1)') $PSScriptRoot
    $OldEnv = Join-Path $Target 'backend-laravel\.env'
    if (Test-Path $Target) {
        if (!(Test-Path (Join-Path $Target 'RELEASE_VERSION.json')) -or !(Test-Path $OldEnv)) { throw 'D:\warq is not a recognized installed release. It was left untouched.' }
        $InstalledRelease = Get-Content -LiteralPath (Join-Path $Target 'RELEASE_VERSION.json') -Raw | ConvertFrom-Json
        if ([int]$InstalledRelease.build -gt [int]$Release.build) { throw 'The installed release is newer than this package. Downgrade refused; existing files are untouched.' }
        if ((EnvValue $OldEnv 'DB_CONNECTION' 'sqlite') -ne 'sqlite' -or (EnvValue $OldEnv 'DB_URL' '') -notin @('','null') -or (EnvValue $OldEnv 'APP_ENV' 'local') -ne 'local') { throw 'Automatic upgrade supports local SQLite only. External or production databases require a separate backup/deployment procedure; nothing was changed.' }
    }
    $ToolsRoot = 'D:\warq-tools'
    New-Item -ItemType Directory -Path $ToolsRoot -Force | Out-Null
    $Flutter = Exe @('flutter.bat') @('D:\warq-tools\flutter-3.44.0\bin\flutter.bat','C:\src\flutter\bin\flutter.bat','D:\flutter\bin\flutter.bat')
    if (!$Flutter) {
        if (!$Git) { throw 'Git is required to install Flutter automatically.' }
        $Sdk = Join-Path $ToolsRoot "flutter-3.44.0-$Stamp"
        Run 'Download Flutter 3.44.0' $Git @('clone','--depth','1','--branch','3.44.0','https://github.com/flutter/flutter.git',$Sdk) $ToolsRoot
        $Flutter = Join-Path $Sdk 'bin\flutter.bat'
    }
    $Composer = Exe @('composer.bat','composer.exe') @('C:\ProgramData\ComposerSetup\bin\composer.bat')
    if (!$Composer) {
        $setup = Join-Path $ToolsRoot "composer-setup-$Stamp.php"
        $signature = (Invoke-WebRequest 'https://composer.github.io/installer.sig' -UseBasicParsing).Content.Trim()
        Invoke-WebRequest 'https://getcomposer.org/installer' -OutFile $setup -UseBasicParsing
        if ((Get-FileHash $setup -Algorithm SHA384).Hash -ne $signature) { throw 'Composer installer signature mismatch.' }
        Run 'Install verified Composer' $Php @($setup,"--install-dir=$ToolsRoot",'--filename=composer.phar') $ToolsRoot
    }
    Step 'Extracting into an isolated staging directory'
    Expand-Archive -LiteralPath $Archive -DestinationPath $Stage
    $Source = Join-Path $Stage $ArchiveRoot
    $Backend = Join-Path $Source 'backend-laravel'
    $FlutterApp = Join-Path $Source 'flutter_app'
    Run 'Source regression gates' $Python @('tools\validate_release.py') $Source
    Run 'Source privacy' $Python @('tools\check_git_privacy_v304.py') $Source
    Copy-Item (Join-Path $Backend '.env.example') (Join-Path $Backend '.env')
    foreach ($directory in @('storage\framework\views','storage\framework\sessions','storage\framework\cache\data','bootstrap\cache')) { New-Item -ItemType Directory -Path (Join-Path $Backend $directory) -Force | Out-Null }
    if ($Composer) { Run 'Composer dependencies' $Composer @('install','--prefer-dist','--no-interaction','--no-progress') $Backend }
    else { Run 'Composer dependencies' $Php @((Join-Path $ToolsRoot 'composer.phar'),'install','--prefer-dist','--no-interaction','--no-progress') $Backend }
    # Tests always use an isolated in-memory DB; never the user's restored database.
    $testEnv = @('APP_ENV','DB_CONNECTION','DB_DATABASE','CACHE_STORE','SESSION_DRIVER','QUEUE_CONNECTION')
    $savedEnv = @{}
    foreach ($key in $testEnv) { $savedEnv[$key] = [Environment]::GetEnvironmentVariable($key,'Process') }
    try {
        $env:APP_ENV='testing'; $env:DB_CONNECTION='sqlite'; $env:DB_DATABASE=':memory:'; $env:CACHE_STORE='array'; $env:SESSION_DRIVER='array'; $env:QUEUE_CONNECTION='sync'
        Run 'Laravel focused runtime tests' $Php @('artisan','test','--filter=V700BootstrapPrivacyTest|V650OperationsAndPartyTest|V305SingleTableTest|V230SocialWorldTest|V240CompetitiveArenaTest') $Backend
    } finally { foreach ($key in $testEnv) { [Environment]::SetEnvironmentVariable($key,$savedEnv[$key],'Process') } }
    $Port = FreePort 8007 8016
    $WebPort = FreePort 8088 8098
    Run 'Flutter packages' $Flutter @('pub','get') $FlutterApp
    Run 'Flutter analysis' $Flutter @('analyze','--no-fatal-infos') $FlutterApp
    Run 'Flutter tests' $Flutter @('test') $FlutterApp
    Run 'Flutter web release' $Flutter @('build','web','--release',"--dart-define=WARQNA_API_URL=http://127.0.0.1:$Port/api/mobile/v1","--dart-define=WARQNA_APP_VERSION=$($Release.version)","--dart-define=WARQNA_APP_BUILD=$($Release.build)") $FlutterApp
    # No existing files have been modified before this point.
    if (Test-Path $Target) {
        $legacy = @(Get-CimInstance Win32_Process | Where-Object { $_.Name -match '^php' -and $_.CommandLine -match 'artisan\s+(serve|schedule:work|queue:work)' })
        if ($legacy.Count -gt 0 -and !(Test-Path (Join-Path $Target 'runtime.local.json'))) { throw 'Close old Warqnaa PHP command windows and rerun. Their ownership cannot be verified safely.' }
        StopOwned $Target
        $OldStopped = $true
        Run 'Pause old application' $Php @((Join-Path $Target 'backend-laravel\artisan'),'down') (Join-Path $Target 'backend-laravel')
        $OldDown = $true
        Copy-Item $OldEnv (Join-Path $Backend '.env') -Force
        $db = EnvValue $OldEnv 'DB_DATABASE' 'database/database.sqlite'
        if (![IO.Path]::IsPathRooted($db)) { $db = Join-Path (Join-Path $Target 'backend-laravel') $db }
        if (!(Test-Path -LiteralPath $db)) { throw 'Existing SQLite database is missing. Upgrade stopped to avoid replacing it with an empty database.' }
        $snapshot = Join-Path $Backend 'database\upgrade.sqlite'
        Run 'Consistent SQLite snapshot' $Php @((Join-Path $Source 'tools\windows\sqlite_snapshot.php'),$db,$snapshot) $Source
        Move-Item $snapshot (Join-Path $Backend 'database\database.sqlite') -Force
        CopyTree (Join-Path $Target 'backend-laravel\storage\app') (Join-Path $Backend 'storage\app')
        CopyTree (Join-Path $Target '.git') (Join-Path $Source '.git')
    } else { New-Item -ItemType File -Path (Join-Path $Backend 'database\database.sqlite') | Out-Null }
    $EnvFile = Join-Path $Backend '.env'
    SetEnv $EnvFile 'DB_CONNECTION' 'sqlite'
    SetEnv $EnvFile 'DB_DATABASE' 'database/database.sqlite'
    SetEnv $EnvFile 'DB_URL' 'null'
    SetEnv $EnvFile 'WARQNA_VERSION' ([string]$Release.version)
    SetEnv $EnvFile 'WARQNA_BUILD' ([string]$Release.build)
    SetEnv $EnvFile 'APP_URL' "http://127.0.0.1:$Port"
    SetEnv $EnvFile 'FRONTEND_URL' "http://127.0.0.1:$WebPort"
    SetEnv $EnvFile 'CORS_ALLOWED_ORIGINS' "http://127.0.0.1:$WebPort"
    if (!(EnvValue $EnvFile 'APP_KEY' '')) { Run 'Generate application key' $Php @('artisan','key:generate','--force') $Backend }
    Run 'Migrate staged data' $Php @('artisan','migrate','--force') $Backend
    # Seed only new installations. Re-seeding upgrades can reset customized store/settings.
    if (!(Test-Path $Target)) { Run 'Initial catalog and data' $Php @('artisan','db:seed','--force') $Backend }
    & $Php (Join-Path $Source 'tools\windows\admin_exists.php')
    $adminExit = $LASTEXITCODE
    if ($adminExit -notin @(0,2)) { throw 'Administrator existence check failed.' }
    if (!(Test-Path $Target) -or $adminExit -eq 2) {
        if (!$env:WARQNAA_ADNAN_ADMIN_EMAIL -or !$env:WARQNAA_ADNAN_ADMIN_PASSWORD) { throw 'Private administrator configuration is required for a new account.' }
        Run 'Provision new administrator' $Php @('artisan','warqnaa:setup-adnan-admin','--force') $Backend
    }
    Run 'Clear staged caches' $Php @('artisan','optimize:clear') $Backend
    [IO.File]::WriteAllText((Join-Path $Source 'install-settings.local.json'), (@{php=$Php;python=$Python;port=$Port;webPort=$WebPort}|ConvertTo-Json), $Utf8)
    if (Test-Path $Target) { Move-Item $Target $Backup; $OldMoved=$true }
    Move-Item $Source $Target
    $Swapped=$true
    $Backend = Join-Path $Target 'backend-laravel'
    Run 'Public uploads link' $Php @('artisan','storage:link') $Backend
    Run 'Enable upgraded application' $Php @('artisan','up') $Backend
    Run 'Start local services' 'powershell.exe' @('-NoProfile','-ExecutionPolicy','Bypass','-File',(Join-Path $Target 'scripts\windows\current\Start-Warqnaa.ps1'),'-NoBrowser') $Target
    $response = $null
    for ($attempt=0;$attempt -lt 15;$attempt++) {
        try { $response=Invoke-RestMethod "http://127.0.0.1:$Port/api/mobile/v1/health"; if ($response.ok) { break } } catch { }
        Start-Sleep -Seconds 1
    }
    if (!$response -or !$response.ok -or [int]$response.build -ne [int]$Release.build) { throw 'Post-install API health check failed.' }
    $web = Invoke-WebRequest "http://127.0.0.1:$WebPort/" -UseBasicParsing
    if ($web.StatusCode -ne 200) { throw 'Flutter web server check failed.' }
    $Gates['API and web HTTP smoke'] = 'PASS'
    [IO.File]::WriteAllText($Result, (@{status='PASSED';release=$Release.full;target=$Target;backup=$(if($OldMoved){$Backup}else{$null});gates=$Gates}|ConvertTo-Json -Depth 5),$Utf8)
    if (!$NoBrowser) {
        Start-Process "http://127.0.0.1:$Port"
        Start-Process "http://127.0.0.1:$WebPort"
    }
    Step 'Installation passed. See INSTALLATION_RESULT.json. Backups are retained.'
    exit 0
} catch {
    $failure = $_.Exception.Message
    Step ('FAILED: '+$failure)
    $rollback = 'not_needed'
    try {
        if ($Swapped) { StopOwned $Target; Move-Item $Target $Failed }
        if ($OldMoved) { Move-Item $Backup $Target }
        if ($OldDown) { & $Php (Join-Path $Target 'backend-laravel\artisan') up | Out-Null }
        if ($OldMoved -or $OldDown -or $OldStopped) { $rollback='files_restored_restart_required' }
    } catch { $rollback='manual_recovery_required'; Step "Recovery needs attention; backup remains at $Backup" }
    [IO.File]::WriteAllText($Result, (@{status='FAILED';message=$failure;rollback=$rollback;backup=$Backup;stage=$Stage;gates=$Gates}|ConvertTo-Json -Depth 5),$Utf8)
    exit 1
} finally {
    Remove-Item Env:WARQNAA_ADNAN_ADMIN_EMAIL -ErrorAction SilentlyContinue
    Remove-Item Env:WARQNAA_ADNAN_ADMIN_PASSWORD -ErrorAction SilentlyContinue
}

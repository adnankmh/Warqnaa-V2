<?php
// A consistent SQLite snapshot includes committed WAL records.
if ($argc !== 3 || !is_file($argv[1]) || file_exists($argv[2])) {
    fwrite(STDERR, "Expected an existing source and a new destination.\n"); exit(1);
}
$source = new SQLite3($argv[1], SQLITE3_OPEN_READONLY);
$source->busyTimeout(10000);
$destination = new SQLite3($argv[2]);
if (!$source->backup($destination)) { fwrite(STDERR, "SQLite backup failed.\n"); exit(1); }
$result = $destination->querySingle('PRAGMA integrity_check');
$destination->close(); $source->close();
if ($result !== 'ok') { fwrite(STDERR, "SQLite integrity check failed.\n"); exit(1); }
echo "SQLite snapshot verified.\n";

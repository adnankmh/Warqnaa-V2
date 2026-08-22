<?php

namespace App\Services\WarqnaPro;

use Illuminate\Support\Arr;

class AssetDeliveryService
{
    public function manifest(): array
    {
        $file = (string) config('warqna_assets.manifest_file');
        $payload = ['schema'=>1,'release'=>'R10','build'=>220,'mode'=>'hybrid','entries'=>[],'summary'=>[]];
        if (is_file($file)) {
            $decoded = json_decode((string) file_get_contents($file), true);
            if (is_array($decoded)) $payload = $decoded;
        }
        $mode = in_array(config('warqna_assets.mode'), ['local','hybrid','remote'], true)
            ? (string) config('warqna_assets.mode') : 'hybrid';
        $cdn = rtrim((string) config('warqna_assets.cdn_url'), '/');
        $payload['mode'] = $mode;
        $payload['cdn_enabled'] = $cdn !== '' && $mode !== 'local';
        $payload['data_saver_default'] = (bool) config('warqna_assets.data_saver_default', false);
        $payload['entries'] = array_values(array_map(function (array $entry) use ($cdn, $mode) {
            $remote = ltrim((string)($entry['remote_path'] ?? ''), '/');
            $thumb = ltrim((string)($entry['thumbnail_remote_path'] ?? ''), '/');
            $entry['url'] = ($cdn !== '' && $mode !== 'local' && $remote !== '') ? $cdn.'/'.$remote : null;
            $entry['thumbnail_url'] = ($cdn !== '' && $mode !== 'local' && $thumb !== '') ? $cdn.'/'.$thumb : null;
            // Do not leak internal server filesystem paths.
            unset($entry['remote_path'], $entry['thumbnail_remote_path']);
            return $entry;
        }, is_array($payload['entries'] ?? null) ? $payload['entries'] : []));
        return $payload;
    }

    public function summary(): array
    {
        $manifest = $this->manifest();
        return [
            'release' => 'R10',
            'schema' => (int)($manifest['schema'] ?? 1),
            'mode' => (string)($manifest['mode'] ?? 'hybrid'),
            'cdn_enabled' => (bool)($manifest['cdn_enabled'] ?? false),
            'manifest_url' => '/api/mobile/v1/assets/manifest',
            'manifest_ttl_seconds' => (int) config('warqna_assets.manifest_ttl_seconds', 21600),
            'data_saver_default' => (bool)($manifest['data_saver_default'] ?? false),
            'entries' => (int) Arr::get($manifest, 'summary.entries', count($manifest['entries'] ?? [])),
            'bundled_bytes' => (int) Arr::get($manifest, 'summary.bundled_bytes', 0),
            'ondemand_entries' => (int) Arr::get($manifest, 'summary.ondemand_entries', 0),
        ];
    }

    public function etag(): string
    {
        return '"'.hash('sha256', json_encode($this->manifest(), JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE)).'"';
    }
}

<?php

namespace App\Support;

/** Presentation only: catalogue identity, pricing and entitlements stay intact. */
final class R48TableArtwork
{
    public const DESIGNS = [
        'table_v173_royal_09' => 'purple',
        'table_v173_royal_21' => 'ocean',
        'table_v173_showcase_04' => 'eagle',
    ];

    public static function design(?string $key): ?string
    {
        $key = str_replace('-', '_', (string) $key);
        return self::DESIGNS[preg_replace('/^r61_cardback_/', '', $key)] ?? null;
    }

    public static function url(?string $key, bool $portrait = false): ?string
    {
        $design = self::design($key);
        return $design ? '/assets/store/r48/'.$design.($portrait ? '_portrait' : '_landscape').'.webp' : null;
    }
}

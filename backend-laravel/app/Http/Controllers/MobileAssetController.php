<?php

namespace App\Http\Controllers;

use App\Services\WarqnaPro\AssetDeliveryService;
use Illuminate\Http\Request;

class MobileAssetController extends Controller
{
    public function manifest(Request $request, AssetDeliveryService $assets)
    {
        $etag = $assets->etag();
        if ($request->headers->get('If-None-Match') === $etag) {
            return response('', 304)->header('ETag', $etag);
        }
        return response()->json($assets->manifest())
            ->header('ETag', $etag)
            ->header('Cache-Control', 'public, max-age='.(int)config('warqna_assets.manifest_ttl_seconds', 21600).', stale-while-revalidate=86400');
    }
}

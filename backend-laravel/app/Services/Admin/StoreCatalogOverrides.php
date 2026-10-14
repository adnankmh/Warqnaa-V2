<?php

namespace App\Services\Admin;

use App\Models\StoreItem;
use Illuminate\Support\Facades\{DB,Schema};

/** Administrator edits survive the shared catalogue's idempotent synchronization. */
class StoreCatalogOverrides
{
    public function save(StoreItem $item): void
    {
        DB::table('store_catalog_overrides')->updateOrInsert(['key'=>$item->key],[
            'operation'=>'upsert',
            'attributes'=>json_encode($item->only(['name','category','price','duration_days','payload','active']),JSON_UNESCAPED_UNICODE|JSON_THROW_ON_ERROR),
            'created_at'=>now(),'updated_at'=>now(),
        ]);
    }

    public function delete(string $key): void
    {
        DB::table('store_catalog_overrides')->updateOrInsert(['key'=>$key],[
            'operation'=>'delete','attributes'=>null,'created_at'=>now(),'updated_at'=>now(),
        ]);
    }

    public function apply(): void
    {
        if (!Schema::hasTable('store_catalog_overrides')) return;
        foreach (DB::table('store_catalog_overrides')->orderBy('key')->get() as $row) {
            if ($row->operation==='delete') {
                StoreItem::where('key',$row->key)->delete();
            } else {
                $attributes=json_decode((string)$row->attributes,true,512,JSON_THROW_ON_ERROR);
                StoreItem::updateOrCreate(['key'=>$row->key],$attributes);
            }
        }
    }
}

<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\{DB, Schema};

return new class extends Migration
{
    private function permissions(): array
    {
        return [
            'all'=>true,'users'=>true,'store'=>true,'rooms'=>true,'clubs'=>true,'tournaments'=>true,
            'economy'=>true,'security'=>true,'social_world'=>true,'designer'=>true,'moderation'=>true,
            'analytics'=>true,'settings'=>true,'releases'=>true,'support'=>true,
        ];
    }

    public function up(): void
    {
        if (!Schema::hasTable('users')) return;

        $now = now();
        $abd = DB::table('users')->whereRaw('LOWER(username) = ?', ['abd'])->first();
        $userPayload = [
            'is_admin' => true,
            'is_banned' => false,
            'updated_at' => $now,
        ];
        if (Schema::hasColumn('users', 'admin_role')) $userPayload['admin_role'] = 'delegated_admin';
        if (Schema::hasColumn('users', 'admin_permissions')) {
            $userPayload['admin_permissions'] = json_encode($this->permissions(), JSON_UNESCAPED_UNICODE);
        }

        if (!$abd) return; // Account creation/password provisioning is intentionally local/private in B304.
        DB::table('users')->where('id', $abd->id)->update($userPayload);
        $abdId = (int)$abd->id;

        if (Schema::hasTable('profiles')) {
            DB::table('profiles')->updateOrInsert(['user_id'=>$abdId],[
                'display_name'=>'Abd','avatar'=>'🛡️','country_code'=>'PS','country_name'=>'Palestine',
                'level'=>90,'xp'=>7800000,'games_played'=>12000,'wins'=>8000,
                'name_color'=>'#38bdf8','chat_color'=>'#38bdf8','pasha_days'=>365,'badge'=>'admin',
                'created_at'=>$now,'updated_at'=>$now,
            ]);
        }
        if (Schema::hasTable('wallets')) {
            DB::table('wallets')->updateOrInsert(['user_id'=>$abdId],[
                'tokens'=>10000000000000000,'gems'=>100000,'created_at'=>$now,'updated_at'=>$now,
            ]);
        }
    }

    public function down(): void
    {
        // Intentionally non-reversible: a rollback must never restore or guess a previous password.
    }
};

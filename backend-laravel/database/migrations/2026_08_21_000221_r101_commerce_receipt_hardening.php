<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
 public function up(): void {
  if(!Schema::hasTable('purchase_receipts')) return;
  Schema::table('purchase_receipts',function(Blueprint $t){
   if(!Schema::hasColumn('purchase_receipts','product_id')) $t->string('product_id',180)->nullable()->after('package_key');
   if(!Schema::hasColumn('purchase_receipts','transaction_id')) $t->string('transaction_id',190)->nullable()->index()->after('receipt_token');
   if(!Schema::hasColumn('purchase_receipts','amount_minor')) $t->unsignedBigInteger('amount_minor')->default(0)->after('status');
   if(!Schema::hasColumn('purchase_receipts','currency')) $t->string('currency',8)->default('USD')->after('amount_minor');
   if(!Schema::hasColumn('purchase_receipts','verified_at')) $t->timestamp('verified_at')->nullable()->after('currency');
  });
 }
 public function down(): void {}
};

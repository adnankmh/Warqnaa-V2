import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/api_client.dart';
import 'package:warqna_mobile/services/app_sounds.dart';

class MemoryStoreApi extends WarqnaApiClient {
  Map<String,dynamic> snapshot={};
  Map<String,dynamic>? lastPatch;
  int? lastExpectedPrice;
  bool failActivation=false;
  int activations=0;
  @override Future<Map<String,dynamic>> bootstrap() async=>snapshot;
  @override Future<Map<String,dynamic>> patch(String path,Map<String,dynamic> body) async {
    lastPatch=body;
    final row=Map<String,dynamic>.from((snapshot['store'] as List).first as Map)..addAll(body);
    snapshot['store']=[row];
    return {'ok':true,'item':row};
  }
  @override Future<Map<String,dynamic>> purchase(String key,{int? expectedPrice}) async {
    lastExpectedPrice=expectedPrice;return {'wallet':{'tokens':'875'}};
  }
  @override Future<Map<String,dynamic>> activateStoreItemV183(String key) async {
    if(failActivation)throw const ApiException('Activation rejected',statusCode:409);
    activations++;
    final inventory=Map<String,dynamic>.from((snapshot['inventory'] as List).first as Map)
      ..['activated_at']='2026-10-15T00:00:00Z';
    snapshot['inventory']=[inventory];
    return {'ok':true,'inventory_item':inventory,'profile':{'xp_boost_multiplier':2.0,'xp_boost_expires_at':'2099-01-01T00:00:00Z'}};
  }
}

void main() {
  setUp((){SharedPreferences.setMockInitialValues({});AppSounds.enabled=false;});
  Map<String,dynamic> row(String key)=>{
    'id':71,'key':key,'category':'pasha','name':{'ar':'عضوية معدلة','en':'Edited membership'},
    'price':125,'original_price':250,'discount_percent':50,'offer_cadence':'daily',
    'duration_days':14,'active':true,'payload':{'description_ar':'تفاصيل محفوظة'},
  };
  test('server quote and metadata override local defaults, and new catalogue items appear',() async {
    final api=MemoryStoreApi();final product=products.firstWhere((item)=>item.category=='pasha');
    api.snapshot={'store':[row(product.id),row('r36_new_membership')],'inventory':[
      {'store_item':{'key':product.id},'quantity':100,'active':false},
    ]};
    final controller=AppController(api:api)..serverConnected=true;
    controller.owned.add('previous_account_item');
    expect(await controller.refreshServerStoreR36(),isTrue);
    expect(controller.priceFor(product),125);
    expect(controller.nameFor(product,'ar'),'عضوية معدلة');
    expect(controller.durationFor(product),14);
    expect(controller.storeDiscountR36(product.id),50);
    expect(controller.storeProductsR36.map((item)=>item.id),contains('r36_new_membership'));
    expect(controller.owned,contains(product.id));
    expect(controller.owned,isNot(contains('previous_account_item')));
    controller.dispose();
  });
  test('administrator edits are sent to the server and remain visible after refresh',() async {
    final api=MemoryStoreApi();final product=products.firstWhere((item)=>item.category=='pasha');
    api.snapshot={'store':[row(product.id)]};
    final controller=AppController(api:api)..serverConnected=true..isAdmin=true..adminRole='primary_admin';
    await controller.refreshServerStoreR36();
    await controller.updateStoreProductAdmin(product,price:321,name:'حفظ مباشر',visible:false,durationDays:30);
    expect(api.lastPatch?['price'],321);
    expect(controller.priceFor(product),321);
    expect(controller.nameFor(product),'حفظ مباشر');
    expect(controller.durationFor(product),30);
    expect(controller.isStoreProductVisible(product),isFalse);
    controller.dispose();
  });
  test('checkout confirms the displayed server quote',() async {
    final api=MemoryStoreApi();final product=products.firstWhere((item)=>item.category=='pasha');
    api.snapshot={'store':[row(product.id)]};
    final controller=AppController(api:api)..serverConnected=true..coins=BigInt.from(1000);
    await controller.refreshServerStoreR36();
    expect(await controller.buy(product),isTrue);
    expect(api.lastExpectedPrice,125);
    expect(controller.coins,BigInt.from(875));
    controller.dispose();
  });
  test('primary administrator keeps 100 evergreen boosters after acknowledged activation',() async {
    final api=MemoryStoreApi();final product=products.firstWhere((item)=>item.category=='boost');
    api.snapshot={'inventory':[{'store_item':{'key':product.id,'category':'xp_booster'},'quantity':100,'active':false,'expires_at':null}]};
    final controller=AppController(api:api)..serverConnected=true..isAdmin=true..adminRole='primary_admin';
    await controller.refreshServerStoreR36();
    expect(controller.quantityForR36(product.id),100);
    expect(await controller.activateOwnedProductR36(product),isTrue);
    expect(await controller.activateOwnedProductR36(product),isTrue);
    expect(api.activations,2);
    expect(controller.quantityForR36(product.id),100);
    expect(controller.owned,contains(product.id));
    expect(controller.activeXpMultiplier,2.0);
    controller.dispose();
  });
  test('a rejected server activation never grants a local multiplier',() async {
    final api=MemoryStoreApi()..failActivation=true;final product=products.firstWhere((item)=>item.category=='boost');
    api.snapshot={'inventory':[{'store_item':{'key':product.id,'category':'xp_booster'},'quantity':1,'active':false}]};
    final controller=AppController(api:api)..serverConnected=true;
    await controller.refreshServerStoreR36();
    expect(await controller.activateOwnedProductR36(product),isFalse);
    expect(controller.activeXpMultiplier,1.0);
    expect(controller.quantityForR36(product.id),1);
    expect(controller.lastStoreError,isNotNull);
    controller.dispose();
  });
  test('ordinary booster stock sums unused purchases without restoring consumed or expired units',() {
    final controller=AppController();
    Map<String,dynamic> unit({String? activated,String? expiry,int quantity=1})=>{
      'store_item':{'key':'r36_stock','category':'xp_booster'},'quantity':quantity,
      'active':true,'activated_at':activated,'expires_at':expiry,
    };
    controller.syncPackInventoryV176([
      unit(activated:'2026-10-14'),unit(),unit(quantity:2),unit(expiry:'2020-01-01'),
    ]);
    expect(controller.quantityForR36('r36_stock'),3);
    expect(controller.owned,contains('r36_stock'));
    controller.syncPackInventoryV176([unit(activated:'2026-10-14')]);
    expect(controller.quantityForR36('r36_stock'),0);
    expect(controller.owned,isNot(contains('r36_stock')));
    controller.dispose();
  });
}

part of 'main.dart';

extension R36ServerStore on AppController {
  void syncServerStoreR36(dynamic rows, {bool replace = true}) {
    if (rows is! List) return;
    if (replace) serverStoreR36.clear();
    for (final raw in rows.whereType<Map>()) {
      final row=Map<String,dynamic>.from(raw);
      final key=row['key']?.toString() ?? '';
      if (key.isNotEmpty) serverStoreR36[key]=row;
    }
    serverStoreReadyR36=true;
  }

  Future<bool> refreshServerStoreR36() async {
    if (!serverConnected) return false;
    try {
      final data=await api.bootstrap();
      _applySession(data);
      lastStoreError=null;
      refreshUi();
      return true;
    } catch (error) {
      lastStoreError=friendlyErrorMessage(error,localeCode);
      return false;
    }
  }

  List<StoreProduct> get storeProductsR36 {
    final known=<String,StoreProduct>{for(final product in products) product.id:product};
    if (!serverConnected || !serverStoreReadyR36) return known.values.toList(growable:false);
    return serverStoreR36.entries.map((entry) {
      if (known.containsKey(entry.key)) return known[entry.key]!;
      final row=entry.value;
      final payload=row['payload'] is Map?Map<String,dynamic>.from(row['payload'] as Map):<String,dynamic>{};
      final names=row['name'] is Map?row['name'] as Map:const {};
      final category=const {'table':'tables','card_back':'cards','emoji_pack':'emoji','xp_booster':'boost',
        'name_color':'names','chat_color':'chat_colors','profile_color':'profile_colors','cover':'covers','theme':'themes'}[row['category']] ?? row['category']?.toString() ?? 'other';
      return StoreProduct(id:entry.key,category:category,icon:payload['preview_icon']?.toString() ?? '✦',
        nameAr:names['ar']?.toString() ?? entry.key,nameEn:names['en']?.toString() ?? entry.key,
        descriptionAr:payload['description_ar']?.toString() ?? '',descriptionEn:payload['description_en']?.toString() ?? '',
        price:int.tryParse(row['price']?.toString() ?? '') ?? 0,
        durationDays:int.tryParse(row['duration_days']?.toString() ?? ''),
        durationHours:int.tryParse(payload['duration_hours']?.toString() ?? ''),
        value:(payload['value'] ?? payload['color'] ?? payload['table'] ?? payload['card_back'] ?? payload['denomination'])?.toString(),
        multiplier:double.tryParse(payload['multiplier']?.toString() ?? ''),
        imageAsset:payload['asset']?.toString().startsWith('assets/')==true?payload['asset'].toString():null,
      );
    }).toList(growable:false);
  }

  Map<String,dynamic>? storeRowR36(String key) => serverConnected?serverStoreR36[key]:null;
  int storeDiscountR36(String key) => int.tryParse(storeRowR36(key)?['discount_percent']?.toString() ?? '') ?? 0;
  String? storeTextR36(StoreProduct product,String field,String language) {
    final row=storeRowR36(product.id);
    if (row==null) return null;
    final value=field=='name'?row['name']:(row['payload'] as Map?)?['description'];
    if (value is Map) return (value[language] ?? value['en'] ?? value['ar'])?.toString();
    return field=='description'?(row['payload'] as Map?)?['description_$language']?.toString():null;
  }

  Future<void> saveServerStoreProductR36(StoreProduct product,{int? price,bool? visible,String? name,
    String? description,int? durationDays,String? color1,String? color2}) async {
    if (!isAdmin) throw const ApiException('Administrator permission is required.');
    var row=serverStoreR36[product.id];
    if (row==null) {
      final dashboard=await api.adminDashboard();
      syncServerStoreR36(dashboard['store'],replace:false);
      row=serverStoreR36[product.id];
    }
    final id=int.tryParse(row?['id']?.toString() ?? '');
    if (id==null) throw const ApiException('This item is not available in the server catalogue.');
    final names=row?['name'] is Map?Map<String,dynamic>.from(row!['name'] as Map):<String,dynamic>{};
    final payload=row?['payload'] is Map?Map<String,dynamic>.from(row!['payload'] as Map):<String,dynamic>{};
    if (name!=null) names[localeCode]=name.trim();
    if (description!=null) payload['description_$localeCode']=description.trim();
    if (color1!=null || color2!=null) payload['gradient']=[color1 ?? colorToHex(color1For(product)),color2 ?? colorToHex(color2For(product))];
    final response=await api.patch('/admin/store/$id',{
      if(price!=null)'price':price,if(visible!=null)'active':visible,
      if(durationDays!=null && durationDays>0)'duration_days':durationDays,
      if(name!=null)'name':names,if(description!=null || color1!=null || color2!=null)'payload':payload,
    });
    final updated=response['item'];
    if(updated is Map) syncServerStoreR36([updated],replace:false);
    // Keep the editor's full catalogue, including inactive rows, while refreshing quotes.
    final full=Map<String,Map<String,dynamic>>.from(serverStoreR36);
    await refreshServerStoreR36();
    for(final entry in full.entries) {serverStoreR36.putIfAbsent(entry.key,()=>entry.value);}
    refreshUi();
  }
}

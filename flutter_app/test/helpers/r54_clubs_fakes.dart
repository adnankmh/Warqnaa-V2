import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';
import 'package:warqna_mobile/services/api_client.dart';

/// Synthetic catalogue shared by VM and Chrome journeys; never production data.
List<Map<String,dynamic>> catalogue(String locale) => [
  {'id':1,'name':locale=='ar'?'مجلس فرسان الورق والأصدقاء':'Knights Majlis and Friends',
    'description':locale=='ar'?'مجلس يجمع اللاعبين والفعاليات بروح الفريق واللعب النزيه.':'A majlis for players, club events and fair team play.',
    'league':{'ar':'ذهبي','en':'Gold'},'visibility':'public','members_count':8,'capacity':20,'weekly_points':12400},
  {'id':2,'name':locale=='ar'?'نجوم ورقنا':'Warqnaa Stars','league':{'ar':'فضي','en':'Silver'},
    'visibility':'request','members_count':4,'capacity':20,'weekly_points':3200},
  {'id':3,'name':locale=='ar'?'أساطير المجلس':'Majlis Legends','league':{'ar':'ماسي','en':'Diamond'},
    'visibility':'request','members_count':12,'capacity':20,'join_request_pending':true,'weekly_points':9200},
  {'id':4,'name':locale=='ar'?'المجلس الملكي':'Royal Majlis','league':{'ar':'أسطوري','en':'Legendary'},
    'visibility':'public','members_count':20,'capacity':20,'weekly_points':18200},
];

class ClubsApi extends WarqnaApiClient {
  ClubsApi(this.locale);
  final String locale;
  int loads=0,joins=0,details=0;
  int? joined,pending;
  Completer<Map<String,dynamic>>? nextLoad,joinResponse;
  Map<String,dynamic> snapshot() {
    final clubs=catalogue(locale).map((club)=><String,dynamic>{...club,
      if(joined==club['id'])'membership':{'role':'member'},
      if(pending==club['id'])'join_request_pending':true}).toList();
    return {'clubs':clubs,'my_club':joined==null?null:clubs.firstWhere((club)=>club['id']==joined)};
  }
  @override Future<Map<String,dynamic>> clubsWorldR11() async {
    loads++;return nextLoad==null?snapshot():await nextLoad!.future;
  }
  @override Future<Map<String,dynamic>> joinClubWorldR11(int id) async {
    joins++;
    if(joinResponse!=null)return await joinResponse!.future;
    pending=id;return {'ok':true,'status':'pending'};
  }
  @override Future<Map<String,dynamic>> clubWorldR11(int id) async {
    details++;return {'club':{...catalogue(locale).firstWhere((club)=>club['id']==id),'members':[]},
      'membership':null,'announcements':[],'events':[],'join_requests':[]};
  }
}

class ClubsController extends AppController {
  ClubsController(this.fake);
  final ClubsApi fake;
  @override WarqnaApiClient get api=>fake;
}

/// Build lazily-scrolled sections before locating a target, and pump the new
/// viewport transform before hit testing. Never bypass the actual action.
Future<void> revealClubWidget(WidgetTester tester,Finder target) async {
  final scroll=find.descendant(of:find.byKey(const ValueKey('r54-clubs-scroll')),
    matching:find.byType(Scrollable)).first;
  if(target.evaluate().isEmpty) {
    tester.state<ScrollableState>(scroll).position.jumpTo(0);await tester.pump();
    await tester.scrollUntilVisible(target,180,scrollable:scroll,maxScrolls:40);
  }
  await tester.ensureVisible(target);await tester.pumpAndSettle();
}

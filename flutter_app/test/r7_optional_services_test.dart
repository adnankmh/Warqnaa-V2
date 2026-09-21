import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warqna_mobile/services/app_notifications.dart';
import 'package:warqna_mobile/services/r10_asset_delivery.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('missing native notification registration cannot break login', () async {
    expect(PushNotifications.configured, isFalse);
    expect(await PushNotifications.initialize(), isNull);
    // Failed initialization remains retryable rather than marking it ready.
    expect(await PushNotifications.initialize(), isNull);
    await PushNotifications.dispose();
  });

  testWidgets('asset notifications update mounted images synchronously', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final delivery = R10AssetDelivery.instance;
    await tester.pumpWidget(const MaterialApp(
      home: R10AssetImage(localAsset: 'assets/images/brand/warqna_logo.png'),
    ));
    // No image decoding is needed to exercise the notification callback.
    delivery.clearMemoryCache();
    expect(tester.takeException(), isNull);
    delivery.clearMemoryCache();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    delivery.clearMemoryCache();
    expect(tester.takeException(), isNull);
  });
}

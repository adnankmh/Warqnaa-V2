import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  test('R113 physical orientation lock is limited to native phones', () {
    for (final platform in <TargetPlatform>[
      TargetPlatform.android,
      TargetPlatform.iOS,
    ]) {
      expect(
        supportsPhysicalOrientationLockV185(
          isWeb: false,
          platform: platform,
        ),
        isTrue,
      );
      expect(
        supportsPhysicalOrientationLockV185(
          isWeb: true,
          platform: platform,
        ),
        isFalse,
      );
    }

    for (final platform in <TargetPlatform>[
      TargetPlatform.linux,
      TargetPlatform.macOS,
      TargetPlatform.windows,
      TargetPlatform.fuchsia,
    ]) {
      expect(
        supportsPhysicalOrientationLockV185(
          isWeb: false,
          platform: platform,
        ),
        isFalse,
      );
    }
  });

  test('R113 phone orientation defaults portrait and landscape is explicit', () {
    expect(
      preferredPhoneOrientationsV185(false),
      <DeviceOrientation>[DeviceOrientation.portraitUp],
    );
    expect(
      preferredPhoneOrientationsV185(true),
      <DeviceOrientation>[
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
    );
  });
}

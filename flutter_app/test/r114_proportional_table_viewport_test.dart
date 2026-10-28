import 'package:flutter_test/flutter_test.dart';
import 'package:warqna_mobile/main.dart';

void main() {
  test('R114 phone and tablet tables keep all available width', () {
    expect(
      proportionalTableWidthV186(
        availableWidth: 390,
        tableHeight: 520,
        desktop: false,
      ),
      390,
    );
    expect(
      proportionalTableWidthV186(
        availableWidth: 844,
        tableHeight: 390,
        desktop: false,
      ),
      844,
    );
  });

  test('R114 desktop table stays near two thirds of a normal viewport', () {
    expect(
      proportionalTableWidthV186(
        availableWidth: 1440,
        tableHeight: 800,
        desktop: true,
      ),
      closeTo(950.4, .001),
    );
  });

  test('R114 ultrawide table is also bounded by its height', () {
    expect(
      proportionalTableWidthV186(
        availableWidth: 2560,
        tableHeight: 480,
        desktop: true,
      ),
      closeTo(792, .001),
    );
  });

  test('R114 table width never exceeds the available viewport', () {
    expect(
      proportionalTableWidthV186(
        availableWidth: 700,
        tableHeight: 900,
        desktop: true,
      ),
      closeTo(462, .001),
    );
    expect(
      proportionalTableWidthV186(
        availableWidth: -1,
        tableHeight: 500,
        desktop: true,
      ),
      0,
    );
  });
}

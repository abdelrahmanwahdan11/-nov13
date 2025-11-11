import 'package:flutter_test/flutter_test.dart';

import 'package:voxa/ui/widgets/password_strength_meter.dart';

void main() {
  group('computePasswordScore', () {
    test('scores increase with complexity', () {
      expect(computePasswordScore('abc'), 0);
      expect(computePasswordScore('abc123'), greaterThanOrEqualTo(1));
      expect(computePasswordScore('Abc123'), greaterThanOrEqualTo(2));
      expect(computePasswordScore('Abc123!'), 3);
    });
  });
}

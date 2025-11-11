import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:voxa/controllers/auth_controller.dart';
import 'package:voxa/ui/pages/auth/auth_pages.dart';

void main() {
  testWidgets('Sign up page matches design', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SignUpPage(controller: AuthController()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sign Up'), findsOneWidget);
  }, skip: true);
}

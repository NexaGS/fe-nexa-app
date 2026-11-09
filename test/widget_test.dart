import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fe_nexa_app/app/app.dart';
import 'package:fe_nexa_app/app/theme/nexa_colors.dart';

void main() {
  testWidgets('NexaApp sobe com o tema Porcelana', (tester) async {
    await tester.pumpWidget(const NexaApp());

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme?.scaffoldBackgroundColor, NexaColors.background);
  });
}

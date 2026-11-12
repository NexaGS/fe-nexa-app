import 'package:fe_nexa_app/shared/widgets/nexa_samu_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_de_teste.dart';

void main() {
  testWidgets('tocar em SAMU 192 pergunta antes de ligar', (tester) async {
    await tester.pumpWidget(appDeTeste(const NexaSamuButton()));

    await tester.tap(find.text('SAMU 192'));
    await tester.pumpAndSettle();

    expect(find.text('Sintomas graves?'), findsOneWidget);
    expect(find.text('Ligar para o 192'), findsOneWidget);
    expect(find.text('Agora não'), findsOneWidget);
  });

  testWidgets('"Agora não" só fecha o aviso, sem tentar ligar', (tester) async {
    await tester.pumpWidget(appDeTeste(const NexaSamuButton()));

    await tester.tap(find.text('SAMU 192'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agora não'));
    await tester.pumpAndSettle();

    expect(find.text('Sintomas graves?'), findsNothing);
    // Se tivesse tentado ligar e falhado, o aviso de erro apareceria.
    expect(find.byType(SnackBar), findsNothing);
  });
}

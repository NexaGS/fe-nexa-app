import 'package:fe_nexa_app/features/unidades/nexa_linha_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_de_teste.dart';

void main() {
  testWidgets('mostra rótulo e valor', (tester) async {
    await tester.pumpWidget(
      appDeTeste(
        const NexaLinhaInfo(
          iconName: 'pin',
          rotulo: 'Endereço',
          valor: 'Rua das Acácias, 120',
        ),
      ),
    );

    expect(find.text('Endereço'), findsOneWidget);
    expect(find.text('Rua das Acácias, 120'), findsOneWidget);
  });

  testWidgets('a ação aparece à direita e funciona', (tester) async {
    var toques = 0;
    await tester.pumpWidget(
      appDeTeste(
        NexaLinhaInfo(
          iconName: 'phone',
          rotulo: 'Telefone',
          valor: '(11) 5555-0142',
          mostrarDivisor: false,
          acao: IconButton(
            tooltip: 'Ligar',
            onPressed: () => toques++,
            icon: const Icon(Icons.call),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Ligar'));

    expect(toques, 1);
  });
}

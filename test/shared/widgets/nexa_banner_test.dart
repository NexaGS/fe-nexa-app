import 'package:fe_nexa_app/shared/widgets/nexa_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_de_teste.dart';

void main() {
  testWidgets('mostra a mensagem e o link, e o link chama a ação', (
    tester,
  ) async {
    var toques = 0;
    await tester.pumpWidget(
      appDeTeste(
        NexaBanner(
          mensagem: 'Mostrando dados de há 12 min',
          rotuloAcao: 'Tentar de novo',
          aoAcionar: () => toques++,
        ),
      ),
    );

    expect(find.text('Mostrando dados de há 12 min'), findsOneWidget);
    await tester.tap(find.text('Tentar de novo'));

    expect(toques, 1);
    expect(find.byType(TextButton), findsOneWidget);
  });

  testWidgets('com acaoEmBotao, a ação vira botão de contorno', (tester) async {
    var toques = 0;
    await tester.pumpWidget(
      appDeTeste(
        NexaBanner(
          tom: NexaBannerTom.informativo,
          mensagem: 'Suas favoritas estão só neste aparelho.',
          rotuloAcao: 'Criar conta',
          aoAcionar: () => toques++,
          acaoEmBotao: true,
        ),
      ),
    );

    await tester.tap(find.text('Criar conta'));

    expect(toques, 1);
    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(find.byType(TextButton), findsNothing);
  });

  testWidgets('sem rótulo ou sem ação, não aparece botão nenhum', (tester) async {
    await tester.pumpWidget(
      appDeTeste(
        const NexaBanner(mensagem: 'Só o aviso', rotuloAcao: 'Tentar de novo'),
      ),
    );

    expect(find.text('Só o aviso'), findsOneWidget);
    expect(find.byType(TextButton), findsNothing);
    expect(find.byType(OutlinedButton), findsNothing);
  });
}

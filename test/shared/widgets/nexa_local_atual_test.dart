import 'package:fe_nexa_app/shared/widgets/nexa_local_atual.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_de_teste.dart';

void main() {
  testWidgets('com ação: mostra o link e avisa ao tocar', (tester) async {
    var toques = 0;
    await tester.pumpWidget(
      appDeTeste(
        NexaLocalAtual(local: 'Vila Nova, São Paulo', aoAlterar: () => toques++),
      ),
    );

    expect(find.text('Vila Nova, São Paulo'), findsOneWidget);
    await tester.tap(find.text('Alterar'));
    expect(toques, 1);
  });

  testWidgets('sem ação: o link nem aparece', (tester) async {
    await tester.pumpWidget(
      appDeTeste(const NexaLocalAtual(local: 'Vila Nova, São Paulo')),
    );

    expect(find.text('Vila Nova, São Paulo'), findsOneWidget);
    expect(find.text('Alterar'), findsNothing);
  });
}

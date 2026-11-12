import 'package:fe_nexa_app/shared/widgets/nexa_favorito_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_de_teste.dart';

void main() {
  testWidgets('toque chama aoAlternar', (tester) async {
    var toques = 0;
    await tester.pumpWidget(
      appDeTeste(
        NexaFavoritoButton(favorita: false, aoAlternar: () => toques++),
      ),
    );

    await tester.tap(find.byType(IconButton));

    expect(toques, 1);
  });

  testWidgets('o texto do leitor de tela muda com o estado', (tester) async {
    await tester.pumpWidget(
      appDeTeste(
        NexaFavoritoButton(
          favorita: false,
          aoAlternar: () {},
          nomeDaUnidade: 'Unidade B',
        ),
      ),
    );
    expect(find.byTooltip('Adicionar às favoritas: Unidade B'), findsOneWidget);

    await tester.pumpWidget(
      appDeTeste(
        NexaFavoritoButton(
          favorita: true,
          aoAlternar: () {},
          nomeDaUnidade: 'Unidade B',
        ),
      ),
    );
    expect(find.byTooltip('Remover das favoritas: Unidade B'), findsOneWidget);
  });

  testWidgets('sem aoAlternar o botão fica desabilitado', (tester) async {
    await tester.pumpWidget(
      appDeTeste(const NexaFavoritoButton(favorita: false, aoAlternar: null)),
    );

    expect(tester.widget<IconButton>(find.byType(IconButton)).onPressed, isNull);
  });
}

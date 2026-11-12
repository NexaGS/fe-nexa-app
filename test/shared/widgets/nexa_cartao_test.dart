import 'package:fe_nexa_app/shared/widgets/nexa_cartao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_de_teste.dart';

void main() {
  testWidgets('mostra o miolo dentro da moldura', (tester) async {
    await tester.pumpWidget(
      appDeTeste(const NexaCartao(child: Text('dentro do cartão'))),
    );

    expect(find.text('dentro do cartão'), findsOneWidget);
  });

  testWidgets('sem aoTocar não é um botão', (tester) async {
    await tester.pumpWidget(
      appDeTeste(const NexaCartao(child: Text('dentro do cartão'))),
    );

    expect(find.byType(InkWell), findsNothing);
  });

  testWidgets('com aoTocar, o cartão inteiro responde ao toque', (
    tester,
  ) async {
    var toques = 0;
    await tester.pumpWidget(
      appDeTeste(
        NexaCartao(
          aoTocar: () => toques++,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Text('dentro do cartão'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('dentro do cartão'));

    expect(toques, 1);
    expect(find.byType(InkWell), findsOneWidget);
  });

  testWidgets('um botão dentro do cartão recebe o toque sem acionar o cartão', (
    tester,
  ) async {
    var cartao = 0;
    var botao = 0;
    await tester.pumpWidget(
      appDeTeste(
        NexaCartao(
          aoTocar: () => cartao++,
          child: TextButton(onPressed: () => botao++, child: const Text('ok')),
        ),
      ),
    );

    await tester.tap(find.text('ok'));

    expect((cartao, botao), (0, 1));
  });
}

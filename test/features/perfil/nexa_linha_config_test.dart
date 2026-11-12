import 'package:fe_nexa_app/features/perfil/nexa_linha_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_de_teste.dart';

void main() {
  testWidgets('mostra título e apoio, e a chave avisa o novo valor', (
    tester,
  ) async {
    bool? recebido;
    await tester.pumpWidget(
      appDeTeste(
        NexaLinhaConfig(
          titulo: 'Usar minha localização',
          descricao: 'Só usamos para ordenar por distância.',
          ativa: false,
          aoAlterar: (valor) => recebido = valor,
        ),
      ),
    );

    expect(find.text('Usar minha localização'), findsOneWidget);
    expect(find.text('Só usamos para ordenar por distância.'), findsOneWidget);

    await tester.tap(find.byType(Switch));

    expect(recebido, isTrue);
  });

  testWidgets('sem aoAlterar a chave fica desabilitada', (tester) async {
    await tester.pumpWidget(
      appDeTeste(
        const NexaLinhaConfig(
          titulo: 'Usar minha localização',
          ativa: true,
          aoAlterar: null,
        ),
      ),
    );

    expect(tester.widget<Switch>(find.byType(Switch)).onChanged, isNull);
  });
}

import 'package:fe_nexa_app/features/unidades/nexa_folha_espera.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_espera_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_de_teste.dart';

Future<void> abrirFolhaDaEspera(WidgetTester tester) async {
  await tester.pumpWidget(
    appDeTeste(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => mostrarFolhaEspera(context),
          child: const Text('abrir'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('explica como a espera é calculada', (tester) async {
    await abrirFolhaDaEspera(tester);

    expect(find.text('Como calculamos a espera'), findsOneWidget);
    expect(
      find.text('Contamos quantas pessoas estão aguardando agora.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Comparamos com o tempo que a unidade levou para atender nas '
        'últimas horas.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('a legenda mostra as três faixas com as horas de cada uma', (
    tester,
  ) async {
    await abrirFolhaDaEspera(tester);

    expect(find.byType(NexaEsperaChip), findsNWidgets(3));
    expect(find.text('Espera curta'), findsOneWidget);
    expect(find.text('Espera média'), findsOneWidget);
    expect(find.text('Espera longa'), findsOneWidget);
    expect(find.text('· até 1 hora'), findsOneWidget);
    expect(find.text('· de 1 a 3 horas'), findsOneWidget);
    expect(find.text('· mais de 3 horas'), findsOneWidget);
  });

  testWidgets('Entendi fecha a folha', (tester) async {
    await abrirFolhaDaEspera(tester);

    await tester.tap(find.text('Entendi'));
    await tester.pumpAndSettle();

    expect(find.text('Como calculamos a espera'), findsNothing);
  });
}

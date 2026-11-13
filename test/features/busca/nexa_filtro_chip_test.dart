import 'package:fe_nexa_app/features/busca/nexa_filtro_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_de_teste.dart';

void main() {
  testWidgets('mostra o rótulo e avisa ao tocar', (tester) async {
    var toques = 0;
    await tester.pumpWidget(
      appDeTeste(
        NexaFiltroChip(rotulo: 'Estado: Todos', aoTocar: () => toques++),
      ),
    );

    expect(find.text('Estado: Todos'), findsOneWidget);
    await tester.tap(find.text('Estado: Todos'));
    expect(toques, 1);
  });

  testWidgets('área de toque de pelo menos 44 px de altura', (tester) async {
    await tester.pumpWidget(
      appDeTeste(NexaFiltroChip(rotulo: 'Estado: SP', aoTocar: () {})),
    );

    expect(tester.getSize(find.byType(NexaFiltroChip)).height, greaterThanOrEqualTo(44));
  });

  testWidgets('o leitor de tela lê o rótulo semântico, quando há', (tester) async {
    final semantica = tester.ensureSemantics();
    await tester.pumpWidget(
      appDeTeste(
        NexaFiltroChip(
          rotulo: 'Estado: SP',
          rotuloSemantico: 'Filtrar por estado. Mostrando São Paulo',
          ativo: true,
          aoTocar: () {},
        ),
      ),
    );

    expect(
      find.bySemanticsLabel('Filtrar por estado. Mostrando São Paulo'),
      findsOneWidget,
    );
    semantica.dispose();
  });
}

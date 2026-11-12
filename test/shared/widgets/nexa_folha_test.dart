import 'package:fe_nexa_app/shared/widgets/nexa_folha.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_de_teste.dart';

/// Abre uma folha de exemplo e devolve o que precisar para conferir o fim dela.
Future<void> abrirFolha(
  WidgetTester tester, {
  String? rotuloFechar,
  required void Function() aoFechar,
}) async {
  await tester.pumpWidget(
    appDeTeste(
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            await mostrarNexaFolha(
              context,
              titulo: 'Título da folha',
              rotuloFechar: rotuloFechar ?? 'Entendi',
              children: const [Text('Primeiro conteúdo'), Text('Segundo conteúdo')],
            );
            aoFechar();
          },
          child: const Text('abrir'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('mostra o título, o conteúdo e o botão Entendi', (tester) async {
    await abrirFolha(tester, aoFechar: () {});

    expect(find.text('Título da folha'), findsOneWidget);
    expect(find.text('Primeiro conteúdo'), findsOneWidget);
    expect(find.text('Segundo conteúdo'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Entendi'), findsOneWidget);
  });

  testWidgets('o rótulo do botão pode ser trocado', (tester) async {
    await abrirFolha(tester, rotuloFechar: 'Fechar', aoFechar: () {});

    expect(find.widgetWithText(FilledButton, 'Fechar'), findsOneWidget);
    expect(find.text('Entendi'), findsNothing);
  });

  testWidgets('o botão fecha a folha', (tester) async {
    var fechou = false;
    await abrirFolha(tester, aoFechar: () => fechou = true);

    await tester.tap(find.text('Entendi'));
    await tester.pumpAndSettle();

    expect(fechou, isTrue);
    expect(find.text('Título da folha'), findsNothing);
  });

  testWidgets('tocar no fundo escuro também fecha', (tester) async {
    var fechou = false;
    await abrirFolha(tester, aoFechar: () => fechou = true);

    // O alto da tela é só o fundo escuro; a folha ocupa a parte de baixo.
    await tester.tapAt(const Offset(400, 5));
    await tester.pumpAndSettle();

    expect(fechou, isTrue);
    expect(find.text('Título da folha'), findsNothing);
  });

  testWidgets('o título é anunciado como cabeçalho', (tester) async {
    await abrirFolha(tester, aoFechar: () {});

    final cabecalho = find.ancestor(
      of: find.text('Título da folha'),
      matching: find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.header == true,
      ),
    );

    expect(cabecalho, findsOneWidget);
  });
}

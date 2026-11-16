import 'package:fe_nexa_app/features/busca/nexa_campo_busca.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_de_teste.dart';

const _dica = 'Buscar endereço, bairro ou CEP';

/// O anel escuro do foco é um `DecoratedBox` com duas sombras.
final _anelDoFoco = find.byWidgetPredicate((widget) {
  if (widget is! DecoratedBox) return false;
  final decoracao = widget.decoration;
  return decoracao is BoxDecoration && decoracao.boxShadow?.length == 2;
});

Widget _campo(
  TextEditingController controller, {
  FocusNode? focusNode,
  ValueChanged<String>? aoMudar,
  ValueChanged<String>? aoEnviar,
}) {
  return appDeTeste(
    Padding(
      padding: const EdgeInsets.all(16),
      child: NexaCampoBusca(
        controller: controller,
        focusNode: focusNode,
        aoMudar: aoMudar,
        aoEnviar: aoEnviar,
      ),
    ),
  );
}

void main() {
  testWidgets('vazio: mostra a dica e não mostra o X', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(_campo(controller));

    expect(find.text(_dica), findsOneWidget);
    expect(find.byTooltip('Limpar busca'), findsNothing);
  });

  testWidgets('digitando: mostra o X e avisa a cada mudança', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final avisos = <String>[];

    await tester.pumpWidget(_campo(controller, aoMudar: avisos.add));
    await tester.enterText(find.byType(TextField), 'Vila');
    await tester.pumpAndSettle();

    expect(avisos, ['Vila']);
    expect(find.byTooltip('Limpar busca'), findsOneWidget);
    expect(controller.text, 'Vila');
  });

  testWidgets('o X limpa o texto, avisa com vazio e mantém o foco', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final avisos = <String>[];

    await tester.pumpWidget(_campo(controller, aoMudar: avisos.add));
    await tester.enterText(find.byType(TextField), 'Vila');
    await tester.pump();

    await tester.tap(find.byTooltip('Limpar busca'));
    await tester.pump();

    expect(controller.text, isEmpty);
    expect(avisos.last, '');
    expect(find.byTooltip('Limpar busca'), findsNothing);
    expect(find.text(_dica), findsOneWidget);
    final campo = tester.widget<TextField>(find.byType(TextField));
    expect(campo.focusNode?.hasFocus, isTrue);
  });

  testWidgets('"buscar" no teclado chama aoEnviar com o texto', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final enviados = <String>[];

    await tester.pumpWidget(_campo(controller, aoEnviar: enviados.add));
    await tester.enterText(find.byType(TextField), 'Vila Mariana');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();

    expect(enviados, ['Vila Mariana']);
  });

  testWidgets('o anel escuro só aparece com o campo em foco', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(_campo(controller));
    expect(_anelDoFoco, findsNothing);

    await tester.tap(find.byType(TextField));
    await tester.pump();

    expect(_anelDoFoco, findsOneWidget);
  });

  testWidgets('usa o FocusNode da tela e não o descarta', (tester) async {
    final controller = TextEditingController();
    final foco = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(foco.dispose);

    await tester.pumpWidget(_campo(controller, focusNode: foco));
    foco.requestFocus();
    await tester.pump();

    expect(foco.hasFocus, isTrue);
    expect(_anelDoFoco, findsOneWidget);

    // Tira o campo da tela. O FocusNode é da tela, então segue vivo.
    await tester.pumpWidget(const SizedBox());
    expect(() => foco.addListener(() {}), returnsNormally);
  });

  testWidgets('o X tem área de toque de pelo menos 44 px', (tester) async {
    final controller = TextEditingController(text: 'Vila');
    addTearDown(controller.dispose);

    await tester.pumpWidget(_campo(controller));

    final tamanho = tester.getSize(find.byType(IconButton));
    expect(tamanho.width, greaterThanOrEqualTo(44));
    expect(tamanho.height, greaterThanOrEqualTo(44));
  });
}

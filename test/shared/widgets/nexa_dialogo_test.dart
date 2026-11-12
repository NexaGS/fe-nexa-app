import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_dialogo.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_de_teste.dart';

/// Monta uma tela com o botão "abrir", toca nele e deixa o diálogo na tela.
/// A resposta do diálogo chega em [aoResponder].
Future<void> abrirDialogo(
  WidgetTester tester, {
  required void Function(bool resposta) aoResponder,
  bool destrutivo = false,
  String? iconName,
  String? iconeConfirmar,
}) async {
  await tester.pumpWidget(
    appDeTeste(
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            final resposta = await mostrarNexaDialogo(
              context,
              titulo: 'Sair da conta?',
              texto: 'Suas favoritas continuam guardadas.',
              rotuloConfirmar: 'Sair',
              rotuloCancelar: 'Cancelar',
              destrutivo: destrutivo,
              iconName: iconName,
              iconeConfirmar: iconeConfirmar,
            );
            aoResponder(resposta);
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
  testWidgets('mostra título, texto e os dois botões', (tester) async {
    await abrirDialogo(tester, aoResponder: (_) {});

    expect(find.text('Sair da conta?'), findsOneWidget);
    expect(find.text('Suas favoritas continuam guardadas.'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Sair'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Cancelar'), findsOneWidget);
  });

  testWidgets('confirmar fecha o diálogo e devolve true', (tester) async {
    bool? resposta;
    await abrirDialogo(tester, aoResponder: (r) => resposta = r);

    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();

    expect(resposta, isTrue);
    expect(find.text('Sair da conta?'), findsNothing);
  });

  testWidgets('cancelar fecha o diálogo e devolve false', (tester) async {
    bool? resposta;
    await abrirDialogo(tester, aoResponder: (r) => resposta = r);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(resposta, isFalse);
    expect(find.text('Sair da conta?'), findsNothing);
  });

  testWidgets('tocar fora do diálogo conta como cancelar (false, nunca null)', (
    tester,
  ) async {
    bool? resposta;
    await abrirDialogo(tester, aoResponder: (r) => resposta = r);

    // O canto de cima da tela é só o fundo escuro.
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(resposta, isFalse);
    expect(find.text('Sair da conta?'), findsNothing);
  });

  testWidgets('modo padrão: os botões ficam um embaixo do outro', (
    tester,
  ) async {
    await abrirDialogo(tester, aoResponder: (_) {});

    final confirmar = find.widgetWithText(FilledButton, 'Sair');
    final cancelar = find.widgetWithText(TextButton, 'Cancelar');

    expect(
      tester.getTopLeft(confirmar).dy,
      lessThan(tester.getTopLeft(cancelar).dy),
    );
    // Os dois ocupam a largura toda, então começam no mesmo ponto à esquerda.
    expect(tester.getTopLeft(confirmar).dx, tester.getTopLeft(cancelar).dx);
    expect(tester.getSize(confirmar).width, tester.getSize(cancelar).width);
  });

  testWidgets('modo destrutivo: lado a lado, confirmar à direita e vermelho', (
    tester,
  ) async {
    await abrirDialogo(tester, aoResponder: (_) {}, destrutivo: true);

    final confirmar = find.widgetWithText(FilledButton, 'Sair');
    final cancelar = find.widgetWithText(TextButton, 'Cancelar');

    expect(
      tester.getTopLeft(cancelar).dx,
      lessThan(tester.getTopLeft(confirmar).dx),
    );
    expect(
      (tester.getCenter(cancelar).dy - tester.getCenter(confirmar).dy).abs(),
      lessThan(1),
    );

    final estilo = tester.widget<FilledButton>(confirmar).style;
    expect(estilo?.backgroundColor?.resolve(<WidgetState>{}), NexaColors.red);
  });

  testWidgets('sem ícones passados, nenhum ícone aparece', (tester) async {
    await abrirDialogo(tester, aoResponder: (_) {});

    expect(find.byType(NexaIcon), findsNothing);
  });

  testWidgets('com ícones, mostra o do alto e o do botão de confirmar', (
    tester,
  ) async {
    await abrirDialogo(
      tester,
      aoResponder: (_) {},
      iconName: 'logout',
      iconeConfirmar: 'phone',
    );

    bool temIcone(String nome) => tester
        .widgetList<NexaIcon>(find.byType(NexaIcon))
        .any((icone) => icone.name == nome);

    expect(temIcone('logout'), isTrue);
    expect(temIcone('phone'), isTrue);
  });

  testWidgets('o título é anunciado como cabeçalho', (tester) async {
    await abrirDialogo(tester, aoResponder: (_) {});

    final cabecalho = find.ancestor(
      of: find.text('Sair da conta?'),
      matching: find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.header == true,
      ),
    );

    expect(cabecalho, findsOneWidget);
  });
}

import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/features/busca/nexa_local_item.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_de_teste.dart';

bool _temIcone(WidgetTester tester, String nome) => tester
    .widgetList<NexaIcon>(find.byType(NexaIcon))
    .any((icone) => icone.name == nome);

/// O círculo verde-claro atrás do ícone da localização atual.
final _circuloVerde = find.byWidgetPredicate((widget) {
  if (widget is! DecoratedBox) return false;
  final decoracao = widget.decoration;
  return decoracao is BoxDecoration && decoracao.color == NexaColors.primrose;
});

/// A linha fina de baixo.
final _divisor = find.byWidgetPredicate((widget) {
  if (widget is! DecoratedBox) return false;
  final decoracao = widget.decoration;
  return decoracao is BoxDecoration && decoracao.border != null;
});

void main() {
  group('localizacaoAtual', () {
    testWidgets('traz o texto do Figma e responde ao toque', (tester) async {
      var toques = 0;
      await tester.pumpWidget(
        appDeTeste(NexaLocalItem.localizacaoAtual(aoTocar: () => toques++)),
      );

      expect(find.text('Usar minha localização atual'), findsOneWidget);
      expect(find.text('Atualiza o ponto de partida pelo GPS'), findsOneWidget);
      expect(_temIcone(tester, 'locate'), isTrue);
      expect(_circuloVerde, findsOneWidget);

      await tester.tap(find.text('Usar minha localização atual'));
      expect(toques, 1);
    });
  });

  group('sugestao', () {
    testWidgets('mostra o pin sem círculo e não tem botão de remover', (
      tester,
    ) async {
      var toques = 0;
      await tester.pumpWidget(
        appDeTeste(
          NexaLocalItem.sugestao(
            titulo: 'Vila Mariana, São Paulo',
            descricao: 'Bairro',
            aoTocar: () => toques++,
          ),
        ),
      );

      expect(find.text('Vila Mariana, São Paulo'), findsOneWidget);
      expect(find.text('Bairro'), findsOneWidget);
      expect(_temIcone(tester, 'pin'), isTrue);
      expect(_circuloVerde, findsNothing);
      expect(find.byType(IconButton), findsNothing);

      await tester.tap(find.text('Vila Mariana, São Paulo'));
      expect(toques, 1);
    });
  });

  group('recente', () {
    testWidgets('o toque na linha e o toque no X são independentes', (
      tester,
    ) async {
      var aoTocar = 0;
      var aoRemover = 0;
      await tester.pumpWidget(
        appDeTeste(
          NexaLocalItem.recente(
            titulo: 'Vila Nova, São Paulo',
            descricao: 'Local atual',
            aoTocar: () => aoTocar++,
            aoRemover: () => aoRemover++,
          ),
        ),
      );

      expect(_temIcone(tester, 'history'), isTrue);

      await tester.tap(find.text('Vila Nova, São Paulo'));
      expect((aoTocar, aoRemover), (1, 0));

      await tester.tap(find.byType(IconButton));
      expect((aoTocar, aoRemover), (1, 1));
    });

    testWidgets('o X diz qual local vai remover e tem 44 px de toque', (
      tester,
    ) async {
      await tester.pumpWidget(
        appDeTeste(
          NexaLocalItem.recente(
            titulo: 'Vila Nova, São Paulo',
            descricao: 'Local atual',
            aoTocar: () {},
            aoRemover: () {},
          ),
        ),
      );

      expect(
        find.byTooltip('Remover "Vila Nova, São Paulo" dos recentes'),
        findsOneWidget,
      );
      final tamanho = tester.getSize(find.byType(IconButton));
      expect(tamanho.width, greaterThanOrEqualTo(44));
      expect(tamanho.height, greaterThanOrEqualTo(44));
    });
  });

  testWidgets('mostrarDivisor: false tira a linha de baixo', (tester) async {
    await tester.pumpWidget(
      appDeTeste(
        NexaLocalItem.sugestao(
          titulo: 'Vila Nova, São Paulo',
          descricao: 'Bairro',
          aoTocar: () {},
        ),
      ),
    );
    expect(_divisor, findsOneWidget);

    await tester.pumpWidget(
      appDeTeste(
        NexaLocalItem.sugestao(
          titulo: 'Vila Nova, São Paulo',
          descricao: 'Bairro',
          aoTocar: () {},
          mostrarDivisor: false,
        ),
      ),
    );
    expect(_divisor, findsNothing);
  });

  testWidgets('título e descrição cabem em letra grande sem estourar', (
    tester,
  ) async {
    await tester.pumpWidget(
      appDeTeste(
        // Dobra o tamanho da letra só para este item, como no celular de
        // quem aumentou a fonte nas configurações.
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: NexaLocalItem.sugestao(
              titulo: 'Rua Doutor Arnaldo de Carvalho, 1200 · Cerqueira César',
              descricao: 'Endereço',
              aoTocar: () {},
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}

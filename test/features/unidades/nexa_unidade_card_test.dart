import 'package:fe_nexa_app/features/unidades/nexa_unidade_card.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_de_teste.dart';

Widget _cartao({
  double? tempoEspera = 40,
  bool favorita = false,
  VoidCallback? aoAlternarFavorita,
  VoidCallback? aoTocar,
  List<String> detalhes = const [],
  String? chegada,
  bool menorEspera = false,
  bool dadosAntigos = false,
}) {
  return appDeTeste(
    Padding(
      padding: const EdgeInsets.all(16),
      child: NexaUnidadeCard(
        nome: 'Unidade B',
        tempoEspera: tempoEspera,
        favorita: favorita,
        aoAlternarFavorita: aoAlternarFavorita ?? () {},
        aoTocar: aoTocar,
        detalhes: detalhes,
        chegada: chegada,
        menorEspera: menorEspera,
        dadosAntigos: dadosAntigos,
      ),
    ),
  );
}

void main() {
  testWidgets('normal: nome, tempo, faixa e detalhes', (tester) async {
    await tester.pumpWidget(
      _cartao(detalhes: const ['3 km', '4 aguardando', 'há 2 min']),
    );

    expect(find.text('Unidade B'), findsOneWidget);
    expect(find.text('Cerca de 40 min'), findsOneWidget);
    expect(find.text('Espera curta'), findsOneWidget);
    expect(find.text('3 km · 4 aguardando · há 2 min'), findsOneWidget);
  });

  testWidgets('a faixa acompanha o tempo: média e longa', (tester) async {
    await tester.pumpWidget(_cartao(tempoEspera: 100));
    expect(find.text('Espera média'), findsOneWidget);

    await tester.pumpWidget(_cartao(tempoEspera: 240));
    expect(find.text('Espera longa'), findsOneWidget);
  });

  testWidgets('sem número: "Estimativa indisponível" e "Sem dados recentes"', (
    tester,
  ) async {
    await tester.pumpWidget(_cartao(tempoEspera: null));

    expect(find.text('Estimativa indisponível'), findsOneWidget);
    expect(find.text('Sem dados recentes'), findsOneWidget);
    expect(find.textContaining('Cerca de'), findsNothing);
  });

  testWidgets('dados antigos: mostra o tempo e troca o selo da faixa', (
    tester,
  ) async {
    await tester.pumpWidget(_cartao(tempoEspera: 70, dadosAntigos: true));

    expect(find.text('Cerca de 1 h 10'), findsOneWidget);
    expect(find.text('Dados antigos'), findsOneWidget);
    expect(find.text('Espera média'), findsNothing);
  });

  testWidgets('sem número, "dados antigos" não vale: continua sem estimativa', (
    tester,
  ) async {
    await tester.pumpWidget(_cartao(tempoEspera: null, dadosAntigos: true));

    expect(find.text('Estimativa indisponível'), findsOneWidget);
    expect(find.text('Dados antigos'), findsNothing);
  });

  testWidgets('menorEspera mostra o selo; sem ele, não aparece', (tester) async {
    await tester.pumpWidget(_cartao(menorEspera: true));
    expect(find.text('Menor espera perto de você'), findsOneWidget);

    await tester.pumpWidget(_cartao());
    expect(find.text('Menor espera perto de você'), findsNothing);
  });

  testWidgets('a frase de chegada só aparece quando é passada', (tester) async {
    await tester.pumpWidget(
      _cartao(chegada: 'Se sair agora, você chega por volta das 14h20'),
    );
    expect(
      find.text('Se sair agora, você chega por volta das 14h20'),
      findsOneWidget,
    );

    await tester.pumpWidget(_cartao());
    expect(find.textContaining('Se sair agora'), findsNothing);
  });

  testWidgets('sem detalhes, não sobra linha nem separador', (tester) async {
    await tester.pumpWidget(_cartao());

    expect(find.textContaining('·'), findsNothing);
  });

  testWidgets('o coração mostra a ação e o nome, conforme é favorita ou não', (
    tester,
  ) async {
    await tester.pumpWidget(_cartao(favorita: false));
    expect(
      find.byTooltip('Adicionar às favoritas: Unidade B'),
      findsOneWidget,
    );

    await tester.pumpWidget(_cartao(favorita: true));
    expect(find.byTooltip('Remover das favoritas: Unidade B'), findsOneWidget);
  });

  testWidgets('tocar no coração não abre o cartão, e tocar no cartão não '
      'favorita', (tester) async {
    var cartao = 0;
    var coracao = 0;
    await tester.pumpWidget(
      _cartao(aoTocar: () => cartao++, aoAlternarFavorita: () => coracao++),
    );

    await tester.tap(find.byTooltip('Adicionar às favoritas: Unidade B'));
    expect((cartao, coracao), (0, 1));

    await tester.tap(find.text('Unidade B'));
    expect((cartao, coracao), (1, 1));
  });

  testWidgets('nome comprido quebra em até duas linhas sem estourar', (
    tester,
  ) async {
    await tester.pumpWidget(
      appDeTeste(
        NexaUnidadeCard(
          nome:
              'Unidade Básica de Saúde Doutor Fulano de Tal da Silva Sauro '
              'Ribeiro dos Santos Neto',
          tempoEspera: 40,
          favorita: false,
          aoAlternarFavorita: () {},
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('carregando: quatro blocos de esqueleto e nenhum texto', (
    tester,
  ) async {
    await tester.pumpWidget(appDeTeste(const NexaUnidadeCardCarregando()));

    expect(find.byType(NexaSkeleton), findsNWidgets(4));
    expect(find.byType(Text), findsNothing);
  });
}

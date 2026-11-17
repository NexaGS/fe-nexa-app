import 'dart:async';

import 'package:fe_nexa_app/app/theme/nexa_theme.dart';
import 'package:fe_nexa_app/features/auth/data/auth_repository.dart'
    show SemConexao;
import 'package:fe_nexa_app/features/favoritas/aba_favoritas.dart';
import 'package:fe_nexa_app/features/favoritas/data/favoritas_conta_repository.dart';
import 'package:fe_nexa_app/features/home/data/localizacao_service.dart';
import 'package:fe_nexa_app/features/unidades/data/favoritas_repository.dart';
import 'package:fe_nexa_app/features/unidades/data/unidade_resumo.dart';
import 'package:fe_nexa_app/features/unidades/nexa_unidade_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


class _GpsFalso implements LocalizacaoService {
  /// Quantas vezes o GPS foi consultado.
  int consultas = 0;

  @override
  Future<Posicao> posicaoAtual() async {
    consultas++;
    return const Posicao(latitude: -23.56, longitude: -46.65);
  }

  @override
  Future<void> abrirAjustesDoGps() async {}

  @override
  Future<void> abrirAjustesDoApp() async {}
}

class _FavoritasFalso implements FavoritasRepository {
  _FavoritasFalso(Set<int> inicial, {this.falhaAoSalvar = false})
    : _ids = ValueNotifier(inicial);

  final bool falhaAoSalvar;
  final ValueNotifier<Set<int>> _ids;
  final definicoes = <(int, bool)>[];

  @override
  ValueListenable<Set<int>> get ids => _ids;

  @override
  Future<void> carregar() async {}

  @override
  Future<void> definir(int id, {required bool favorita}) async {
    definicoes.add((id, favorita));
    if (falhaAoSalvar) throw const FavoritaNaoSalva();
    _ids.value = favorita ? {..._ids.value, id} : ({..._ids.value}..remove(id));
  }
}

class _ListaFalsa implements FavoritasLista {
  _ListaFalsa(this.resposta);

  final Object resposta;
  double? latitudePedida;

  @override
  Future<List<UnidadeResumo>> carregarUnidades({
    double? latitude,
    double? longitude,
  }) async {
    latitudePedida = latitude;
    final r = resposta;
    if (r is Exception) throw r;
    if (r is Completer<List<UnidadeResumo>>) return r.future;
    return r as List<UnidadeResumo>;
  }

  @override
  Future<UnidadeResumo?> carregarUnidade(int id) async {
    final r = resposta;
    if (r is! List<UnidadeResumo>) return null;
    return r.where((u) => u.id == id).firstOrNull;
  }
}

/// Um Java que muda de ideia: a lista e a falha podem ser trocadas no meio do
/// teste, para ver o que a tela faz na rodada seguinte.
class _ListaQueMuda implements FavoritasLista {
  _ListaQueMuda(this.unidades);

  List<UnidadeResumo> unidades;
  Exception? falha;
  int chamadas = 0;

  @override
  Future<List<UnidadeResumo>> carregarUnidades({
    double? latitude,
    double? longitude,
  }) async {
    chamadas++;
    final erro = falha;
    if (erro != null) throw erro;
    return unidades;
  }

  @override
  Future<UnidadeResumo?> carregarUnidade(int id) async =>
      unidades.where((u) => u.id == id).firstOrNull;
}

const _a = UnidadeResumo(
  id: 1,
  nome: 'Unidade A',
  bairro: 'Centro',
  tempoEspera: 200,
);
const _b = UnidadeResumo(
  id: 2,
  nome: 'Unidade B',
  bairro: 'Vila Nova',
  tempoEspera: 40,
);
const _c = UnidadeResumo(id: 3, nome: 'Unidade C', tempoEspera: 90);

/// A mesma unidade B, depois de a fila crescer.
const _bMaisLenta = UnidadeResumo(
  id: 2,
  nome: 'Unidade B',
  bairro: 'Vila Nova',
  tempoEspera: 120,
);

Future<void> abrir(
  WidgetTester tester, {
  required FavoritasRepository favoritas,
  required FavoritasLista lista,
  bool temConta = true,
  VoidCallback? aoVerUnidades,
  VoidCallback? aoCriarConta,
  bool esperar = true,
  bool ativa = true,
  _GpsFalso? gps,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: buildNexaTheme(),
      home: Scaffold(
        body: SafeArea(
          child: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: AbaFavoritas(
                temConta: temConta,
                aoVerUnidades: aoVerUnidades,
                aoCriarConta: aoCriarConta,
                favoritas: favoritas,
                lista: lista,
                localizacao: gps ?? _GpsFalso(),
                ativa: ativa,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  if (esperar) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

void main() {
  testWidgets('lista da menor para a maior espera, com a quantidade', (
    tester,
  ) async {
    await abrir(
      tester,
      favoritas: _FavoritasFalso({1, 2, 3}),
      lista: _ListaFalsa([_a, _b, _c]),
    );

    expect(find.text('Favoritas'), findsOneWidget);
    expect(find.text('3 unidades'), findsOneWidget);
    expect(find.byType(NexaUnidadeCard), findsNWidgets(3));

    final ordem = tester
        .widgetList<NexaUnidadeCard>(find.byType(NexaUnidadeCard))
        .map((c) => c.nome)
        .toList();
    expect(ordem, ['Unidade B', 'Unidade C', 'Unidade A']);
  });

  testWidgets('quem tem conta vê a menor espera entre as favoritas', (
    tester,
  ) async {
    await abrir(
      tester,
      favoritas: _FavoritasFalso({1, 2}),
      lista: _ListaFalsa([_a, _b]),
    );

    expect(
      find.textContaining('A menor espera entre as suas favoritas agora'),
      findsOneWidget,
    );
    expect(find.textContaining('Unidade B, 40 min'), findsOneWidget);
    expect(find.text('Criar conta'), findsNothing);
  });

  testWidgets('com uma só favorita não mostra "a menor espera"', (
    tester,
  ) async {
    await abrir(
      tester,
      favoritas: _FavoritasFalso({2}),
      lista: _ListaFalsa([_b]),
    );

    expect(find.text('1 unidade'), findsOneWidget);
    expect(find.textContaining('A menor espera'), findsNothing);
  });

  testWidgets('quem tem conta manda a posição para ver a distância', (
    tester,
  ) async {
    final lista = _ListaFalsa([_b]);
    await abrir(tester, favoritas: _FavoritasFalso({2}), lista: lista);

    expect(lista.latitudePedida, -23.56);
  });

  testWidgets('visitante vê o convite a criar conta, sem posição', (
    tester,
  ) async {
    var criou = false;
    final lista = _ListaFalsa([_b]);
    await abrir(
      tester,
      temConta: false,
      favoritas: _FavoritasFalso({2}),
      lista: lista,
      aoCriarConta: () => criou = true,
    );

    expect(
      find.textContaining('Suas favoritas estão só neste aparelho'),
      findsOneWidget,
    );
    expect(lista.latitudePedida, isNull);
    expect(find.textContaining('A menor espera'), findsNothing);

    await tester.tap(find.text('Criar conta'));
    expect(criou, isTrue);
  });

  testWidgets('tocar no coração remove o cartão e o "Desfazer" o devolve', (
    tester,
  ) async {
    final favoritas = _FavoritasFalso({1, 2});
    await abrir(tester, favoritas: favoritas, lista: _ListaFalsa([_a, _b]));

    await tester.tap(find.byTooltip('Remover das favoritas: Unidade B'));
    await tester.pumpAndSettle();

    expect(find.text('Unidade removida das favoritas'), findsOneWidget);
    expect(find.text('2 unidades'), findsNothing);
    expect(find.text('1 unidade'), findsOneWidget);
    expect(find.text('Unidade B'), findsNothing);
    expect(favoritas.definicoes, [(2, false)]);

    await tester.tap(find.text('Desfazer'));
    await tester.pumpAndSettle();

    expect(favoritas.definicoes, [(2, false), (2, true)]);
    expect(find.text('2 unidades'), findsOneWidget);
    expect(find.text('Unidade B'), findsOneWidget);
  });

  testWidgets('se não conseguir remover, avisa e mantém o cartão', (
    tester,
  ) async {
    await abrir(
      tester,
      favoritas: _FavoritasFalso({2}, falhaAoSalvar: true),
      lista: _ListaFalsa([_b]),
    );

    await tester.tap(find.byTooltip('Remover das favoritas: Unidade B'));
    await tester.pumpAndSettle();

    expect(find.text('Não consegui remover. Tente de novo.'), findsOneWidget);
    expect(find.text('Unidade B'), findsOneWidget);
  });

  testWidgets('sem favoritas, mostra o estado vazio e leva às unidades', (
    tester,
  ) async {
    var foi = false;
    await abrir(
      tester,
      favoritas: _FavoritasFalso({}),
      lista: _ListaFalsa(<UnidadeResumo>[]),
      aoVerUnidades: () => foi = true,
    );

    expect(find.text('0 unidades'), findsOneWidget);
    expect(find.text('Você ainda não tem favoritas'), findsOneWidget);
    expect(
      find.text('Toque no coração de uma unidade para guardá-la aqui.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Ver unidades próximas'));
    expect(foi, isTrue);
  });

  testWidgets('enquanto carrega, mostra os cartões esqueleto', (tester) async {
    await abrir(
      tester,
      favoritas: _FavoritasFalso({1}),
      lista: _ListaFalsa(Completer<List<UnidadeResumo>>()),
      esperar: false,
    );

    expect(find.byType(NexaUnidadeCardCarregando), findsNWidgets(3));
    expect(find.text('Você ainda não tem favoritas'), findsNothing);
  });

  testWidgets('sem internet, explica e o botão tenta de novo', (tester) async {
    await abrir(
      tester,
      favoritas: _FavoritasFalso({1}),
      lista: _ListaFalsa(const SemConexao()),
    );

    expect(find.text('Sem conexão com a internet'), findsOneWidget);
    expect(find.text('Tentar de novo'), findsOneWidget);
  });

  testWidgets('favoritar em outra aba traz a nova unidade para a lista', (
    tester,
  ) async {
    final favoritas = _FavoritasFalso({1});
    final lista = _ListaAtrasada(inteira: [_a], porId: {2: _b, 3: _c});
    await abrir(tester, favoritas: favoritas, lista: lista);
    expect(find.byType(NexaUnidadeCard), findsOneWidget);

    await favoritas.definir(2, favorita: true);
    await tester.pumpAndSettle();
    expect(find.byType(NexaUnidadeCard), findsNWidgets(2));
    expect(find.text('2 unidades'), findsOneWidget);

    await favoritas.definir(3, favorita: true);
    await tester.pumpAndSettle();
    expect(find.byType(NexaUnidadeCard), findsNWidgets(3));
    expect(find.text('3 unidades'), findsOneWidget);
  });

  group('atualização automática', () {
    double? espera(WidgetTester tester) => tester
        .widget<NexaUnidadeCard>(find.byType(NexaUnidadeCard))
        .tempoEspera;

    testWidgets('traz o tempo novo sozinho, sem esqueleto e sem GPS', (
      tester,
    ) async {
      final lista = _ListaQueMuda([_b]);
      final gps = _GpsFalso();
      await abrir(
        tester,
        favoritas: _FavoritasFalso({2}),
        lista: lista,
        gps: gps,
      );
      expect(espera(tester), 40);

      lista.unidades = [_bMaisLenta];
      await tester.pump(const Duration(seconds: 20));
      await tester.pump();

      expect(espera(tester), 120);
      expect(lista.chamadas, 2);
      expect(find.byType(NexaUnidadeCardCarregando), findsNothing);
      // Só a primeira carga pergunta onde a pessoa está.
      expect(gps.consultas, 1);
    });

    testWidgets('se falhar, mantém a lista, não avisa e tenta de novo', (
      tester,
    ) async {
      final lista = _ListaQueMuda([_b]);
      await abrir(tester, favoritas: _FavoritasFalso({2}), lista: lista);

      lista.falha = const SemConexao();
      await tester.pump(const Duration(seconds: 20));
      await tester.pump();
      expect(lista.chamadas, 2);
      expect(espera(tester), 40);
      expect(find.text('Não consegui atualizar agora.'), findsNothing);

      lista
        ..falha = null
        ..unidades = [_bMaisLenta];
      await tester.pump(const Duration(seconds: 20));
      await tester.pump();
      expect(espera(tester), 120);
    });

    testWidgets('fora da aba não consulta; ao voltar, atualiza na hora', (
      tester,
    ) async {
      final lista = _ListaQueMuda([_b]);
      final favoritas = _FavoritasFalso({2});
      await abrir(tester, favoritas: favoritas, lista: lista, ativa: false);
      expect(lista.chamadas, 1);

      await tester.pump(const Duration(seconds: 90));
      expect(lista.chamadas, 1);

      lista.unidades = [_bMaisLenta];
      await abrir(tester, favoritas: favoritas, lista: lista);

      expect(lista.chamadas, 2);
      expect(espera(tester), 120);
    });
  });
}

class _ListaAtrasada implements FavoritasLista {
  _ListaAtrasada({required this.inteira, required this.porId});

  final List<UnidadeResumo> inteira;
  final Map<int, UnidadeResumo> porId;

  @override
  Future<List<UnidadeResumo>> carregarUnidades({
    double? latitude,
    double? longitude,
  }) async => inteira;

  @override
  Future<UnidadeResumo?> carregarUnidade(int id) async => porId[id];
}

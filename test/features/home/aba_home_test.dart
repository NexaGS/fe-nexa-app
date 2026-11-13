import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:fe_nexa_app/app/theme/nexa_theme.dart';
import 'package:fe_nexa_app/features/auth/data/auth_repository.dart'
    show ErroInesperado, SemConexao;
import 'package:fe_nexa_app/features/home/aba_home.dart';
import 'package:fe_nexa_app/features/home/data/local_repository.dart';
import 'package:fe_nexa_app/features/home/data/localizacao_service.dart';
import 'package:fe_nexa_app/features/unidades/data/favoritas_repository.dart';
import 'package:fe_nexa_app/features/unidades/data/unidade_resumo.dart';
import 'package:fe_nexa_app/features/unidades/data/unidades_repository.dart';
import 'package:fe_nexa_app/features/unidades/nexa_unidade_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _GpsFalso implements LocalizacaoService {
  _GpsFalso({this.erro});

  /// Se informado, a posição lança esta exceção.
  final Exception? erro;

  @override
  Future<Posicao> posicaoAtual() async {
    final falha = erro;
    if (falha != null) throw falha;
    return const Posicao(latitude: -23.56, longitude: -46.65);
  }

  @override
  Future<void> abrirAjustesDoGps() async {}

  @override
  Future<void> abrirAjustesDoApp() async {}
}

class _LocaisFalso implements LocalRepository {
  @override
  Future<LocalDescrito> descrever(Posicao posicao) async =>
      const LocalDescrito(bairro: 'Vila Nova', municipio: 'São Paulo');
}

/// A cada chamada devolve a próxima resposta da fila (a última se repete).
/// Cada resposta é uma lista de unidades ou uma exceção a lançar.
class _UnidadesFalso implements UnidadesRepository {
  _UnidadesFalso(this.respostas);

  final List<Object> respostas;
  int chamadas = 0;

  @override
  Future<List<UnidadeResumo>> proximas({
    required double latitude,
    required double longitude,
    int tamanho = 20,
  }) async {
    final indice = chamadas < respostas.length ? chamadas : respostas.length - 1;
    final resposta = respostas[indice];
    chamadas++;
    if (resposta is Exception) throw resposta;
    return resposta as List<UnidadeResumo>;
  }
}

/// Nunca responde sozinho: serve para ver a tela "carregando".
class _UnidadesPendente implements UnidadesRepository {
  @override
  Future<List<UnidadeResumo>> proximas({
    required double latitude,
    required double longitude,
    int tamanho = 20,
  }) => Completer<List<UnidadeResumo>>().future;
}

class _FavoritasFalso implements FavoritasRepository {
  _FavoritasFalso({this.falhaAoSalvar = false});

  final bool falhaAoSalvar;
  final ValueNotifier<Set<int>> _ids = ValueNotifier({});

  @override
  ValueListenable<Set<int>> get ids => _ids;

  @override
  Future<void> carregar() async {}

  @override
  Future<void> definir(int id, {required bool favorita}) async {
    if (falhaAoSalvar) throw const FavoritaNaoSalva();
    _ids.value = favorita ? {..._ids.value, id} : ({..._ids.value}..remove(id));
  }
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

/// Abre a aba Home numa tela de 390 x 844 (o tamanho do Figma), com as
/// animações desligadas. Por padrão espera tudo carregar; para ver o
/// "carregando", passe `esperar: false`.
Future<void> abrirHome(
  WidgetTester tester, {
  LocalizacaoService? gps,
  UnidadesRepository? unidades,
  FavoritasRepository? favoritas,
  VoidCallback? aoVerTodasAsUnidades,
  DateTime Function()? agora,
  bool esperar = true,
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
              child: AbaHome(
                nome: 'Julio',
                aoVerTodasAsUnidades: aoVerTodasAsUnidades,
                localizacao: gps ?? _GpsFalso(),
                locais: _LocaisFalso(),
                unidades: unidades ?? _UnidadesFalso([[_b]]),
                favoritas: favoritas ?? _FavoritasFalso(),
                agora: agora,
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
  testWidgets('mostra a saudação e o local', (tester) async {
    await abrirHome(tester);

    expect(find.text('Olá, Julio'), findsOneWidget);
    expect(find.text('Vila Nova, São Paulo'), findsOneWidget);
    expect(find.text('Das mais próximas para as mais distantes'), findsOneWidget);
    expect(
      find.text('Estimativas podem mudar. A prioridade é definida pela triagem.'),
      findsOneWidget,
    );
  });

  testWidgets('enquanto carrega: aviso e três cartões esqueleto', (
    tester,
  ) async {
    await abrirHome(tester, unidades: _UnidadesPendente(), esperar: false);

    expect(find.text('Buscando unidades perto de você…'), findsOneWidget);
    expect(find.byType(NexaUnidadeCardCarregando), findsNWidgets(3));
    expect(find.byType(NexaUnidadeCard), findsNothing);
  });

  testWidgets('mantém a ordem do Java (mais perto primeiro), sem reordenar por espera', (
    tester,
  ) async {
    // O Java manda A (200 min), B (40 min), C (90 min): A é a mais perto.
    await abrirHome(
      tester,
      unidades: _UnidadesFalso([
        [_a, _b, _c],
      ]),
    );

    final alturaA = tester.getTopLeft(find.text('Unidade A')).dy;
    final alturaB = tester.getTopLeft(find.text('Unidade B')).dy;
    final alturaC = tester.getTopLeft(find.text('Unidade C')).dy;
    expect(alturaA, lessThan(alturaB));
    expect(alturaB, lessThan(alturaC));

    expect(find.text('Cerca de 40 min'), findsOneWidget);
    expect(find.text('Vila Nova'), findsOneWidget);
  });

  testWidgets('o selo de menor espera vai no cartão da menor espera, onde ele estiver', (
    tester,
  ) async {
    await abrirHome(
      tester,
      unidades: _UnidadesFalso([
        [_a, _b, _c],
      ]),
    );

    // O selo fica no alto do cartão B: abaixo do nome de A e acima do nome de B.
    expect(find.text('Menor espera perto de você'), findsOneWidget);
    final alturaA = tester.getTopLeft(find.text('Unidade A')).dy;
    final alturaSelo = tester.getTopLeft(find.text('Menor espera perto de você')).dy;
    final alturaB = tester.getTopLeft(find.text('Unidade B')).dy;
    expect(alturaA, lessThan(alturaSelo));
    expect(alturaSelo, lessThan(alturaB));
  });

  testWidgets('sem selo quando todas as unidades têm a mesma espera', (
    tester,
  ) async {
    const igualA = UnidadeResumo(id: 1, nome: 'Unidade A', tempoEspera: 0);
    const igualB = UnidadeResumo(id: 2, nome: 'Unidade B', tempoEspera: 0);
    await abrirHome(
      tester,
      unidades: _UnidadesFalso([
        [igualA, igualB],
      ]),
    );

    expect(find.byType(NexaUnidadeCard), findsNWidgets(2));
    expect(find.text('Menor espera perto de você'), findsNothing);
  });

  testWidgets('com uma só unidade, não mostra o selo de menor espera', (
    tester,
  ) async {
    await abrirHome(tester);

    expect(find.text('Unidade B'), findsOneWidget);
    expect(find.text('Menor espera perto de você'), findsNothing);
  });

  testWidgets('nenhuma unidade: estado vazio e botão que leva à lista de todas', (
    tester,
  ) async {
    var cliques = 0;
    await abrirHome(
      tester,
      unidades: _UnidadesFalso([<UnidadeResumo>[]]),
      aoVerTodasAsUnidades: () => cliques++,
    );

    expect(find.text('Não achamos unidades perto daqui'), findsOneWidget);
    await tester.tap(find.text('Ver todas as unidades'));
    expect(cliques, 1);
  });

  testWidgets('erro do servidor: mostra o erro e "Tentar de novo" recarrega', (
    tester,
  ) async {
    final unidades = _UnidadesFalso([
      const ErroInesperado(),
      [_b],
    ]);
    await abrirHome(tester, unidades: unidades);

    expect(find.text('Algo deu errado do nosso lado'), findsOneWidget);
    expect(find.byType(NexaUnidadeCard), findsNothing);

    await tester.tap(find.text('Tentar de novo'));
    await tester.pumpAndSettle();

    expect(unidades.chamadas, 2);
    expect(find.text('Algo deu errado do nosso lado'), findsNothing);
    expect(find.text('Unidade B'), findsOneWidget);
  });

  testWidgets('sem internet e sem dados guardados: pede para conferir a internet', (
    tester,
  ) async {
    await abrirHome(
      tester,
      unidades: _UnidadesFalso([const SemConexao()]),
    );

    expect(find.text('Sem conexão com a internet'), findsOneWidget);
    expect(find.text('Tentar de novo'), findsOneWidget);
  });

  testWidgets('puxar para atualizar e falhar: banner com a idade e lista mantida', (
    tester,
  ) async {
    final unidades = _UnidadesFalso([
      [_b, _c],
      const SemConexao(),
    ]);
    var relogio = DateTime(2026, 11, 11, 10);
    await abrirHome(tester, unidades: unidades, agora: () => relogio);

    expect(find.text('Unidade B'), findsOneWidget);
    expect(find.textContaining('Mostrando dados de'), findsNothing);

    relogio = relogio.add(const Duration(minutes: 12));
    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    expect(unidades.chamadas, 2);
    expect(find.text('Mostrando dados de há 12 min'), findsOneWidget);
    expect(find.text('Unidade B'), findsOneWidget);
    expect(find.text('Unidade C'), findsOneWidget);
  });

  testWidgets('GPS desligado: aviso no local e botão para ver todas as unidades', (
    tester,
  ) async {
    var cliques = 0;
    await abrirHome(
      tester,
      gps: _GpsFalso(erro: const GpsDesligado()),
      aoVerTodasAsUnidades: () => cliques++,
    );

    expect(
      find.text('GPS desligado. Ative a localização do celular.'),
      findsOneWidget,
    );
    expect(find.text('Ativar GPS'), findsOneWidget);
    expect(find.text('Não sabemos onde você está'), findsOneWidget);

    await tester.tap(find.text('Ver todas as unidades'));
    expect(cliques, 1);
  });

  testWidgets('o local vem sempre do GPS: não há "Alterar"', (tester) async {
    await abrirHome(tester);

    expect(find.text('Vila Nova, São Paulo'), findsOneWidget);
    expect(find.text('Alterar'), findsNothing);
  });

  testWidgets('tocar no coração favorita e desfavorita a unidade', (
    tester,
  ) async {
    final favoritas = _FavoritasFalso();
    await abrirHome(tester, favoritas: favoritas);

    await tester.tap(find.byTooltip('Adicionar às favoritas: Unidade B'));
    await tester.pumpAndSettle();
    expect(favoritas.ids.value, {2});
    expect(find.byTooltip('Remover das favoritas: Unidade B'), findsOneWidget);

    await tester.tap(find.byTooltip('Remover das favoritas: Unidade B'));
    await tester.pumpAndSettle();
    expect(favoritas.ids.value, isEmpty);
  });

  testWidgets('se não conseguir salvar a favorita, avisa com um snackbar', (
    tester,
  ) async {
    await abrirHome(tester, favoritas: _FavoritasFalso(falhaAoSalvar: true));

    await tester.tap(find.byTooltip('Adicionar às favoritas: Unidade B'));
    await tester.pumpAndSettle();

    expect(
      find.text('Não consegui salvar a favorita. Tente de novo.'),
      findsOneWidget,
    );
  });
}

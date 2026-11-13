import 'dart:async';
import 'dart:math' as math;

import 'package:fe_nexa_app/app/theme/nexa_theme.dart';
import 'package:fe_nexa_app/features/auth/data/auth_repository.dart'
    show ErroInesperado, SemConexao;
import 'package:fe_nexa_app/features/busca/aba_buscar.dart';
import 'package:fe_nexa_app/features/busca/data/catalogo_repository.dart';
import 'package:fe_nexa_app/features/unidades/data/favoritas_repository.dart';
import 'package:fe_nexa_app/features/unidades/data/unidade_resumo.dart';
import 'package:fe_nexa_app/features/unidades/nexa_unidade_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// --- Versões falsas das dependências: a tela roda sem o Java e sem guardar
// nada de verdade. ---

/// 25 unidades: as ímpares são de São Paulo e as pares, do Rio de Janeiro.
/// Com 10 por página, são 3 páginas (10, 10 e 5).
UnidadeResumo _unidade(int n) => UnidadeResumo(
  id: n,
  nome: 'Unidade ${n.toString().padLeft(2, '0')}',
  bairro: 'Centro',
  municipio: n.isEven ? 'Rio de Janeiro' : 'São Paulo',
  uf: n.isEven ? 'RJ' : 'SP',
  tempoEspera: 30.0 + n,
);

final _todas = [for (var n = 1; n <= 25; n++) _unidade(n)];

/// Um chamado ao catálogo, para conferir o que a tela pediu.
typedef _Pedido = ({String? nome, String? uf, int pagina});

/// Um Java de mentira com [_todas]: filtra por nome e UF, ordena (já estão em
/// ordem) e pagina de verdade.
///
/// [falhas] diz o que acontece em cada chamada, na ordem: `null` = responde
/// normal; uma exceção = lança. Passado o fim da lista, responde normal.
class _CatalogoFalso implements CatalogoRepository {
  _CatalogoFalso({this.falhas = const []});

  final List<Exception?> falhas;
  final List<_Pedido> pedidos = [];

  @override
  Future<PaginaDeUnidades> pagina({
    String? nome,
    String? uf,
    int pagina = 0,
    int tamanho = 10,
  }) async {
    pedidos.add((nome: nome, uf: uf, pagina: pagina));
    final indice = pedidos.length - 1;
    if (indice < falhas.length) {
      final falha = falhas[indice];
      if (falha != null) throw falha;
    }

    final termo = (nome ?? '').trim().toLowerCase();
    final sigla = (uf ?? '').toUpperCase();
    final filtradas = _todas
        .where(
          (u) =>
              (termo.isEmpty || u.nome.toLowerCase().contains(termo)) &&
              (sigla.isEmpty || u.uf == sigla),
        )
        .toList();

    final inicio = pagina * tamanho;
    final fim = math.min(inicio + tamanho, filtradas.length);
    return PaginaDeUnidades(
      unidades: inicio >= filtradas.length
          ? const []
          : filtradas.sublist(inicio, fim),
      pagina: pagina,
      totalElementos: filtradas.length,
      ultima: fim >= filtradas.length,
    );
  }
}

/// Responde só quando o teste manda: serve para "carregando" e para conferir
/// que a resposta velha é descartada.
class _CatalogoManual implements CatalogoRepository {
  final List<Completer<PaginaDeUnidades>> respostas = [];

  @override
  Future<PaginaDeUnidades> pagina({
    String? nome,
    String? uf,
    int pagina = 0,
    int tamanho = 10,
  }) {
    final resposta = Completer<PaginaDeUnidades>();
    respostas.add(resposta);
    return resposta.future;
  }
}

class _FavoritasFalso implements FavoritasRepository {
  _FavoritasFalso();

  final ValueNotifier<Set<int>> _ids = ValueNotifier({});

  @override
  ValueListenable<Set<int>> get ids => _ids;

  @override
  Future<void> carregar() async {}

  @override
  Future<void> definir(int id, {required bool favorita}) async {
    _ids.value = favorita ? {..._ids.value, id} : ({..._ids.value}..remove(id));
  }
}

PaginaDeUnidades _paginaCom(List<UnidadeResumo> unidades) => PaginaDeUnidades(
  unidades: unidades,
  pagina: 0,
  totalElementos: unidades.length,
  ultima: true,
);

/// Abre a aba Buscar numa tela de 390 x 844 (o tamanho do Figma). Por padrão
/// espera tudo carregar; para ver o "carregando", passe `esperar: false`.
Future<void> abrirBusca(
  WidgetTester tester, {
  CatalogoRepository? catalogo,
  FavoritasRepository? favoritas,
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
              child: AbaBuscar(
                catalogo: catalogo ?? _CatalogoFalso(),
                favoritas: favoritas ?? _FavoritasFalso(),
                tamanhoDaPagina: 10,
                // Curto para o teste não esperar à toa.
                atrasoDaDigitacao: const Duration(milliseconds: 50),
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

/// Rola a lista até [alvo] aparecer.
Future<void> rolarAte(WidgetTester tester, Finder alvo) {
  return tester.dragUntilVisible(
    alvo,
    find.byType(ListView),
    const Offset(0, -300),
  );
}

/// Digita [texto] no campo e espera a pausa da digitação passar.
Future<void> digitar(WidgetTester tester, String texto) async {
  await tester.enterText(find.byType(TextField), texto);
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('abre com o título, o campo, o filtro e o total', (tester) async {
    final catalogo = _CatalogoFalso();
    await abrirBusca(tester, catalogo: catalogo);

    expect(find.text('Buscar'), findsOneWidget);
    expect(find.text('Buscar unidade pelo nome'), findsOneWidget);
    expect(find.text('Estado: Todos'), findsOneWidget);
    expect(find.text('25 unidades · em ordem alfabética'), findsOneWidget);

    // Pediu só a primeira página, sem nenhum filtro.
    expect(catalogo.pedidos, [(nome: '', uf: '', pagina: 0)]);
  });

  testWidgets('mostra as unidades em ordem, com cidade e UF', (tester) async {
    await abrirBusca(tester);

    final alturaPrimeira = tester.getTopLeft(find.text('Unidade 01')).dy;
    final alturaSegunda = tester.getTopLeft(find.text('Unidade 02')).dy;
    expect(alturaPrimeira, lessThan(alturaSegunda));

    expect(find.textContaining('São Paulo, SP'), findsWidgets);
    expect(find.textContaining('Rio de Janeiro, RJ'), findsWidgets);
    // Na Busca não há "menor espera perto de você": ela não é por perto.
    expect(find.text('Menor espera perto de você'), findsNothing);
  });

  testWidgets('enquanto carrega: aviso e três cartões esqueleto', (
    tester,
  ) async {
    await abrirBusca(tester, catalogo: _CatalogoManual(), esperar: false);

    expect(find.text('Buscando unidades…'), findsOneWidget);
    expect(find.byType(NexaUnidadeCardCarregando), findsNWidgets(3));
    expect(find.byType(NexaUnidadeCard), findsNothing);
  });

  testWidgets('rolar até perto do fim pede a página seguinte', (tester) async {
    final catalogo = _CatalogoFalso();
    await abrirBusca(tester, catalogo: catalogo);
    expect(find.text('Unidade 11'), findsNothing);

    await rolarAte(tester, find.text('Unidade 11'));
    await tester.pumpAndSettle();

    expect(catalogo.pedidos.map((p) => p.pagina), contains(1));
    expect(find.text('Unidade 11'), findsOneWidget);
  });

  testWidgets('chega até a última página e para de pedir', (tester) async {
    final catalogo = _CatalogoFalso();
    await abrirBusca(tester, catalogo: catalogo);

    await rolarAte(tester, find.text('Unidade 25'));
    await tester.pumpAndSettle();

    // Páginas 0, 1 e 2, cada uma uma vez só.
    expect(catalogo.pedidos.map((p) => p.pagina).toList(), [0, 1, 2]);
    expect(find.text('Unidade 25'), findsOneWidget);
  });

  testWidgets('filtrar por estado: escolhe SP na folha e refaz a busca', (
    tester,
  ) async {
    final catalogo = _CatalogoFalso();
    await abrirBusca(tester, catalogo: catalogo);

    await tester.tap(find.text('Estado: Todos'));
    await tester.pumpAndSettle();
    expect(find.text('Filtrar por estado'), findsOneWidget);
    expect(find.text('Todos os estados'), findsOneWidget);

    await tester.ensureVisible(find.text('São Paulo (SP)'));
    await tester.tap(find.text('São Paulo (SP)'));
    await tester.pumpAndSettle();

    expect(find.text('Estado: SP'), findsOneWidget);
    expect(catalogo.pedidos.last, (nome: '', uf: 'SP', pagina: 0));
    // Só as de São Paulo (as 13 ímpares).
    expect(find.text('13 unidades · em ordem alfabética'), findsOneWidget);
    expect(find.text('Unidade 02'), findsNothing);
  });

  testWidgets('"Todos os estados" na folha tira o filtro', (tester) async {
    final catalogo = _CatalogoFalso();
    await abrirBusca(tester, catalogo: catalogo);

    await tester.tap(find.text('Estado: Todos'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Rio de Janeiro (RJ)'));
    await tester.tap(find.text('Rio de Janeiro (RJ)'));
    await tester.pumpAndSettle();
    expect(find.text('Estado: RJ'), findsOneWidget);

    await tester.tap(find.text('Estado: RJ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Todos os estados'));
    await tester.pumpAndSettle();

    expect(find.text('Estado: Todos'), findsOneWidget);
    expect(catalogo.pedidos.last, (nome: '', uf: '', pagina: 0));
    expect(find.text('25 unidades · em ordem alfabética'), findsOneWidget);
  });

  testWidgets('fechar a folha sem escolher não refaz a busca', (tester) async {
    final catalogo = _CatalogoFalso();
    await abrirBusca(tester, catalogo: catalogo);

    await tester.tap(find.text('Estado: Todos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();

    expect(catalogo.pedidos, hasLength(1));
    expect(find.text('Estado: Todos'), findsOneWidget);
  });

  testWidgets('digitar busca pelo nome depois de uma pausa', (tester) async {
    final catalogo = _CatalogoFalso();
    await abrirBusca(tester, catalogo: catalogo);

    await digitar(tester, 'Unidade 2');

    expect(catalogo.pedidos.last, (nome: 'Unidade 2', uf: '', pagina: 0));
    // Unidade 20 a 25.
    expect(find.text('6 unidades · em ordem alfabética'), findsOneWidget);
  });

  testWidgets('digitar rápido faz uma busca só, com o texto final', (
    tester,
  ) async {
    final catalogo = _CatalogoFalso();
    await abrirBusca(tester, catalogo: catalogo);

    await tester.enterText(find.byType(TextField), 'U');
    await tester.pump(const Duration(milliseconds: 10));
    await tester.enterText(find.byType(TextField), 'Un');
    await tester.pump(const Duration(milliseconds: 10));
    await tester.enterText(find.byType(TextField), 'Uni');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    // A busca inicial e uma só depois da pausa.
    expect(catalogo.pedidos, hasLength(2));
    expect(catalogo.pedidos.last.nome, 'Uni');
  });

  testWidgets('sem resultado: mensagem e "Limpar filtros" volta à lista', (
    tester,
  ) async {
    await abrirBusca(tester);

    await digitar(tester, 'nome que não existe');
    expect(find.text('Nenhuma unidade encontrada'), findsOneWidget);
    expect(find.byType(NexaUnidadeCard), findsNothing);

    await tester.tap(find.text('Limpar filtros'));
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma unidade encontrada'), findsNothing);
    expect(find.text('25 unidades · em ordem alfabética'), findsOneWidget);
    // O campo também foi esvaziado.
    final campo = tester.widget<TextField>(find.byType(TextField));
    expect(campo.controller?.text, isEmpty);
  });

  testWidgets('a resposta de uma busca velha é descartada', (tester) async {
    final catalogo = _CatalogoManual();
    await abrirBusca(tester, catalogo: catalogo, esperar: false);
    expect(catalogo.respostas, hasLength(1)); // a busca inicial, ainda pendente

    await tester.enterText(find.byType(TextField), 'Unidade 20');
    await tester.pump(const Duration(milliseconds: 100));
    expect(catalogo.respostas, hasLength(2)); // a busca nova

    // A nova chega primeiro; a velha chega depois e não pode sobrescrevê-la.
    catalogo.respostas[1].complete(_paginaCom([_unidade(20)]));
    await tester.pumpAndSettle();
    catalogo.respostas[0].complete(_paginaCom([_unidade(1)]));
    await tester.pumpAndSettle();

    expect(find.text('Unidade 20'), findsOneWidget);
    expect(find.text('Unidade 01'), findsNothing);
  });

  testWidgets('erro do servidor: mostra o erro e "Tentar de novo" recarrega', (
    tester,
  ) async {
    final catalogo = _CatalogoFalso(falhas: [const ErroInesperado()]);
    await abrirBusca(tester, catalogo: catalogo);

    expect(find.text('Algo deu errado do nosso lado'), findsOneWidget);
    expect(find.byType(NexaUnidadeCard), findsNothing);

    await tester.tap(find.text('Tentar de novo'));
    await tester.pumpAndSettle();

    expect(catalogo.pedidos, hasLength(2));
    expect(find.text('Algo deu errado do nosso lado'), findsNothing);
    expect(find.text('Unidade 01'), findsOneWidget);
  });

  testWidgets('sem internet: pede para conferir a conexão', (tester) async {
    await abrirBusca(
      tester,
      catalogo: _CatalogoFalso(falhas: [const SemConexao()]),
    );

    expect(find.text('Sem conexão com a internet'), findsOneWidget);
    expect(find.text('Tentar de novo'), findsOneWidget);
    // Com a lista inteira falha, o total ("25 unidades") não aparece.
    expect(find.textContaining('unidades · em ordem'), findsNothing);
  });

  testWidgets(
    'falha ao carregar mais: a lista fica e "Tentar de novo" pede só essa página',
    (tester) async {
      // 1ª chamada ok; 2ª (página 1) falha; 3ª ok.
      final catalogo = _CatalogoFalso(falhas: [null, const SemConexao()]);
      await abrirBusca(tester, catalogo: catalogo);

      await rolarAte(tester, find.text('Não deu para carregar mais unidades.'));
      await tester.pumpAndSettle();

      expect(find.text('Não deu para carregar mais unidades.'), findsOneWidget);
      // A lista de cima continua lá.
      expect(find.byType(NexaUnidadeCard), findsWidgets);

      await tester.tap(find.text('Tentar de novo'));
      await tester.pumpAndSettle();

      expect(catalogo.pedidos.map((p) => p.pagina).toList(), [0, 1, 1]);
      expect(
        find.text('Não deu para carregar mais unidades.'),
        findsNothing,
      );
      await rolarAte(tester, find.text('Unidade 11'));
      expect(find.text('Unidade 11'), findsOneWidget);
    },
  );

  testWidgets('tocar no coração favorita e desfavorita a unidade', (
    tester,
  ) async {
    final favoritas = _FavoritasFalso();
    await abrirBusca(tester, favoritas: favoritas);

    await tester.tap(find.byTooltip('Adicionar às favoritas: Unidade 01'));
    await tester.pumpAndSettle();
    expect(favoritas.ids.value, {1});
    expect(
      find.byTooltip('Remover das favoritas: Unidade 01'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Remover das favoritas: Unidade 01'));
    await tester.pumpAndSettle();
    expect(favoritas.ids.value, isEmpty);
  });
}

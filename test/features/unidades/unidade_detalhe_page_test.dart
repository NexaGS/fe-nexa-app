import 'package:fe_nexa_app/app/theme/nexa_theme.dart';
import 'package:fe_nexa_app/features/unidades/data/acoes_unidade.dart';
import 'package:fe_nexa_app/features/unidades/data/favoritas_repository.dart';
import 'package:fe_nexa_app/features/unidades/data/unidade_resumo.dart';
import 'package:fe_nexa_app/features/unidades/unidade_detalhe_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _AcoesFalso implements AcoesUnidade {
  _AcoesFalso({this.abre = true});

  final bool abre;
  final rotas = <String>[];
  final compartilhados = <String>[];

  @override
  Future<bool> abrirRota(String destino) async {
    rotas.add(destino);
    return abre;
  }

  @override
  Future<void> compartilhar(String texto) async => compartilhados.add(texto);
}

class _FavoritasFalso implements FavoritasRepository {
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

const _completa = UnidadeResumo(
  id: 7,
  nome: 'Unidade B',
  cep: '01311000',
  logradouro: 'Rua das Acácias',
  numero: '120',
  bairro: 'Vila Nova',
  municipio: 'São Paulo',
  uf: 'SP',
  tempoEspera: 40,
  distanciaKm: 3,
);

Future<void> abrir(
  WidgetTester tester,
  UnidadeResumo unidade, {
  AcoesUnidade? acoes,
  FavoritasRepository? favoritas,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: buildNexaTheme(),
      home: UnidadeDetalhePage(
        unidade: unidade,
        acoes: acoes ?? _AcoesFalso(),
        favoritas: favoritas ?? _FavoritasFalso(),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('mostra espera, selo, endereço, distância e "Ao chegar"', (
    tester,
  ) async {
    await abrir(tester, _completa);

    expect(find.text('Unidade B'), findsOneWidget);
    expect(find.text('Espera estimada'), findsOneWidget);
    expect(find.text('40 min'), findsOneWidget);
    expect(find.text('Espera curta'), findsOneWidget);
    expect(find.text('Rua das Acácias, 120 · Vila Nova, São Paulo'), findsOneWidget);
    expect(find.text('3 km de você'), findsOneWidget);
    expect(find.text('Ao chegar'), findsOneWidget);
    expect(find.textContaining('Faça o check-in no totem'), findsOneWidget);
    expect(find.text('Como chegar'), findsOneWidget);
    expect(find.text('Compartilhar'), findsOneWidget);
  });

  testWidgets('o que o Java não manda não aparece', (tester) async {
    await abrir(tester, const UnidadeResumo(id: 1, nome: 'Sem dados'));

    expect(find.text('Estimativa indisponível'), findsOneWidget);
    expect(find.text('Endereço'), findsNothing);
    expect(find.text('Distância'), findsNothing);
    expect(find.text('Telefone'), findsNothing);
  });

  testWidgets('"Como calculamos?" abre a folha da espera', (tester) async {
    await abrir(tester, _completa);

    await tester.tap(find.text('Como calculamos?'));
    await tester.pumpAndSettle();

    expect(find.text('Como calculamos a espera'), findsOneWidget);
  });

  testWidgets('"Como chegar" abre a rota até o endereço', (tester) async {
    final acoes = _AcoesFalso();
    await abrir(tester, _completa, acoes: acoes);

    await tester.tap(find.text('Como chegar'));
    await tester.pump();

    expect(acoes.rotas, [
      'Rua das Acácias, 120, Vila Nova, São Paulo - SP, 01311000',
    ]);
  });

  testWidgets('sem endereço, a rota usa o nome da unidade', (tester) async {
    final acoes = _AcoesFalso();
    await abrir(tester, const UnidadeResumo(id: 1, nome: 'UPA Centro'), acoes: acoes);

    await tester.tap(find.text('Como chegar'));
    await tester.pump();

    expect(acoes.rotas, ['UPA Centro']);
  });

  testWidgets('se o mapa não abre, avisa com um snackbar', (tester) async {
    await abrir(tester, _completa, acoes: _AcoesFalso(abre: false));

    await tester.tap(find.text('Como chegar'));
    await tester.pump();

    expect(find.text('Não consegui abrir o mapa neste aparelho.'), findsOneWidget);
  });

  testWidgets('"Compartilhar" manda nome, endereço, espera e link da rota', (
    tester,
  ) async {
    final acoes = _AcoesFalso();
    await abrir(tester, _completa, acoes: acoes);

    await tester.tap(find.text('Compartilhar'));
    await tester.pump();

    final texto = acoes.compartilhados.single;
    expect(texto, contains('Unidade B'));
    expect(texto, contains('Rua das Acácias, 120 · Vila Nova, São Paulo'));
    expect(texto, contains('Espera estimada: Cerca de 40 min'));
    expect(texto, contains('https://www.google.com/maps/dir/?api=1&destination='));
  });

  testWidgets('o coração da barra favorita e desfavorita', (tester) async {
    final favoritas = _FavoritasFalso();
    await abrir(tester, _completa, favoritas: favoritas);

    await tester.tap(find.byTooltip('Adicionar às favoritas: Unidade B'));
    await tester.pump();
    expect(favoritas.ids.value, {7});

    await tester.tap(find.byTooltip('Remover das favoritas: Unidade B'));
    await tester.pump();
    expect(favoritas.ids.value, isEmpty);
  });
}

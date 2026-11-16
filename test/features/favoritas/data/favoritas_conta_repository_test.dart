import 'dart:convert';

import 'package:fe_nexa_app/features/auth/data/auth_repository.dart'
    show ErroInesperado, SemConexao;
import 'package:fe_nexa_app/features/auth/data/sessao_service.dart';
import 'package:fe_nexa_app/features/favoritas/data/favoritas_conta_repository.dart';
import 'package:fe_nexa_app/features/favoritas/data/favoritas_remotas.dart';
import 'package:fe_nexa_app/features/unidades/data/favoritas_repository.dart';
import 'package:fe_nexa_app/features/unidades/data/unidade_resumo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/fakes_auth.dart';

http.Response _json(Object corpo, [int status = 200]) => http.Response.bytes(
  utf8.encode(jsonEncode(corpo)),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

Map<String, Object?> _unidade(int id, String nome, [double? espera]) => {
  'id': id,
  'nomeUnidade': nome,
  'tempoEspera': espera,
};

class _RemotasFalsas implements FavoritasRemotas {
  _RemotasFalsas({Set<int> daConta = const {}}) : noServidor = {...daConta};

  final Set<int> noServidor;
  final pedidos = <String>[];
  bool falhar = false;

  @override
  Future<List<UnidadeResumo>> listar({
    double? latitude,
    double? longitude,
  }) async {
    pedidos.add('listar');
    return [
      for (final id in noServidor) UnidadeResumo(id: id, nome: 'Unidade $id'),
    ];
  }

  @override
  Future<void> definir(int id, {required bool favorita}) async {
    pedidos.add(favorita ? 'add $id' : 'del $id');
    if (falhar) throw const SemConexao();
    favorita ? noServidor.add(id) : noServidor.remove(id);
  }

  @override
  Future<UnidadeResumo> unidadePorId(int id) async {
    pedidos.add('porId $id');
    if (id == 99) throw const ErroInesperado();
    return UnidadeResumo(id: id, nome: 'Unidade $id');
  }
}

void main() {
  group('FavoritasRemotasHttp', () {
    FavoritasRemotasHttp remotas(
      Future<http.Response> Function(http.Request) aoPedir,
    ) => FavoritasRemotasHttp(
      baseUrl: 'http://api.teste',
      cliente: MockClient(aoPedir),
    );

    test('listar lê o array e manda a posição quando existe', () async {
      late Uri pedido;
      final r = remotas((request) async {
        pedido = request.url;
        return _json([_unidade(2, 'UBS B', 40)]);
      });

      final lista = await r.listar(latitude: -23.5, longitude: -46.6);

      expect(pedido.path, '/api/cidadaos/usuario/favoritas');
      expect(pedido.queryParameters, {
        'latitude': '-23.5',
        'longitude': '-46.6',
      });
      expect(lista.single.nome, 'UBS B');
      expect(lista.single.tempoEspera, 40);
    });

    test('listar sem posição não manda parâmetros', () async {
      late Uri pedido;
      final r = remotas((request) async {
        pedido = request.url;
        return _json([]);
      });

      await r.listar();

      expect(pedido.hasQuery, isFalse);
    });

    test('definir usa PUT para favoritar e DELETE para desfavoritar', () async {
      final chamadas = <String>[];
      final r = remotas((request) async {
        chamadas.add('${request.method} ${request.url.path}');
        return _json({});
      });

      await r.definir(7, favorita: true);
      await r.definir(7, favorita: false);

      expect(chamadas, [
        'PUT /api/cidadaos/usuario/adicionarUnidade/7',
        'DELETE /api/cidadaos/usuario/removerUnidade/7',
      ]);
    });

    test('desfavoritar o que já não era favorita (404) não é erro', () async {
      final r = remotas((_) async => _json({}, 404));

      await r.definir(7, favorita: false);
      expect(
        () => r.definir(7, favorita: true),
        throwsA(isA<ErroInesperado>()),
      );
    });

    test('resposta com erro do servidor vira ErroInesperado', () async {
      final r = remotas((_) async => _json({}, 500));

      expect(r.listar(), throwsA(isA<ErroInesperado>()));
    });

    test('falha de rede vira SemConexao', () async {
      final r = remotas((_) async => throw http.ClientException('sem rede'));

      expect(r.listar(), throwsA(isA<SemConexao>()));
    });

    test('unidadePorId lê uma unidade só', () async {
      final r = remotas((request) async {
        expect(request.url.path, '/api/unidades/5');
        return _json(_unidade(5, 'UBS Cinco'));
      });

      expect((await r.unidadePorId(5)).nome, 'UBS Cinco');
    });
  });

  group('FavoritasRepositoryDaConta', () {
    late SessaoService sessoes;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      sessoes = SessaoService(
        auth: AuthFalso(),
        armazenamento: SessoesFalso(),
      );
    });

    FavoritasRepositoryDaConta criar(_RemotasFalsas remotas) =>
        FavoritasRepositoryDaConta(sessoes: sessoes, remotas: remotas);

    Future<void> entrar() => sessoes.entrou(sessaoDeTeste());

    test('visitante guarda só no aparelho, sem falar com o Spring', () async {
      final remotas = _RemotasFalsas();
      final repo = criar(remotas);
      await repo.carregar();

      await repo.definir(4, favorita: true);

      expect(repo.ids.value, {4});
      expect(remotas.pedidos, isEmpty);
      final outro = criar(remotas);
      await outro.carregar();
      expect(outro.ids.value, {4});
    });

    test('quem tem conta lê as favoritas do Spring', () async {
      await entrar();
      final repo = criar(_RemotasFalsas(daConta: {1, 2}));

      await repo.carregar();

      expect(repo.ids.value, {1, 2});
    });

    test('favoritar e desfavoritar com conta chamam o Spring', () async {
      await entrar();
      final remotas = _RemotasFalsas();
      final repo = criar(remotas);
      await repo.carregar();

      await repo.definir(3, favorita: true);
      expect(repo.ids.value, {3});
      await repo.definir(3, favorita: false);

      expect(repo.ids.value, isEmpty);
      expect(remotas.pedidos, containsAllInOrder(['add 3', 'del 3']));
    });

    test('se o Spring falhar, volta atrás e lança FavoritaNaoSalva', () async {
      await entrar();
      final remotas = _RemotasFalsas()..falhar = true;
      final repo = criar(remotas);
      await repo.carregar();

      await expectLater(
        repo.definir(3, favorita: true),
        throwsA(isA<FavoritaNaoSalva>()),
      );

      expect(repo.ids.value, isEmpty);
    });

    test('ao entrar na conta, as favoritas do aparelho vão para ela', () async {
      SharedPreferences.setMockInitialValues({
        'favoritas_unidades': ['8', '9'],
      });
      final remotas = _RemotasFalsas(daConta: {1});
      final repo = criar(remotas);
      await repo.carregar();
      expect(repo.ids.value, {8, 9});

      await entrar();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(remotas.noServidor, {1, 8, 9});
      expect(repo.ids.value, {1, 8, 9});
      final local = FavoritasRepositoryLocal();
      await local.carregar();
      expect(local.ids.value, isEmpty);
    });

    test('carregarUnidades: conta usa a lista do Spring', () async {
      await entrar();
      final remotas = _RemotasFalsas(daConta: {5});
      final repo = criar(remotas);

      final unidades = await repo.carregarUnidades(latitude: 1, longitude: 2);

      expect(unidades.single.id, 5);
      expect(remotas.pedidos, ['listar']);
    });

    test('carregarUnidade busca uma só pelo id, sem a lista da conta', () async {
      await entrar();
      final remotas = _RemotasFalsas();
      final repo = criar(remotas);

      expect((await repo.carregarUnidade(7))?.id, 7);
      expect(await repo.carregarUnidade(99), isNull);
      expect(remotas.pedidos, ['porId 7', 'porId 99']);
    });

    test('carregarUnidades: visitante busca cada id e ignora as sumidas', () async {
      SharedPreferences.setMockInitialValues({
        'favoritas_unidades': ['5', '99'],
      });
      final remotas = _RemotasFalsas();
      final repo = criar(remotas);

      final unidades = await repo.carregarUnidades();

      expect(unidades.map((u) => u.id), [5]);
      expect(remotas.pedidos, containsAll(['porId 5', 'porId 99']));
    });
  });
}

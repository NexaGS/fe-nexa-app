import 'dart:convert';
import 'dart:io';

import 'package:fe_nexa_app/features/auth/data/auth_repository.dart'
    show ErroInesperado, SemConexao;
import 'package:fe_nexa_app/features/unidades/data/unidades_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Uma resposta do Java: o JSON em UTF-8, como o Spring manda.
http.Response _resposta(Object corpo, [int status = 200]) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(corpo)),
    status,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

UnidadesRepositoryHttp _repositorio(
  Future<http.Response> Function(http.Request) aoPedir,
) {
  return UnidadesRepositoryHttp(
    baseUrl: 'http://api.teste',
    cliente: MockClient(aoPedir),
  );
}

void main() {
  test('pede /api/unidades/proximas com a posição e lê o conteudo', () async {
    late Uri pedido;
    final repositorio = _repositorio((request) async {
      pedido = request.url;
      return _resposta({
        'conteudo': [
          {
            'id': 1,
            'nomeUnidade': 'UBS Vila Olímpia',
            'bairro': 'Vila Olímpia',
            'tempoEspera': 20.0,
            'tipoUnidade': 'POSTO_DE_SAUDE',
          },
        ],
        'pagina': 0,
        'tamanho': 5,
        'totalElementos': 1,
        'totalPaginas': 1,
        'ultimo': true,
      });
    });

    final unidades = await repositorio.proximas(
      latitude: -23.5648865,
      longitude: -46.6529992,
    );

    expect(pedido.host, 'api.teste');
    expect(pedido.path, '/api/unidades/proximas');
    expect(pedido.queryParameters, {
      'latitude': '-23.5648865',
      'longitude': '-46.6529992',
      'pagina': '0',
      'tamanho': '5',
    });
    expect(unidades, hasLength(1));
    expect(unidades.single.nome, 'UBS Vila Olímpia'); // acento preservado
    expect(unidades.single.tempoEspera, 20.0);
  });

  test('conteudo vazio devolve lista vazia', () async {
    final repositorio = _repositorio(
      (_) async => _resposta({'conteudo': []}),
    );
    expect(await repositorio.proximas(latitude: 0, longitude: 0), isEmpty);
  });

  test('status diferente de 200 vira ErroInesperado', () async {
    final repositorio = _repositorio(
      (_) async => _resposta({'mensagem': 'erro'}, 500),
    );
    expect(
      repositorio.proximas(latitude: 0, longitude: 0),
      throwsA(isA<ErroInesperado>()),
    );
  });

  test('corpo que não é JSON vira ErroInesperado', () async {
    final repositorio = _repositorio((_) async => http.Response('oi', 200));
    expect(
      repositorio.proximas(latitude: 0, longitude: 0),
      throwsA(isA<ErroInesperado>()),
    );
  });

  test('JSON sem conteudo vira ErroInesperado', () async {
    final repositorio = _repositorio((_) async => _resposta({'outro': 1}));
    expect(
      repositorio.proximas(latitude: 0, longitude: 0),
      throwsA(isA<ErroInesperado>()),
    );
  });

  test('item sem id vira ErroInesperado', () async {
    final repositorio = _repositorio(
      (_) async => _resposta({
        'conteudo': [
          {'nomeUnidade': 'sem id'},
        ],
      }),
    );
    expect(
      repositorio.proximas(latitude: 0, longitude: 0),
      throwsA(isA<ErroInesperado>()),
    );
  });

  test('sem conseguir falar com o servidor vira SemConexao', () async {
    final repositorio = _repositorio(
      (_) async => throw const SocketException('sem rede'),
    );
    expect(
      repositorio.proximas(latitude: 0, longitude: 0),
      throwsA(isA<SemConexao>()),
    );
  });

  test('ClientException do http também vira SemConexao', () async {
    final repositorio = _repositorio(
      (_) async => throw http.ClientException('conexão caiu'),
    );
    expect(
      repositorio.proximas(latitude: 0, longitude: 0),
      throwsA(isA<SemConexao>()),
    );
  });
}

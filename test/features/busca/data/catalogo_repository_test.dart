import 'dart:convert';
import 'dart:io';

import 'package:fe_nexa_app/features/auth/data/auth_repository.dart'
    show ErroInesperado, SemConexao;
import 'package:fe_nexa_app/features/busca/data/catalogo_repository.dart';
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

CatalogoRepositoryHttp _repositorio(
  Future<http.Response> Function(http.Request) aoPedir,
) {
  return CatalogoRepositoryHttp(
    baseUrl: 'http://api.teste',
    cliente: MockClient(aoPedir),
  );
}

Map<String, Object> _pagina({
  List<Map<String, Object>> conteudo = const [],
  int pagina = 0,
  int total = 0,
  bool ultimo = true,
}) => {
  'conteudo': conteudo,
  'pagina': pagina,
  'tamanho': 10,
  'totalElementos': total,
  'totalPaginas': 1,
  'ultimo': ultimo,
};

void main() {
  test('pede /api/unidades e lê a página, com cidade e UF', () async {
    late Uri pedido;
    final repositorio = _repositorio((request) async {
      pedido = request.url;
      return _resposta(
        _pagina(
          conteudo: [
            {
              'id': 7,
              'nomeUnidade': 'UBS Mineira - Centro',
              'bairro': 'Centro',
              'tempoEspera': 50.0,
              'tipoUnidade': 'CENTRO_DE_SAUDE_UNIDADE_BASICA',
              'municipio': 'Belo Horizonte',
              'uf': 'MG',
            },
          ],
          pagina: 1,
          total: 11,
          ultimo: true,
        ),
      );
    });

    final pagina = await repositorio.pagina(pagina: 1);

    expect(pedido.host, 'api.teste');
    expect(pedido.path, '/api/unidades');
    expect(pagina.pagina, 1);
    expect(pagina.totalElementos, 11);
    expect(pagina.ultima, isTrue);
    expect(pagina.unidades.single.nome, 'UBS Mineira - Centro');
    expect(pagina.unidades.single.municipio, 'Belo Horizonte');
    expect(pagina.unidades.single.uf, 'MG');
  });

  test('sem filtros, só manda pagina e tamanho', () async {
    late Uri pedido;
    final repositorio = _repositorio((request) async {
      pedido = request.url;
      return _resposta(_pagina());
    });

    await repositorio.pagina(nome: '', uf: '  ', tamanho: 20);

    expect(pedido.queryParameters, {'pagina': '0', 'tamanho': '20'});
  });

  test('com filtros, manda nome (sem espaços nas pontas) e uf', () async {
    late Uri pedido;
    final repositorio = _repositorio((request) async {
      pedido = request.url;
      return _resposta(_pagina());
    });

    await repositorio.pagina(nome: '  São Mateus ', uf: 'SP');

    expect(pedido.queryParameters['nome'], 'São Mateus');
    expect(pedido.queryParameters['uf'], 'SP');
  });

  test('status diferente de 200 vira ErroInesperado', () async {
    final repositorio = _repositorio((_) async => _resposta({}, 500));
    await expectLater(repositorio.pagina(), throwsA(isA<ErroInesperado>()));
  });

  test('JSON quebrado ou com outro formato vira ErroInesperado', () async {
    final quebrado = _repositorio(
      (_) async => http.Response('isto não é json', 200),
    );
    await expectLater(quebrado.pagina(), throwsA(isA<ErroInesperado>()));

    final semConteudo = _repositorio((_) async => _resposta({'x': 1}));
    await expectLater(semConteudo.pagina(), throwsA(isA<ErroInesperado>()));
  });

  test('sem rede vira SemConexao', () async {
    final repositorio = _repositorio((_) async => throw const SocketException('x'));
    await expectLater(repositorio.pagina(), throwsA(isA<SemConexao>()));
  });
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fe_nexa_app/app/config/api_config.dart';
import 'package:fe_nexa_app/features/auth/data/auth_repository.dart'
    show ErroInesperado, SemConexao;
import 'package:fe_nexa_app/features/unidades/data/unidade_resumo.dart';
import 'package:http/http.dart' as http;

/// Uma página do catálogo, como o Java devolve (`PageResponse`).
class PaginaDeUnidades {
  const PaginaDeUnidades({
    required this.unidades,
    required this.pagina,
    required this.totalElementos,
    required this.ultima,
  });

  /// As unidades desta página (`conteudo`).
  final List<UnidadeResumo> unidades;

  /// O número desta página; a primeira é a `0`.
  final int pagina;

  /// Quantas unidades existem no total para o filtro pedido, em todas as páginas.
  final int totalElementos;

  /// `true` quando não há página depois desta (`ultimo`).
  final bool ultima;
}

/// O contrato: a Busca pede o catálogo de unidades sem saber como o Java responde.
abstract interface class CatalogoRepository {
  /// Uma página das unidades cadastradas, em ordem alfabética pelo nome.
  Future<PaginaDeUnidades> pagina({
    String? nome,
    String? uf,
    int pagina = 0,
    int tamanho = 10,
  });
}

/// `GET /api/unidades?nome=&uf=&pagina=&tamanho=`
/// -> 200 com `PageResponse<UnidadeSaudeResponse>`.
class CatalogoRepositoryHttp implements CatalogoRepository {
  /// Em teste, passe um `MockClient` (de `package:http/testing.dart`) em
  /// [cliente] para não depender da rede.
  CatalogoRepositoryHttp({required this.baseUrl, http.Client? cliente})
    : _cliente = cliente ?? http.Client();

  final String baseUrl;
  final http.Client _cliente;

  @override
  Future<PaginaDeUnidades> pagina({
    String? nome,
    String? uf,
    int pagina = 0,
    int tamanho = 10,
  }) async {
    final termo = nome?.trim();
    final sigla = uf?.trim();
    final uri = Uri.parse('$baseUrl/api/unidades').replace(
      queryParameters: {
        'pagina': pagina.toString(),
        'tamanho': tamanho.toString(),
        if (termo != null && termo.isNotEmpty) 'nome': termo,
        if (sigla != null && sigla.isNotEmpty) 'uf': sigla,
      },
    );

    final resposta = await _buscar(uri);
    if (resposta.statusCode != 200) throw const ErroInesperado();

    try {
      final json =
          jsonDecode(utf8.decode(resposta.bodyBytes)) as Map<String, dynamic>;
      final conteudo = json['conteudo'] as List<dynamic>;
      return PaginaDeUnidades(
        unidades: [
          for (final item in conteudo)
            UnidadeResumo.fromJson(item as Map<String, dynamic>),
        ],
        pagina: (json['pagina'] as num).toInt(),
        totalElementos: (json['totalElementos'] as num).toInt(),
        ultima: json['ultimo'] as bool,
      );
    } on FormatException {
      throw const ErroInesperado();
    } on TypeError {
      throw const ErroInesperado();
    }
  }

  /// Faz o GET e traduz "não consegui falar com o servidor" em SemConexao.
  Future<http.Response> _buscar(Uri uri) async {
    try {
      return await _cliente.get(uri).timeout(const Duration(seconds: 10));
    } on SocketException {
      throw const SemConexao();
    } on TimeoutException {
      throw const SemConexao();
    } on http.ClientException {
      throw const SemConexao();
    }
  }
}

/// A instância que a Busca usa. Para testar sem rede, passe outra classe que
/// também `implements CatalogoRepository` na tela.
final CatalogoRepository catalogoRepository = CatalogoRepositoryHttp(
  baseUrl: ApiConfig.baseUrl,
);

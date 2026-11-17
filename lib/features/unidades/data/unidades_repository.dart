import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fe_nexa_app/app/config/api_config.dart';
import 'package:fe_nexa_app/features/auth/data/auth_repository.dart'
    show ErroInesperado, SemConexao;
import 'package:fe_nexa_app/features/unidades/data/unidade_resumo.dart';
import 'package:http/http.dart' as http;

/// O contrato: as telas pedem unidades sem saber como o Java responde.
abstract interface class UnidadesRepository {
  /// As [tamanho] unidades mais próximas de um ponto, sem limite de distância,
  /// na ordem em que o Java devolve (primeiro a distância, depois a espera).
  /// [tamanho] é a escolha da pessoa no Perfil: 3, 5 ou 10.
  Future<List<UnidadeResumo>> proximas({
    required double latitude,
    required double longitude,
    int tamanho = 5,
  });

  /// Uma unidade pelo id. A resposta não traz a distância, só os dados e a
  /// espera atual.
  Future<UnidadeResumo> porId(int id);
}

/// `GET /api/unidades/proximas?latitude=&longitude=&pagina=&tamanho=`
/// -> 200 com `PageResponse<UnidadeSaudeResponse>` (a lista vem em `conteudo`).
class UnidadesRepositoryHttp implements UnidadesRepository {

  UnidadesRepositoryHttp({required this.baseUrl, http.Client? cliente})
    : _cliente = cliente ?? http.Client();

  final String baseUrl;
  final http.Client _cliente;

  @override
  Future<List<UnidadeResumo>> proximas({
    required double latitude,
    required double longitude,
    int tamanho = 5,
  }) async {
    final uri = Uri.parse('$baseUrl/api/unidades/proximas').replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'pagina': '0',
        'tamanho': tamanho.toString(),
      },
    );

    final resposta = await _buscar(uri);
    if (resposta.statusCode != 200) throw const ErroInesperado();

    try {
      final json =
          jsonDecode(utf8.decode(resposta.bodyBytes)) as Map<String, dynamic>;
      final conteudo = json['conteudo'] as List<dynamic>;
      return [
        for (final item in conteudo)
          UnidadeResumo.fromJson(item as Map<String, dynamic>),
      ];
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

  @override
  Future<UnidadeResumo> porId(int id) async {
    final resposta = await _buscar(Uri.parse('$baseUrl/api/unidades/$id'));
    if (resposta.statusCode != 200) throw const ErroInesperado();

    try {
      final json =
      jsonDecode(utf8.decode(resposta.bodyBytes)) as Map<String, dynamic>;
      return UnidadeResumo.fromJson(json);
    } on FormatException {
      throw const ErroInesperado();
    } on TypeError {
      throw const ErroInesperado();
    }
  }
}

/// A instância que as telas usam. Para testar sem rede, passe outra classe
/// que também `implements UnidadesRepository` na tela.
final UnidadesRepository unidadesRepository = UnidadesRepositoryHttp(
  baseUrl: ApiConfig.baseUrl,
);

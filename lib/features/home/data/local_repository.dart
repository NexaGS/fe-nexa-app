import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fe_nexa_app/app/config/api_config.dart';
import 'package:fe_nexa_app/features/auth/data/auth_repository.dart'
    show ErroInesperado, SemConexao;
import 'package:fe_nexa_app/features/home/data/localizacao_service.dart';
import 'package:http/http.dart' as http;

/// O endereço de um ponto no mapa, como o Java devolve (LocalizacaoResponse).
/// Aqui só guardamos o que a tela usa.
class LocalDescrito {
  const LocalDescrito({this.bairro, this.municipio});

  final String? bairro;
  final String? municipio;

  /// Texto pronto para a tela: "Bela Vista, São Paulo". Se o Google não
  /// souber um dos dois, mostra só o outro.
  String get rotulo {
    final partes =
        [bairro, municipio].whereType<String>().where((p) => p.isNotEmpty);
    return partes.isEmpty ? 'Local não identificado' : partes.join(', ');
  }
}

/// O contrato: a tela pede o nome do local sem saber como o Java responde.
abstract interface class LocalRepository {
  Future<LocalDescrito> descrever(Posicao posicao);
}

/// `GET /api/localizacoes/reversa` -> 200 com o endereço (LocalizacaoResponse).
class LocalRepositoryHttp implements LocalRepository {
  LocalRepositoryHttp({required this.baseUrl});

  final String baseUrl;

  @override
  Future<LocalDescrito> descrever(Posicao posicao) async {
    final uri = Uri.parse('$baseUrl/api/localizacoes/reversa').replace(
      queryParameters: {
        'latitude': posicao.latitude.toString(),
        'longitude': posicao.longitude.toString(),
      },
    );

    final resposta = await _buscar(uri);
    if (resposta.statusCode != 200) throw const ErroInesperado();

    try {
      final json =
          jsonDecode(utf8.decode(resposta.bodyBytes)) as Map<String, dynamic>;
      return LocalDescrito(
        bairro: json['bairro'] as String?,
        municipio: json['municipio'] as String?,
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
      return await http.get(uri).timeout(const Duration(seconds: 10));
    } on SocketException {
      throw const SemConexao();
    } on TimeoutException {
      throw const SemConexao();
    } on http.ClientException {
      throw const SemConexao();
    }
  }
}

final LocalRepository localRepository = LocalRepositoryHttp(
  baseUrl: ApiConfig.baseUrl,
);

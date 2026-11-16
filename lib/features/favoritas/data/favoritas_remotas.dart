import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fe_nexa_app/app/config/api_config.dart';
import 'package:fe_nexa_app/features/auth/data/auth_repository.dart'
    show ErroInesperado, SemConexao;
import 'package:fe_nexa_app/features/auth/data/cliente_autenticado.dart';
import 'package:fe_nexa_app/features/auth/data/sessao_service.dart';
import 'package:fe_nexa_app/features/unidades/data/unidade_resumo.dart';
import 'package:http/http.dart' as http;

abstract interface class FavoritasRemotas {
  Future<List<UnidadeResumo>> listar({double? latitude, double? longitude});

  Future<void> definir(int id, {required bool favorita});

  Future<UnidadeResumo> unidadePorId(int id);
}

class FavoritasRemotasHttp implements FavoritasRemotas {
  FavoritasRemotasHttp({required this.baseUrl, required this._cliente});

  final String baseUrl;
  final http.Client _cliente;

  @override
  Future<List<UnidadeResumo>> listar({
    double? latitude,
    double? longitude,
  }) async {
    final posicao = latitude != null && longitude != null
        ? {'latitude': latitude.toString(), 'longitude': longitude.toString()}
        : null;
    final uri = Uri.parse(
      '$baseUrl/api/cidadaos/usuario/favoritas',
    ).replace(queryParameters: posicao);

    final resposta = await _enviar(() => _cliente.get(uri));
    if (resposta.statusCode != 200) throw const ErroInesperado();

    try {
      final lista =
          jsonDecode(utf8.decode(resposta.bodyBytes)) as List<dynamic>;
      return [
        for (final item in lista)
          UnidadeResumo.fromJson(item as Map<String, dynamic>),
      ];
    } on FormatException {
      throw const ErroInesperado();
    } on TypeError {
      throw const ErroInesperado();
    }
  }

  @override
  Future<void> definir(int id, {required bool favorita}) async {
    final base = '$baseUrl/api/cidadaos/usuario';
    final resposta = favorita
        ? await _enviar(
            () => _cliente.put(Uri.parse('$base/adicionarUnidade/$id')),
          )
        : await _enviar(
            () => _cliente.delete(Uri.parse('$base/removerUnidade/$id')),
          );

    final semEfeito = !favorita && resposta.statusCode == 404;
    if (resposta.statusCode != 200 && !semEfeito) throw const ErroInesperado();
  }

  @override
  Future<UnidadeResumo> unidadePorId(int id) async {
    final resposta = await _enviar(
      () => _cliente.get(Uri.parse('$baseUrl/api/unidades/$id')),
    );
    if (resposta.statusCode != 200) throw const ErroInesperado();

    try {
      return UnidadeResumo.fromJson(
        jsonDecode(utf8.decode(resposta.bodyBytes)) as Map<String, dynamic>,
      );
    } on FormatException {
      throw const ErroInesperado();
    } on TypeError {
      throw const ErroInesperado();
    }
  }

  Future<http.Response> _enviar(
    Future<http.Response> Function() chamada,
  ) async {
    try {
      return await chamada().timeout(const Duration(seconds: 10));
    } on SocketException {
      throw const SemConexao();
    } on TimeoutException {
      throw const SemConexao();
    } on http.ClientException {
      throw const SemConexao();
    }
  }
}

final FavoritasRemotas favoritasRemotas = FavoritasRemotasHttp(
  baseUrl: ApiConfig.baseUrl,
  cliente: ClienteAutenticado(sessoes: sessaoService),
);

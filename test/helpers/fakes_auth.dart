import 'dart:async';
import 'dart:convert';

import 'package:fe_nexa_app/features/auth/data/auth_repository.dart';
import 'package:fe_nexa_app/features/auth/data/sessao_repository.dart';

int _contadorDeTokens = 0;

/// Monta um JWT de mentira (sem assinatura de verdade) com as claims dadas.
/// `exp` é em segundos, como no JWT.
String tokenDeTeste({
  String? nome,
  String role = 'USUARIO',
  DateTime? expira,
}) {
  String parte(Map<String, Object?> mapa) =>
      base64Url.encode(utf8.encode(jsonEncode(mapa))).replaceAll('=', '');

  final validade = expira ?? DateTime.now().add(const Duration(minutes: 15));
  return [
    parte({'alg': 'HS256'}),
    parte({
      'sub': 'ana@exemplo.com',
      'nome': ?nome,
      'role': role,
      'jti': ++_contadorDeTokens,
      'exp': validade.millisecondsSinceEpoch ~/ 1000,
    }),
    'assinatura',
  ].join('.');
}

/// Uma sessão pronta para os testes. Por padrão: access token válido por 15
/// minutos e refresh token por 30 dias.
Sessao sessaoDeTeste({
  String email = 'ana@exemplo.com',
  String? nome = 'Ana Souza',
  DateTime? accessExpira,
  DateTime? refreshExpira,
  String refreshToken = 'refresh-1',
}) {
  return Sessao(
    email: email,
    accessToken: tokenDeTeste(nome: nome, expira: accessExpira),
    refreshToken: refreshToken,
    refreshExpiraEm:
        refreshExpira ?? DateTime.now().add(const Duration(days: 30)),
  );
}

/// O Spring de mentira: a renovação devolve tokens novos, ou lança [erro].
class AuthFalso implements AuthRepository {
  Object? erro;

  /// Se preenchido, [renovar] espera isto terminar (para simular demora).
  Future<void>? espera;

  int renovacoes = 0;
  int saidas = 0;

  @override
  Future<Sessao> entrar({required String email, required String senha}) =>
      throw UnimplementedError();

  @override
  Future<Sessao> registrar({
    required String nome,
    required String email,
    required String senha,
    required String confirmarSenha,
    required bool aceitouLocalizacao,
  }) => throw UnimplementedError();

  @override
  Future<Sessao> renovar(Sessao atual) async {
    renovacoes++;
    await espera;
    final falha = erro;
    if (falha != null) throw falha;
    return atual.comTokens(
      accessToken: tokenDeTeste(nome: atual.nome),
      refreshToken: 'refresh-${renovacoes + 1}',
      refreshExpiraEm: DateTime.now().add(const Duration(days: 30)),
    );
  }

  @override
  Future<void> sair(Sessao atual) async => saidas++;
}

class SessoesFalso implements SessaoRepository {
  SessoesFalso([this.guardada]);

  Sessao? guardada;
  int limpezas = 0;

  @override
  Future<Sessao?> carregar() async => guardada;

  @override
  Future<void> salvar(Sessao sessao) async => guardada = sessao;

  @override
  Future<void> limpar() async {
    limpezas++;
    guardada = null;
  }
}

import 'dart:convert';

import 'package:fe_nexa_app/features/auth/data/sessao.dart';
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

  final validade = expira ?? DateTime.now().add(const Duration(hours: 8));
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

/// Uma sessão pronta para os testes. Por padrão: token válido por 8 horas,
/// como o do Spring.
Sessao sessaoDeTeste({
  String email = 'ana@exemplo.com',
  String? nome = 'Ana Souza',
  DateTime? expira,
}) {
  return Sessao(
    email: email,
    accessToken: tokenDeTeste(nome: nome, expira: expira),
  );
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

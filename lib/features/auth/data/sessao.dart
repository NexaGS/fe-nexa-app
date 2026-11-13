import 'package:fe_nexa_app/features/auth/data/jwt.dart';

/// Quem está logado no app: dois tokens com papéis diferentes.
///
/// - [accessToken]: JWT de vida curta (minutos). É o que vai no cabeçalho
///   `Authorization` de cada chamada. Se vazar, vale pouco tempo.
/// - [refreshToken]: texto aleatório de vida longa (semanas). Só serve para
///   pedir ao Spring um novo par de tokens, e cada um vale uma vez só.

class Sessao {
  const Sessao({
    required this.email,
    required this.accessToken,
    required this.refreshToken,
    required this.refreshExpiraEm,
  });

  final String email;
  final String accessToken;
  final String refreshToken;

  /// Quando o refresh token deixa de valer. Depois disso só um novo login resolve.
  final DateTime refreshExpiraEm;

  String? get nome => dadosDoToken(accessToken)?['nome'] as String?;

  /// Quando o access token deixa de valer
  DateTime? get accessExpiraEm {
    final exp = dadosDoToken(accessToken)?['exp'];
    if (exp is! num) return null;
    return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
  }

  bool accessExpirou({
    DateTime? agora,
    Duration folga = const Duration(seconds: 30),
  }) {
    final validade = accessExpiraEm;
    if (validade == null) return true;
    return !validade.subtract(folga).isAfter(agora ?? DateTime.now());
  }

  /// `true` se o refresh token já venceu: não há mais como renovar sozinho.
  bool refreshExpirou([DateTime? agora]) =>
      !refreshExpiraEm.isAfter(agora ?? DateTime.now());

  Sessao comTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime refreshExpiraEm,
  }) {
    return Sessao(
      email: email,
      accessToken: accessToken,
      refreshToken: refreshToken,
      refreshExpiraEm: refreshExpiraEm,
    );
  }
}

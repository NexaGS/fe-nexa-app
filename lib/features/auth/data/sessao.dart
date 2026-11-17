import 'package:fe_nexa_app/features/auth/data/jwt.dart';

/// Quem está logado no app: o e-mail e o token JWT que o Spring entregou.
///
/// O [accessToken] vale 8 horas e vai no cabeçalho `Authorization` de cada
/// chamada. Não há refresh token: quando ele vence, só um novo login resolve.
class Sessao {
  const Sessao({required this.email, required this.accessToken});

  final String email;
  final String accessToken;

  String? get nome => dadosDoToken(accessToken)?['nome'] as String?;

  /// Quando o token deixa de valer (a claim `exp` do JWT). Nulo se o token não
  /// for legível.
  DateTime? get accessExpiraEm {
    final exp = dadosDoToken(accessToken)?['exp'];
    if (exp is! num) return null;
    return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
  }

  /// `true` se o token já venceu, ou vence nos próximos [folga] segundos (para
  /// não mandar uma chamada com um token que morre no meio do caminho). Token
  /// sem validade legível conta como vencido.
  bool accessExpirou({
    DateTime? agora,
    Duration folga = const Duration(seconds: 30),
  }) {
    final validade = accessExpiraEm;
    if (validade == null) return true;
    return !validade.subtract(folga).isAfter(agora ?? DateTime.now());
  }
}

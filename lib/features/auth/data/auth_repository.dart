import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fe_nexa_app/app/config/api_config.dart';
import 'package:fe_nexa_app/features/auth/data/jwt.dart';
import 'package:fe_nexa_app/features/auth/data/sessao.dart';
import 'package:http/http.dart' as http;

export 'package:fe_nexa_app/features/auth/data/sessao.dart';

/// Erros que as telas sabem explicar para a pessoa.
class CredenciaisInvalidas implements Exception {
  const CredenciaisInvalidas();
}

class EmailJaCadastrado implements Exception {
  const EmailJaCadastrado();
}

/// O e-mail e a senha estão certos, mas a conta é de colaborador, que entra
/// pelo sistema web e não pelo app.
class ContaDeColaborador implements Exception {
  const ContaDeColaborador();
}

/// O Spring recusou o refresh token (vencido, já usado, revogado ou conta
/// removida). Não há o que tentar de novo: a pessoa precisa entrar outra vez.
class SessaoRecusada implements Exception {
  const SessaoRecusada();
}

class SemConexao implements Exception {
  const SemConexao();
}

/// Qualquer outra resposta que o app não esperava (erro 500, por exemplo).
class ErroInesperado implements Exception {
  const ErroInesperado();
}

/// O contrato: o que as telas precisam, sem saber como a conversa com o
/// servidor acontece.
abstract interface class AuthRepository {
  Future<Sessao> entrar({required String email, required String senha});

  Future<Sessao> registrar({
    required String nome,
    required String email,
    required String senha,
    required String confirmarSenha,
    required bool aceitouLocalizacao,
  });

  /// Troca o refresh token de [atual] por uma sessão nova (access e refresh
  /// novos). Lança [SessaoRecusada] se o Spring recusar, [SemConexao] se não
  /// deu para falar com ele e [ErroInesperado] para qualquer outra resposta.
  Future<Sessao> renovar(Sessao atual);

  /// Avisa o Spring que esta sessão acabou, para ele revogar o refresh token.
  /// Falha em silêncio: sair do app nunca pode depender da internet.
  Future<void> sair(Sessao atual);
}

/// Conversa de verdade com o Spring.
class AuthRepositoryHttp implements AuthRepository {
  AuthRepositoryHttp({required this.baseUrl});

  final String baseUrl;

  @override
  Future<Sessao> entrar({required String email, required String senha}) async {
    final emailNormalizado = _normalizar(email);
    final resposta = await _postar('/api/auth/login', {
      'email': emailNormalizado,
      'senha': senha,
    });

    if (resposta.statusCode == 401) throw const CredenciaisInvalidas();
    if (resposta.statusCode != 200) throw const ErroInesperado();

    final sessao = _lerSessao(resposta, emailNormalizado);

    // O mesmo /login atende o sistema web (colaborador). O app é só do
    // cidadão, então a conta de colaborador não entra aqui.
    if (_papelDoToken(sessao.accessToken) == 'COLABORADOR') {
      throw const ContaDeColaborador();
    }
    return sessao;
  }

  @override
  Future<Sessao> registrar({
    required String nome,
    required String email,
    required String senha,
    required String confirmarSenha,
    required bool aceitouLocalizacao,
  }) async {
    final emailNormalizado = _normalizar(email);
    final resposta = await _postar('/api/auth/registro', {
      'nome': nome.trim(),
      'email': emailNormalizado,
      'senha': senha,
      'confirmarSenha': confirmarSenha,
      'aceitouLocalizacao': aceitouLocalizacao,
    });

    if (resposta.statusCode == 409) throw const EmailJaCadastrado();
    if (resposta.statusCode != 201) throw const ErroInesperado();

    return _lerSessao(resposta, emailNormalizado);
  }

  @override
  Future<Sessao> renovar(Sessao atual) async {
    final resposta = await _postar('/api/auth/refresh', {
      'refreshToken': atual.refreshToken,
    });

    if (resposta.statusCode == 401) throw const SessaoRecusada();
    if (resposta.statusCode != 200) throw const ErroInesperado();

    return _lerSessao(resposta, atual.email);
  }

  @override
  Future<void> sair(Sessao atual) async {
    try {
      await _postar('/api/auth/logout', {'refreshToken': atual.refreshToken});
    } catch (_) {
      // Sem internet o servidor continua com o refresh token até ele vencer;
      // o aparelho já o apagou, que é o que importa para esta pessoa.
    }
  }

  /// "  Ana@Exemplo.com " e "ana@exemplo.com" têm que ser a mesma conta.
  String _normalizar(String email) => email.trim().toLowerCase();

  /// Manda o JSON e traduz "não consegui falar com o servidor" em SemConexao.
  Future<http.Response> _postar(
    String caminho,
    Map<String, Object?> corpo,
  ) async {
    try {
      return await http
          .post(
            Uri.parse('$baseUrl$caminho'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(corpo),
          )
          .timeout(const Duration(seconds: 10));
    } on SocketException {
      throw const SemConexao();
    } on TimeoutException {
      throw const SemConexao();
    } on http.ClientException {
      throw const SemConexao();
    }
  }

  Sessao _lerSessao(http.Response resposta, String email) {
    try {
      final json =
      jsonDecode(utf8.decode(resposta.bodyBytes)) as Map<String, dynamic>;
      final segundos = (json['refreshExpiresInSeconds'] as num).toInt();
      return Sessao(
        email: email,
        accessToken: json['token'] as String,
        refreshToken: json['refreshToken'] as String,
        refreshExpiraEm: DateTime.now().add(Duration(seconds: segundos)),
      );
    } on FormatException {
      throw const ErroInesperado();
    } on TypeError {
      throw const ErroInesperado();
    }
  }

  String? _papelDoToken(String token) =>
      dadosDoToken(token)?['role'] as String?;
}

/// A instância que as telas usam. Para testar sem rede, troque aqui por uma
/// classe que também `implements AuthRepository`.
final AuthRepository authRepository = AuthRepositoryHttp(
  baseUrl: ApiConfig.baseUrl,
);

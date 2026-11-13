import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fe_nexa_app/app/config/api_config.dart';
import 'package:http/http.dart' as http;

/// Quem entrou no app. O [token] é a "chave" que o Spring devolve e que será
/// enviada nas próximas chamadas que exigirem login.
class Sessao {
  const Sessao({required this.email, required this.token, this.nome});

  final String email;
  final String token;
  final String? nome;
}

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
    if (_papelDoToken(sessao.token) == 'COLABORADOR') {
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
      final token = json['token'] as String;
      final nome = _dadosDoToken(token)?['nome'] as String?;
      return Sessao(email: email, token: token, nome: nome);
    } on FormatException {
      throw const ErroInesperado();
    } on TypeError {
      throw const ErroInesperado();
    }
  }

  /// O token JWT tem 3 partes separadas por ponto: cabeçalho.dados.assinatura.
  /// A parte do meio é um JSON em base64 com o "role" e o "nome". Aqui só
  /// LEMOS esses dados, para escolher a tela e dar boas-vindas. Quem confere
  /// a assinatura e dá permissão de verdade é o Spring.
  Map<String, dynamic>? _dadosDoToken(String token) {
    try {
      final partes = token.split('.');
      if (partes.length != 3) return null;
      // "normalize" completa os "=" do final que o base64 do JWT dispensa.
      final miolo = base64Url.normalize(partes[1]);
      final dados = utf8.decode(base64Url.decode(miolo));
      return jsonDecode(dados) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  String? _papelDoToken(String token) =>
      _dadosDoToken(token)?['role'] as String?;
}

/// A instância que as telas usam. Para testar sem rede, troque aqui por uma
/// classe que também `implements AuthRepository`.
final AuthRepository authRepository = AuthRepositoryHttp(
  baseUrl: ApiConfig.baseUrl,
);

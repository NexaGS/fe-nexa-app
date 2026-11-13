import 'package:fe_nexa_app/features/auth/data/sessao_service.dart';
import 'package:http/http.dart' as http;

/// Um cliente HTTP que cuida do login sozinho: quem o usa só faz `get` e
/// `post`, sem se preocupar com token.
///
/// Em cada chamada ele:
/// 1. pede ao [SessaoService] um access token válido (renovando se preciso) e
///    o coloca em `Authorization: Bearer ...`;
/// 2. se o Spring responder 401 mesmo assim (token revogado ou relógio
///    desencontrado), renova uma vez e repete a chamada;
/// 3. se ainda assim for 401, devolve o 401: a sessão já foi encerrada pelo
///    [SessaoService] e a casca do app leva a pessoa ao Início.
///
/// Só aceita requisições simples ([http.Request]: `get`, `post` com corpo em
/// texto), que podem ser repetidas. Upload em partes não passa por aqui.
class ClienteAutenticado extends http.BaseClient {
  ClienteAutenticado({required SessaoService sessoes, http.Client? interno})
    : _sessoes = sessoes,
      _interno = interno ?? http.Client();

  final SessaoService _sessoes;
  final http.Client _interno;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request is! http.Request) {
      throw ArgumentError('ClienteAutenticado só envia http.Request.');
    }

    final token = await _sessoes.tokenDeAcesso();
    final resposta = await _interno.send(_comToken(request, token));
    if (resposta.statusCode != 401 || token == null) return resposta;

    final novoToken = await _sessoes.renovar();
    if (novoToken == null) return resposta;

    // A primeira resposta não será usada: esvazia para liberar a conexão.
    await resposta.stream.drain<void>();
    return _interno.send(_comToken(request, novoToken));
  }

  /// Uma requisição só pode ser enviada uma vez, então cada tentativa usa uma
  /// cópia, com o token da vez.
  http.Request _comToken(http.Request original, String? token) {
    final copia = http.Request(original.method, original.url)
      ..headers.addAll(original.headers)
      ..bodyBytes = original.bodyBytes
      ..followRedirects = original.followRedirects
      ..maxRedirects = original.maxRedirects
      ..persistentConnection = original.persistentConnection;
    if (token != null) copia.headers['Authorization'] = 'Bearer $token';
    return copia;
  }

  @override
  void close() => _interno.close();
}

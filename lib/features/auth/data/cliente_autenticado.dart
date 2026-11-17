import 'package:fe_nexa_app/features/auth/data/sessao_service.dart';
import 'package:http/http.dart' as http;

/// Um cliente HTTP que cuida do login sozinho: quem o usa só faz `get` e
/// `post`, sem se preocupar com token.
///
/// Em cada chamada ele:
/// 1. pede ao [SessaoService] o token da sessão e o coloca em
///    `Authorization: Bearer ...` (sem sessão, a chamada vai sem cabeçalho);
/// 2. se o Spring responder 401 para uma chamada que levou token, avisa o
///    [SessaoService] que a sessão acabou (a casca do app leva a pessoa ao
///    Início) e devolve o 401. Não há refresh token, então não há o que
///    renovar nem repetir.
class ClienteAutenticado extends http.BaseClient {
  ClienteAutenticado({required this._sessoes, http.Client? interno})
    : _interno = interno ?? http.Client();

  final SessaoService _sessoes;
  final http.Client _interno;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = await _sessoes.tokenDeAcesso();
    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    final resposta = await _interno.send(request);
    if (resposta.statusCode == 401 && token != null) {
      await _sessoes.expirou(token);
    }
    return resposta;
  }

  @override
  void close() => _interno.close();
}

import 'package:fe_nexa_app/features/auth/data/auth_repository.dart';
import 'package:fe_nexa_app/features/auth/data/cliente_autenticado.dart';
import 'package:fe_nexa_app/features/auth/data/sessao_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../../helpers/fakes_auth.dart';

Future<SessaoService> servicoLogado(AuthFalso auth) async {
  final servico = SessaoService(
    auth: auth,
    armazenamento: SessoesFalso(sessaoDeTeste()),
  );
  await servico.iniciar();
  return servico;
}

void main() {
  final url = Uri.parse('https://api.teste/api/favoritas');

  test('coloca o access token no cabeçalho Authorization', () async {
    final auth = AuthFalso();
    final servico = await servicoLogado(auth);
    String? recebido;
    final cliente = ClienteAutenticado(
      sessoes: servico,
      interno: MockClient((req) async {
        recebido = req.headers['Authorization'];
        return http.Response('ok', 200);
      }),
    );

    final resposta = await cliente.get(url);

    expect(resposta.statusCode, 200);
    expect(recebido, 'Bearer ${servico.atual.value!.accessToken}');
  });

  test('sem sessão, manda a chamada sem Authorization', () async {
    final servico = SessaoService(auth: AuthFalso(), armazenamento: SessoesFalso());
    bool? temCabecalho;
    final cliente = ClienteAutenticado(
      sessoes: servico,
      interno: MockClient((req) async {
        temCabecalho = req.headers.containsKey('Authorization');
        return http.Response('ok', 200);
      }),
    );

    await cliente.get(url);

    expect(temCabecalho, isFalse);
  });

  test('401: renova uma vez e repete a chamada com o token novo', () async {
    final auth = AuthFalso();
    final servico = await servicoLogado(auth);
    final tokensUsados = <String?>[];
    final cliente = ClienteAutenticado(
      sessoes: servico,
      interno: MockClient((req) async {
        tokensUsados.add(req.headers['Authorization']);
        return http.Response('', tokensUsados.length == 1 ? 401 : 200);
      }),
    );

    final resposta = await cliente.post(url, body: 'corpo');

    expect(resposta.statusCode, 200);
    expect(auth.renovacoes, 1);
    expect(tokensUsados, hasLength(2));
    expect(tokensUsados[0], isNot(tokensUsados[1]));
    expect(tokensUsados[1], 'Bearer ${servico.atual.value!.accessToken}');
  });

  test('401 e o servidor recusa a renovação: devolve o 401 e a sessão acaba', () async {
    final auth = AuthFalso()..erro = const SessaoRecusada();
    final servico = await servicoLogado(auth);
    var chamadas = 0;
    final cliente = ClienteAutenticado(
      sessoes: servico,
      interno: MockClient((req) async {
        chamadas++;
        return http.Response('', 401);
      }),
    );

    final resposta = await cliente.get(url);

    expect(resposta.statusCode, 401);
    expect(chamadas, 1);
    expect(servico.atual.value, isNull);
  });
}

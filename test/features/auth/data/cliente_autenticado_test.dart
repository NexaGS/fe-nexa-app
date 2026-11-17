import 'package:fe_nexa_app/features/auth/data/cliente_autenticado.dart';
import 'package:fe_nexa_app/features/auth/data/sessao_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../../helpers/fakes_auth.dart';

Future<SessaoService> servicoLogado({DateTime? expira}) async {
  final servico = SessaoService(
    armazenamento: SessoesFalso(sessaoDeTeste(expira: expira)),
  );
  await servico.iniciar();
  return servico;
}

void main() {
  final url = Uri.parse('https://api.teste/api/favoritas');

  test('coloca o token no cabeçalho Authorization', () async {
    final servico = await servicoLogado();
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
    final servico = SessaoService(armazenamento: SessoesFalso());
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

  test('401: devolve o 401 sem repetir a chamada e a sessão acaba', () async {
    final servico = await servicoLogado();
    var avisos = 0;
    servico.expiradas.listen((_) => avisos++);
    var chamadas = 0;
    final cliente = ClienteAutenticado(
      sessoes: servico,
      interno: MockClient((req) async {
        chamadas++;
        return http.Response('', 401);
      }),
    );

    final resposta = await cliente.post(url, body: 'corpo');
    await Future<void>.delayed(Duration.zero);

    expect(resposta.statusCode, 401);
    expect(chamadas, 1);
    expect(servico.atual.value, isNull);
    expect(avisos, 1);
  });

  test('401 sem sessão (visitante): só devolve o 401', () async {
    final servico = SessaoService(armazenamento: SessoesFalso());
    var avisos = 0;
    servico.expiradas.listen((_) => avisos++);
    final cliente = ClienteAutenticado(
      sessoes: servico,
      interno: MockClient((req) async => http.Response('', 401)),
    );

    final resposta = await cliente.get(url);
    await Future<void>.delayed(Duration.zero);

    expect(resposta.statusCode, 401);
    expect(avisos, 0);
  });

  test('token vencido: a sessão acaba e a chamada vai sem Authorization', () async {
    final servico = await servicoLogado(
      expira: DateTime.now().subtract(const Duration(minutes: 5)),
    );
    var avisos = 0;
    servico.expiradas.listen((_) => avisos++);
    bool? temCabecalho;
    final cliente = ClienteAutenticado(
      sessoes: servico,
      interno: MockClient((req) async {
        temCabecalho = req.headers.containsKey('Authorization');
        return http.Response('', 401);
      }),
    );

    await cliente.get(url);
    await Future<void>.delayed(Duration.zero);

    expect(temCabecalho, isFalse);
    expect(servico.atual.value, isNull);
    expect(avisos, 1);
  });
}

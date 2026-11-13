import 'dart:async';

import 'package:fe_nexa_app/features/auth/data/auth_repository.dart';
import 'package:fe_nexa_app/features/auth/data/sessao_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes_auth.dart';

SessaoService criar(AuthFalso auth, SessoesFalso armazenamento) =>
    SessaoService(auth: auth, armazenamento: armazenamento);

void main() {
  late AuthFalso auth;

  setUp(() => auth = AuthFalso());

  test('iniciar carrega a sessão guardada, sem ir à rede', () async {
    final servico = criar(auth, SessoesFalso(sessaoDeTeste()));

    await servico.iniciar();

    expect(servico.atual.value?.email, 'ana@exemplo.com');
    expect(auth.renovacoes, 0);
  });

  test('entrou guarda a sessão e a torna a atual', () async {
    final armazenamento = SessoesFalso();
    final servico = criar(auth, armazenamento);
    final sessao = sessaoDeTeste();

    await servico.entrou(sessao);

    expect(servico.atual.value, same(sessao));
    expect(armazenamento.guardada, same(sessao));
  });

  group('tokenDeAcesso', () {
    test('sem sessão, devolve nulo', () async {
      expect(await criar(auth, SessoesFalso()).tokenDeAcesso(), isNull);
    });

    test('access token válido: devolve sem renovar', () async {
      final sessao = sessaoDeTeste();
      final servico = criar(auth, SessoesFalso(sessao));
      await servico.iniciar();

      expect(await servico.tokenDeAcesso(), sessao.accessToken);
      expect(auth.renovacoes, 0);
    });

    test('access token vencido: renova, guarda o novo par e devolve o novo token', () async {
      final armazenamento = SessoesFalso(
        sessaoDeTeste(accessExpira: DateTime.now().subtract(const Duration(minutes: 5))),
      );
      final servico = criar(auth, armazenamento);
      await servico.iniciar();

      final token = await servico.tokenDeAcesso();

      expect(auth.renovacoes, 1);
      expect(token, servico.atual.value!.accessToken);
      expect(armazenamento.guardada!.refreshToken, 'refresh-2');
    });
  });

  group('renovar', () {
    test('três pedidos ao mesmo tempo viram uma só ida ao servidor', () async {
      final liberar = Completer<void>();
      auth.espera = liberar.future;
      final servico = criar(auth, SessoesFalso(sessaoDeTeste()));
      await servico.iniciar();

      final pedidos = [servico.renovar(), servico.renovar(), servico.renovar()];
      liberar.complete();
      final tokens = await Future.wait(pedidos);

      expect(auth.renovacoes, 1);
      expect(tokens.toSet(), hasLength(1));
    });

    test('servidor recusou: encerra a sessão, apaga e avisa a casca do app', () async {
      auth.erro = const SessaoRecusada();
      final armazenamento = SessoesFalso(sessaoDeTeste());
      final servico = criar(auth, armazenamento);
      await servico.iniciar();
      var avisos = 0;
      servico.encerradasPeloServidor.listen((_) => avisos++);

      final token = await servico.renovar();
      await Future<void>.delayed(Duration.zero);

      expect(token, isNull);
      expect(servico.atual.value, isNull);
      expect(armazenamento.guardada, isNull);
      expect(avisos, 1);
    });

    test('sem internet: mantém a sessão e repassa o erro', () async {
      auth.erro = const SemConexao();
      final armazenamento = SessoesFalso(sessaoDeTeste());
      final servico = criar(auth, armazenamento);
      await servico.iniciar();

      await expectLater(servico.renovar(), throwsA(isA<SemConexao>()));

      expect(servico.atual.value, isNotNull);
      expect(armazenamento.guardada, isNotNull);
    });

    test('depois de falhar, a próxima tentativa vai ao servidor de novo', () async {
      auth.erro = const SemConexao();
      final servico = criar(auth, SessoesFalso(sessaoDeTeste()));
      await servico.iniciar();
      await expectLater(servico.renovar(), throwsA(isA<SemConexao>()));

      auth.erro = null;
      await servico.renovar();

      expect(auth.renovacoes, 2);
    });
  });

  group('sair', () {
    test('apaga a sessão, avisa o servidor e NÃO dispara a saída forçada', () async {
      final armazenamento = SessoesFalso(sessaoDeTeste());
      final servico = criar(auth, armazenamento);
      await servico.iniciar();
      var avisos = 0;
      servico.encerradasPeloServidor.listen((_) => avisos++);

      await servico.sair();
      await Future<void>.delayed(Duration.zero);

      expect(servico.atual.value, isNull);
      expect(armazenamento.guardada, isNull);
      expect(auth.saidas, 1);
      expect(avisos, 0);
    });

    test('sem sessão, não faz nada além de limpar', () async {
      await criar(auth, SessoesFalso()).sair();

      expect(auth.saidas, 0);
    });
  });
}

import 'package:fe_nexa_app/features/auth/data/sessao_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes_auth.dart';

SessaoService criar(SessoesFalso armazenamento) =>
    SessaoService(armazenamento: armazenamento);

void main() {
  test('iniciar carrega a sessão guardada', () async {
    final servico = criar(SessoesFalso(sessaoDeTeste()));

    await servico.iniciar();

    expect(servico.atual.value?.email, 'ana@exemplo.com');
  });

  test('entrou guarda a sessão e a torna a atual', () async {
    final armazenamento = SessoesFalso();
    final servico = criar(armazenamento);
    final sessao = sessaoDeTeste();

    await servico.entrou(sessao);

    expect(servico.atual.value, same(sessao));
    expect(armazenamento.guardada, same(sessao));
  });

  group('tokenDeAcesso', () {
    test('sem sessão, devolve nulo', () async {
      expect(await criar(SessoesFalso()).tokenDeAcesso(), isNull);
    });

    test('token válido: devolve o token da sessão', () async {
      final sessao = sessaoDeTeste();
      final servico = criar(SessoesFalso(sessao));
      await servico.iniciar();

      expect(await servico.tokenDeAcesso(), sessao.accessToken);
      expect(servico.atual.value, isNotNull);
    });

    test('token vencido: devolve nulo, apaga a sessão e avisa uma vez', () async {
      final armazenamento = SessoesFalso(
        sessaoDeTeste(expira: DateTime.now().subtract(const Duration(minutes: 5))),
      );
      final servico = criar(armazenamento);
      await servico.iniciar();
      var avisos = 0;
      servico.expiradas.listen((_) => avisos++);

      final token = await servico.tokenDeAcesso();
      await Future<void>.delayed(Duration.zero);

      expect(token, isNull);
      expect(servico.atual.value, isNull);
      expect(armazenamento.guardada, isNull);
      expect(avisos, 1);
    });
  });

  group('expirou', () {
    test('token da sessão atual: apaga, e avisa a casca do app', () async {
      final sessao = sessaoDeTeste();
      final armazenamento = SessoesFalso(sessao);
      final servico = criar(armazenamento);
      await servico.iniciar();
      var avisos = 0;
      servico.expiradas.listen((_) => avisos++);

      await servico.expirou(sessao.accessToken);
      await Future<void>.delayed(Duration.zero);

      expect(servico.atual.value, isNull);
      expect(armazenamento.guardada, isNull);
      expect(avisos, 1);
    });

    test('token de uma sessão antiga: a sessão nova continua', () async {
      final antiga = sessaoDeTeste();
      final servico = criar(SessoesFalso());
      await servico.entrou(antiga);
      final nova = sessaoDeTeste();
      await servico.entrou(nova);
      var avisos = 0;
      servico.expiradas.listen((_) => avisos++);

      await servico.expirou(antiga.accessToken);
      await Future<void>.delayed(Duration.zero);

      expect(servico.atual.value, same(nova));
      expect(avisos, 0);
    });

    test('várias respostas 401 ao mesmo tempo avisam uma vez só', () async {
      final sessao = sessaoDeTeste();
      final servico = criar(SessoesFalso(sessao));
      await servico.iniciar();
      var avisos = 0;
      servico.expiradas.listen((_) => avisos++);

      await Future.wait([
        servico.expirou(sessao.accessToken),
        servico.expirou(sessao.accessToken),
        servico.expirou(sessao.accessToken),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(avisos, 1);
    });
  });

  group('sair', () {
    test('apaga a sessão e NÃO dispara a saída forçada', () async {
      final armazenamento = SessoesFalso(sessaoDeTeste());
      final servico = criar(armazenamento);
      await servico.iniciar();
      var avisos = 0;
      servico.expiradas.listen((_) => avisos++);

      await servico.sair();
      await Future<void>.delayed(Duration.zero);

      expect(servico.atual.value, isNull);
      expect(armazenamento.guardada, isNull);
      expect(avisos, 0);
    });

    test('sem sessão, não faz nada além de limpar', () async {
      final armazenamento = SessoesFalso();

      await criar(armazenamento).sair();

      expect(armazenamento.limpezas, 1);
    });
  });
}

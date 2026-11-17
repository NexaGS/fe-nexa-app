import 'package:fe_nexa_app/features/auth/data/sessao.dart';
import 'package:fe_nexa_app/features/auth/data/sessao_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes_auth.dart';

void main() {
  final agora = DateTime(2026, 11, 12, 12);

  group('Sessao', () {
    test('o nome vem da claim "nome" do token', () {
      expect(sessaoDeTeste(nome: 'Ana Souza').nome, 'Ana Souza');
    });

    test('token sem nome ou ilegível deixa o nome nulo', () {
      expect(sessaoDeTeste(nome: null).nome, isNull);
      expect(const Sessao(email: 'a@b.com', accessToken: 'lixo').nome, isNull);
    });

    test('accessExpirou: considera a folga de 30 segundos', () {
      final venceEm20s = sessaoDeTeste(
        expira: agora.add(const Duration(seconds: 20)),
      );
      final venceEm5min = sessaoDeTeste(
        expira: agora.add(const Duration(minutes: 5)),
      );
      final jaVenceu = sessaoDeTeste(
        expira: agora.subtract(const Duration(minutes: 1)),
      );

      expect(venceEm20s.accessExpirou(agora: agora), isTrue);
      expect(venceEm5min.accessExpirou(agora: agora), isFalse);
      expect(jaVenceu.accessExpirou(agora: agora), isTrue);
    });

    test('token sem validade legível conta como vencido', () {
      const ilegivel = Sessao(email: 'a@b.com', accessToken: 'lixo');
      expect(ilegivel.accessExpirou(), isTrue);
    });
  });

  group('SessaoRepositorySegura', () {
    setUp(() => FlutterSecureStorage.setMockInitialValues({}));

    test('sem nada guardado, não há sessão', () async {
      expect(await SessaoRepositorySegura().carregar(), isNull);
    });

    test('guarda e devolve a sessão', () async {
      final original = sessaoDeTeste(expira: agora.add(const Duration(hours: 8)));
      await SessaoRepositorySegura().salvar(original);

      final lida = await SessaoRepositorySegura(agora: () => agora).carregar();

      expect(lida, isNotNull);
      expect(lida!.email, original.email);
      expect(lida.accessToken, original.accessToken);
      expect(lida.nome, 'Ana Souza');
    });

    test('token vencido: não devolve e apaga do aparelho', () async {
      final repo = SessaoRepositorySegura(agora: () => agora);
      await repo.salvar(
        sessaoDeTeste(expira: agora.subtract(const Duration(hours: 1))),
      );

      expect(await repo.carregar(), isNull);
      // Já foi apagado: mesmo com a hora voltando, não há o que carregar.
      expect(
        await SessaoRepositorySegura(
          agora: () => agora.subtract(const Duration(days: 9)),
        ).carregar(),
        isNull,
      );
    });

    test('limpar apaga a sessão (Sair)', () async {
      final repo = SessaoRepositorySegura();
      await repo.salvar(sessaoDeTeste());

      await repo.limpar();

      expect(await repo.carregar(), isNull);
    });

    test('limpar também apaga o refresh token da versão antiga', () async {
      FlutterSecureStorage.setMockInitialValues({
        'sessao_refresh_token': 'velho',
        'sessao_refresh_expira_em': '2026-12-12T12:00:00.000',
      });

      await SessaoRepositorySegura().limpar();

      expect(await const FlutterSecureStorage().readAll(), isEmpty);
    });
  });
}

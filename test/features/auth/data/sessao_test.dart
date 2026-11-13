import 'package:fe_nexa_app/features/auth/data/sessao_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes_auth.dart';

void main() {
  final agora = DateTime(2026, 11, 12, 12);

  group('Sessao', () {
    test('o nome vem da claim "nome" do access token', () {
      expect(sessaoDeTeste(nome: 'Ana Souza').nome, 'Ana Souza');
    });

    test('token sem nome ou ilegível deixa o nome nulo', () {
      expect(sessaoDeTeste(nome: null).nome, isNull);
      expect(
        sessaoDeTeste().comTokens(
          accessToken: 'lixo',
          refreshToken: 'r',
          refreshExpiraEm: agora,
        ).nome,
        isNull,
      );
    });

    test('accessExpirou: considera a folga de 30 segundos', () {
      final venceEm20s = sessaoDeTeste(
        accessExpira: agora.add(const Duration(seconds: 20)),
      );
      final venceEm5min = sessaoDeTeste(
        accessExpira: agora.add(const Duration(minutes: 5)),
      );
      final jaVenceu = sessaoDeTeste(
        accessExpira: agora.subtract(const Duration(minutes: 1)),
      );

      expect(venceEm20s.accessExpirou(agora: agora), isTrue);
      expect(venceEm5min.accessExpirou(agora: agora), isFalse);
      expect(jaVenceu.accessExpirou(agora: agora), isTrue);
    });

    test('access token sem validade legível conta como vencido', () {
      final ilegivel = sessaoDeTeste().comTokens(
        accessToken: 'lixo',
        refreshToken: 'r',
        refreshExpiraEm: agora,
      );
      expect(ilegivel.accessExpirou(), isTrue);
    });

    test('refreshExpirou compara com a data do refresh token', () {
      final valido = sessaoDeTeste(refreshExpira: agora.add(const Duration(days: 1)));
      final vencido = sessaoDeTeste(refreshExpira: agora.subtract(const Duration(days: 1)));
      expect(valido.refreshExpirou(agora), isFalse);
      expect(vencido.refreshExpirou(agora), isTrue);
    });

    test('comTokens troca os tokens e mantém a pessoa', () {
      final nova = sessaoDeTeste().comTokens(
        accessToken: tokenDeTeste(nome: 'Ana Souza'),
        refreshToken: 'refresh-9',
        refreshExpiraEm: agora,
      );
      expect(nova.email, 'ana@exemplo.com');
      expect(nova.refreshToken, 'refresh-9');
    });
  });

  group('SessaoRepositorySegura', () {
    setUp(() => FlutterSecureStorage.setMockInitialValues({}));

    test('sem nada guardado, não há sessão', () async {
      expect(await SessaoRepositorySegura().carregar(), isNull);
    });

    test('guarda e devolve todos os campos da sessão', () async {
      final original = sessaoDeTeste(refreshExpira: agora.add(const Duration(days: 30)));
      await SessaoRepositorySegura().salvar(original);

      final lida = await SessaoRepositorySegura(agora: () => agora).carregar();

      expect(lida, isNotNull);
      expect(lida!.email, original.email);
      expect(lida.accessToken, original.accessToken);
      expect(lida.refreshToken, original.refreshToken);
      expect(lida.refreshExpiraEm, original.refreshExpiraEm);
      expect(lida.nome, 'Ana Souza');
    });

    test('access token vencido não descarta a sessão (o refresh cuida disso)', () async {
      final sessao = sessaoDeTeste(
        accessExpira: agora.subtract(const Duration(hours: 2)),
        refreshExpira: agora.add(const Duration(days: 29)),
      );
      await SessaoRepositorySegura().salvar(sessao);

      expect(await SessaoRepositorySegura(agora: () => agora).carregar(), isNotNull);
    });

    test('refresh token vencido: não devolve e apaga do aparelho', () async {
      final repo = SessaoRepositorySegura(agora: () => agora);
      await repo.salvar(
        sessaoDeTeste(refreshExpira: agora.subtract(const Duration(days: 1))),
      );

      expect(await repo.carregar(), isNull);
      // Já foi apagado: mesmo com a hora voltando, não há o que carregar.
      expect(
        await SessaoRepositorySegura(agora: () => agora.subtract(const Duration(days: 9))).carregar(),
        isNull,
      );
    });

    test('limpar apaga a sessão (Sair)', () async {
      final repo = SessaoRepositorySegura();
      await repo.salvar(sessaoDeTeste());

      await repo.limpar();

      expect(await repo.carregar(), isNull);
    });
  });
}

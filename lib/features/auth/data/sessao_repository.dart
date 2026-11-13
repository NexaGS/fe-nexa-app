import 'package:fe_nexa_app/features/auth/data/sessao.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// O contrato do armazenamento: guardar e recuperar a sessão no aparelho, sem
/// quem usa saber onde ela fica. Só guarda; quem decide renovar ou encerrar é
/// o `SessaoService`.
abstract interface class SessaoRepository {
  /// A sessão guardada, ou `null` se não há ninguém logado ou se o refresh
  /// token já venceu (nesse caso ele é apagado aqui mesmo).
  ///
  /// O access token vencido NÃO descarta a sessão: é para isso que existe o
  /// refresh token.
  Future<Sessao?> carregar();

  /// Guarda a sessão, trocando a anterior. Chamado no login e a cada renovação.
  Future<void> salvar(Sessao sessao);

  /// Apaga tudo ("Sair" ou sessão recusada pelo servidor).
  Future<void> limpar();
}

/// Guarda os tokens no cofre do aparelho (Keystore no Android, Keychain no
/// iOS). Eles são "chaves" de acesso à conta, por isso não vão para as
/// `SharedPreferences`, que são texto aberto.
class SessaoRepositorySegura implements SessaoRepository {
  SessaoRepositorySegura({
    FlutterSecureStorage? cofre,
    DateTime Function()? agora,
  }) : _cofre = cofre ?? const FlutterSecureStorage(),
       _agora = agora ?? DateTime.now;

  static const _chaveAccess = 'sessao_access_token';
  static const _chaveRefresh = 'sessao_refresh_token';
  static const _chaveRefreshExpira = 'sessao_refresh_expira_em';
  static const _chaveEmail = 'sessao_email';

  final FlutterSecureStorage _cofre;
  final DateTime Function() _agora;

  @override
  Future<Sessao?> carregar() async {
    try {
      final access = await _cofre.read(key: _chaveAccess);
      final refresh = await _cofre.read(key: _chaveRefresh);
      final expira = await _cofre.read(key: _chaveRefreshExpira);
      final email = await _cofre.read(key: _chaveEmail);
      if (access == null || refresh == null || expira == null || email == null) {
        return null;
      }

      final validade = DateTime.tryParse(expira);
      if (validade == null) {
        await limpar();
        return null;
      }

      final sessao = Sessao(
        email: email,
        accessToken: access,
        refreshToken: refresh,
        refreshExpiraEm: validade,
      );
      if (sessao.refreshExpirou(_agora())) {
        await limpar();
        return null;
      }
      return sessao;
    } catch (_) {
      // Cofre ilegível (aparelho restaurado, chave perdida): entra de novo.
      return null;
    }
  }

  @override
  Future<void> salvar(Sessao sessao) async {
    await _cofre.write(key: _chaveAccess, value: sessao.accessToken);
    await _cofre.write(key: _chaveRefresh, value: sessao.refreshToken);
    await _cofre.write(
      key: _chaveRefreshExpira,
      value: sessao.refreshExpiraEm.toIso8601String(),
    );
    await _cofre.write(key: _chaveEmail, value: sessao.email);
  }

  @override
  Future<void> limpar() async {
    try {
      await _cofre.delete(key: _chaveAccess);
      await _cofre.delete(key: _chaveRefresh);
      await _cofre.delete(key: _chaveRefreshExpira);
      await _cofre.delete(key: _chaveEmail);
    } catch (_) {
      // Sem conseguir apagar, o app ainda sai da conta na tela; na próxima
      // abertura o refresh token vencido ou recusado é descartado de novo.
    }
  }
}

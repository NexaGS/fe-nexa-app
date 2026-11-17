import 'package:fe_nexa_app/features/auth/data/sessao.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// O contrato do armazenamento: guardar e recuperar a sessão no aparelho, sem
/// quem usa saber onde ela fica. Só guarda; quem decide quando a sessão acaba
/// é o `SessaoService`.
abstract interface class SessaoRepository {
  /// A sessão guardada, ou `null` se não há ninguém logado ou se o token já
  /// venceu (nesse caso ele é apagado aqui mesmo).
  Future<Sessao?> carregar();

  /// Guarda a sessão, trocando a anterior. Chamado no login e no cadastro.
  Future<void> salvar(Sessao sessao);

  /// Apaga tudo ("Sair" ou sessão que acabou).
  Future<void> limpar();
}

/// Guarda o token no cofre do aparelho (Keystore no Android, Keychain no iOS).
/// Ele é uma "chave" de acesso à conta, por isso não vai para as
/// `SharedPreferences`, que são texto aberto.
class SessaoRepositorySegura implements SessaoRepository {
  SessaoRepositorySegura({
    FlutterSecureStorage? cofre,
    DateTime Function()? agora,
  }) : _cofre = cofre ?? const FlutterSecureStorage(),
       _agora = agora ?? DateTime.now;

  static const _chaveAccess = 'sessao_access_token';
  static const _chaveEmail = 'sessao_email';

  /// Chaves que a versão com refresh token guardava. Já não são usadas; só
  /// apagamos, para não deixar um token antigo parado no aparelho.
  static const _chavesAntigas = [
    'sessao_refresh_token',
    'sessao_refresh_expira_em',
  ];

  final FlutterSecureStorage _cofre;
  final DateTime Function() _agora;

  @override
  Future<Sessao?> carregar() async {
    try {
      final access = await _cofre.read(key: _chaveAccess);
      final email = await _cofre.read(key: _chaveEmail);
      if (access == null || email == null) return null;

      final sessao = Sessao(email: email, accessToken: access);
      if (sessao.accessExpirou(agora: _agora())) {
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
    await _cofre.write(key: _chaveEmail, value: sessao.email);
  }

  @override
  Future<void> limpar() async {
    try {
      await _cofre.delete(key: _chaveAccess);
      await _cofre.delete(key: _chaveEmail);
      for (final chave in _chavesAntigas) {
        await _cofre.delete(key: chave);
      }
    } catch (_) {
      // Sem conseguir apagar, o app ainda sai da conta na tela; na próxima
      // abertura o token vencido é descartado de novo.
    }
  }
}

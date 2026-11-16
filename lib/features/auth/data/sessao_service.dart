import 'dart:async';

import 'package:fe_nexa_app/features/auth/data/auth_repository.dart';
import 'package:fe_nexa_app/features/auth/data/sessao_repository.dart';
import 'package:flutter/foundation.dart';

/// O "gerente" da sessão: o único lugar que sabe quem está logado e que
/// decide quando renovar os tokens ou encerrar a sessão.
class SessaoService {
  SessaoService({
    required this._auth,
    required this._armazenamento,
    DateTime Function()? agora,
  }) : _agora = agora ?? DateTime.now;

  final AuthRepository _auth;
  final SessaoRepository _armazenamento;
  final DateTime Function() _agora;

  final ValueNotifier<Sessao?> _atual = ValueNotifier(null);
  final StreamController<void> _encerradas = StreamController<void>.broadcast();

  /// Renovação em andamento.
  Future<String?>? _renovacaoEmAndamento;

  ValueListenable<Sessao?> get atual => _atual;

  /// Avisa quando o SERVIDOR encerrou a sessão (refresh recusado).
  Stream<void> get encerradasPeloServidor => _encerradas.stream;

  /// Lê a sessão guardada no aparelho. Chame uma vez, antes de desenhar a
  /// primeira tela. Não vai à rede: abrir o app offline continua logado.
  Future<void> iniciar() async {
    _atual.value = await _armazenamento.carregar();
  }

  /// Registra o resultado de um login ou cadastro
  Future<void> entrou(Sessao sessao) async {
    _atual.value = sessao;
    try {
      await _armazenamento.salvar(sessao);
    } catch (_) {}
  }

  /// O access token para usar numa chamada agora, renovando antes se ele
  /// venceu. `null` se não há sessão (ou se o servidor a recusou na renovação).
  Future<String?> tokenDeAcesso() async {
    final sessao = _atual.value;
    if (sessao == null) return null;
    if (!sessao.accessExpirou(agora: _agora())) return sessao.accessToken;
    return renovar();
  }

  /// Troca o par de tokens pelo refresh token.
  Future<String?> renovar() {
    return _renovacaoEmAndamento ??= _renovar().whenComplete(
      () => _renovacaoEmAndamento = null,
    );
  }

  Future<String?> _renovar() async {
    final sessao = _atual.value;
    if (sessao == null) return null;

    try {
      final nova = await _auth.renovar(sessao);
      // Guarda ANTES de usar: o refresh antigo já não vale no servidor, então
      // perder o novo agora seria perder a sessão.
      _atual.value = nova;
      await _armazenamento.salvar(nova);
      return nova.accessToken;
    } on SessaoRecusada {
      await _encerrarNoAparelho();
      _encerradas.add(null);
      return null;
    }
  }

  /// "Sair": avisa o servidor (para revogar o refresh token) e apaga a sessão
  /// do aparelho.
  Future<void> sair() async {
    final sessao = _atual.value;
    await _encerrarNoAparelho();
    if (sessao != null) {
      unawaited(_auth.sair(sessao));
    }
  }

  Future<void> _encerrarNoAparelho() async {
    _atual.value = null;
    await _armazenamento.limpar();
  }
}

/// A instância que o app usa.
final SessaoService sessaoService = SessaoService(
  auth: authRepository,
  armazenamento: SessaoRepositorySegura(),
);

import 'dart:async';

import 'package:fe_nexa_app/features/auth/data/sessao.dart';
import 'package:fe_nexa_app/features/auth/data/sessao_repository.dart';
import 'package:flutter/foundation.dart';

/// O "gerente" da sessão: o único lugar que sabe quem está logado e que
/// decide quando a sessão acaba.
///
/// O Spring entrega um JWT de 8 horas e não tem refresh token. Quando o token
/// vence (ou o Spring deixa de aceitá-lo), a sessão acaba e a pessoa entra de
/// novo.
class SessaoService {
  SessaoService({
    required this._armazenamento,
    DateTime Function()? agora,
  }) : _agora = agora ?? DateTime.now;

  final SessaoRepository _armazenamento;
  final DateTime Function() _agora;

  final ValueNotifier<Sessao?> _atual = ValueNotifier(null);
  final StreamController<void> _expiradas = StreamController<void>.broadcast();

  ValueListenable<Sessao?> get atual => _atual;

  /// Avisa quando a sessão acabou SEM a pessoa pedir (token vencido ou recusado
  /// pelo Spring). "Sair" não passa por aqui.
  Stream<void> get expiradas => _expiradas.stream;

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

  /// O token para usar numa chamada agora. `null` se não há sessão, ou se o
  /// token venceu (nesse caso a sessão acaba aqui mesmo).
  Future<String?> tokenDeAcesso() async {
    final sessao = _atual.value;
    if (sessao == null) return null;
    if (!sessao.accessExpirou(agora: _agora())) return sessao.accessToken;

    await expirou(sessao.accessToken);
    return null;
  }

  /// O [token] não vale mais (venceu, ou o Spring o recusou com 401). Se ele
  /// ainda é o da sessão atual, apaga a sessão e avisa [expiradas], que leva a
  /// pessoa ao Início.
  ///
  /// Se a pessoa já entrou de novo com outro token, nada acontece: uma
  /// resposta atrasada não pode derrubar a sessão nova.
  Future<void> expirou(String token) async {
    if (_atual.value?.accessToken != token) return;

    await _encerrarNoAparelho();
    _expiradas.add(null);
  }

  /// "Sair": apaga a sessão do aparelho. O Spring não guarda nada para
  /// revogar, então não há o que avisar a ele.
  Future<void> sair() => _encerrarNoAparelho();

  Future<void> _encerrarNoAparelho() async {
    _atual.value = null;
    await _armazenamento.limpar();
  }
}

/// A instância que o app usa.
final SessaoService sessaoService = SessaoService(
  armazenamento: SessaoRepositorySegura(),
);

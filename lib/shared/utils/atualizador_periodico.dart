import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/widgets.dart';

/// Repete [atualizar] de tempos em tempos, só enquanto o app está na frente.
///
/// Quem usa (uma aba, uma tela) liga com [iniciar] no `initState` e desliga
/// com [parar] no `dispose`. A rodada seguinte só é marcada depois que a
/// anterior termina, então duas rodadas nunca se sobrepõem. Falha não derruba
/// nada: a próxima tentativa vem no intervalo seguinte.
class AtualizadorPeriodico with WidgetsBindingObserver {
  AtualizadorPeriodico({
    required this.atualizar,
    this.intervalo = const Duration(seconds: 20),
    this.nome,
  });

  final Future<void> Function() atualizar;
  final Duration intervalo;

  /// Só identifica a linha no log de debug: `[polling Home] atualizando`.
  final String? nome;

  Timer? _timer;
  bool _ligado = false;
  bool _naFrente = true;
  bool _rodando = false;

  void iniciar() {
    if (_ligado) return;
    _ligado = true;
    WidgetsBinding.instance.addObserver(this);
    _agendar();
  }

  void parar() {
    _ligado = false;
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  /// Liga ou desliga conforme [ativo]. Ao ligar, já faz uma rodada: quem voltou
  /// para a tela vê o dado de agora, não o de quando saiu.
  void definirAtivo(bool ativo) {
    if (ativo == _ligado) return;
    if (ativo) {
      iniciar();
      unawaited(atualizarAgora());
    } else {
      parar();
    }
  }

  /// Faz uma rodada já, sem esperar o intervalo, e recomeça a contagem.
  Future<void> atualizarAgora() async {
    if (!_ligado || !_naFrente) return;
    _timer?.cancel();
    await _rodar();
  }

  void _agendar() {
    _timer?.cancel();
    if (!_ligado || !_naFrente) return;
    _timer = Timer(intervalo, _rodar);
  }

  Future<void> _rodar() async {
    if (_rodando) return;
    _rodando = true;
    _log('atualizando');
    try {
      await atualizar();
    } catch (erro) {
      // Sem isto a falha some sem deixar rastro e parece que "não atualiza".
      _log('falhou: $erro');
    } finally {
      _rodando = false;
    }
    _agendar();
  }

  void _log(String mensagem) {
    if (!kDebugMode) return;
    debugPrint('[polling${nome == null ? '' : ' $nome'}] $mensagem');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _naFrente = state == AppLifecycleState.resumed;
    _timer?.cancel();
    if (_naFrente) unawaited(_rodar());
  }
}

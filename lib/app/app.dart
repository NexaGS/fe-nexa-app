import 'dart:async';

import 'package:fe_nexa_app/app/theme/nexa_theme.dart';
import 'package:fe_nexa_app/features/auth/data/auth_repository.dart';
import 'package:fe_nexa_app/features/auth/data/sessao_service.dart';
import 'package:fe_nexa_app/features/home/home_page.dart';
import 'package:fe_nexa_app/features/inicio/inicio_page.dart';
import 'package:fe_nexa_app/features/splash/nexa_splash.dart';
import 'package:fe_nexa_app/features/splash/splash_config.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_snackbar.dart';
import 'package:flutter/material.dart';

class NexaApp extends StatefulWidget {
  const NexaApp({
    super.key,
    this.sessaoInicial,
    this.sessoes,
    this.mostrarSplash = true,
  });

  /// A sessão guardada no aparelho. Com ela, o app abre direto na Home; sem
  /// ela, no Início (entrar, criar conta ou seguir sem conta).
  final Sessao? sessaoInicial;

  /// Nulo = o gerente de sessão real. Os testes passam um falso.
  final SessaoService? sessoes;

  /// Toca a abertura animada antes da primeira tela. Cores e velocidade em
  /// [SplashConfig]; `false` (ou `SplashConfig.ativa = false`) pula.
  final bool mostrarSplash;

  @override
  State<NexaApp> createState() => _NexaAppState();
}

class _NexaAppState extends State<NexaApp> {
  final _navegador = GlobalKey<NavigatorState>();
  StreamSubscription<void>? _encerradas;

  SessaoService get _sessoes => widget.sessoes ?? sessaoService;

  @override
  void initState() {
    super.initState();
    _encerradas = _sessoes.expiradas.listen(
      (_) => _voltarAoInicio(),
    );
  }

  @override
  void dispose() {
    unawaited(_encerradas?.cancel());
    super.dispose();
  }

  /// A sessão acabou sozinha (token de 8 horas vencido ou recusado pelo
  /// Spring): leva a pessoa ao Início, sem volta, e explica o porquê.
  void _voltarAoInicio() {
    final navegador = _navegador.currentState;
    if (navegador == null) return;

    navegador.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const InicioPage()),
      (rota) => false,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contexto = _navegador.currentContext;
      if (contexto != null && contexto.mounted) {
        NexaSnackbar.aviso(contexto, 'Sua sessão expirou. Entre de novo.');
      }
    });
  }

  /// Início para quem não tem sessão; Home para quem já entrou.
  Widget get _primeiraTela => widget.sessaoInicial == null
      ? const InicioPage()
      : HomePage(sessao: widget.sessaoInicial);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexa',
      navigatorKey: _navegador,
      debugShowCheckedModeBanner: false,
      theme: buildNexaTheme(),
      home: widget.mostrarSplash && SplashConfig.ativa
          ? NexaSplash(destino: _primeiraTela)
          : _primeiraTela,
    );
  }
}

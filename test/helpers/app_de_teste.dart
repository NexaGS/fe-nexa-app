import 'package:fe_nexa_app/app/theme/nexa_theme.dart';
import 'package:flutter/material.dart';

/// Monta o app mínimo para testar um widget sozinho: tema do Nexa e um
/// `Scaffold` com rolagem (assim nada estoura em tela de teste pequena).
///
/// Com [semAnimacao], o widget enxerga "remover animações" ligado, como no
/// celular de quem pediu menos movimento.
Widget appDeTeste(Widget filho, {bool semAnimacao = false}) {
  return MaterialApp(
    theme: buildNexaTheme(),
    home: Scaffold(
      body: SingleChildScrollView(
        child: Builder(
          builder: (context) {
            if (!semAnimacao) return filho;
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: filho,
            );
          },
        ),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:fe_nexa_app/app/theme/nexa_theme.dart';

/// Raiz do aplicativo: aplica o tema Porcelana.
///
/// TODO: trocar o `home` pela tela Início (pasta `features/inicio/`) quando
/// ela for criada. Por enquanto é só um fundo vazio com o tema aplicado.
class NexaApp extends StatelessWidget {
  const NexaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexa',
      debugShowCheckedModeBanner: false,
      theme: buildNexaTheme(),
      home: const Scaffold(),
    );
  }
}

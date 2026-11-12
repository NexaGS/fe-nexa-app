import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/app/theme/nexa_theme.dart';
import 'package:flutter/material.dart';

/// Moldura das galerias de componentes.
///
/// Cada galeria tem o seu ponto de entrada (`lib/galeria/galeria_*.dart`) e se
/// abre com `flutter run -t lib/galeria/galeria_base.dart`. Ela fica fora do
/// app de verdade: não usa rotas, nem Java, só dados fixos. Serve para
/// conferir cada componente em cada estado do Figma.
class GaleriaApp extends StatelessWidget {
  const GaleriaApp({super.key, required this.titulo, required this.secoes});

  final String titulo;
  final List<GaleriaSecao> secoes;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Galeria Nexa',
      debugShowCheckedModeBanner: false,
      theme: buildNexaTheme(),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: NexaColors.background,
          surfaceTintColor: Colors.transparent,
          title: Text(titulo, style: NexaText.title),
        ),
        body: ListView(padding: const EdgeInsets.all(16), children: secoes),
      ),
    );
  }
}

/// Um bloco da galeria: título, uma frase opcional e os exemplos.
class GaleriaSecao extends StatelessWidget {
  const GaleriaSecao({
    super.key,
    required this.titulo,
    required this.children,
    this.descricao,
  });

  final String titulo;
  final String? descricao;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final nota = descricao;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: NexaText.section),
          if (nota != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                nota,
                style: NexaText.small.copyWith(color: NexaColors.inkSoft),
              ),
            ),
          const SizedBox(height: 12),
          for (final filho in children)
            Padding(padding: const EdgeInsets.only(bottom: 12), child: filho),
        ],
      ),
    );
  }
}

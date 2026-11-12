import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_button.dart';
import 'package:flutter/material.dart';

/// Abre uma [NexaFolha] (painel que sobe do pé da tela) e espera ela fechar.
///
/// Fecha ao tocar no botão, ao tocar fora, ao arrastar para baixo ou ao usar o
/// gesto de voltar. Não devolve valor: a folha serve para explicar, não para
/// perguntar (para perguntar, use [mostrarNexaDialogo]).
Future<void> mostrarNexaFolha(
  BuildContext context, {
  required String titulo,
  required List<Widget> children,
  String rotuloFechar = 'Entendi',
}) {
  return showModalBottomSheet<void>(
    context: context,
    // Deixa a folha crescer conforme o conteúdo (letra grande, tela baixa).
    isScrollControlled: true,
    // Não deixa a folha entrar debaixo da barra de status.
    useSafeArea: true,
    backgroundColor: NexaColors.white,
    barrierColor: NexaColors.scrim,
    // Elevação 0 evita o tom esverdeado que o Material 3 põe em superfícies
    // elevadas. O Figma mostra a folha branca pura.
    elevation: 0,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(NexaRadius.dialog),
      ),
    ),
    builder: (_) => NexaFolha(
      titulo: titulo,
      rotuloFechar: rotuloFechar,
      children: children,
    ),
  );
}

/// Conteúdo de uma folha: alça, título, o que você passar e o botão de fechar.
///
/// É só o miolo. A moldura (cantos, fundo escuro atrás) vem de
/// [mostrarNexaFolha]. Prefira abrir por ela.
class NexaFolha extends StatelessWidget {
  const NexaFolha({
    super.key,
    required this.titulo,
    required this.children,
    this.rotuloFechar = 'Entendi',
  });

  final String titulo;

  /// O que aparece entre o título e o botão. Cada filho é separado do
  /// próximo por 16 px.
  final List<Widget> children;

  final String rotuloFechar;

  @override
  Widget build(BuildContext context) {
    // `minimum` garante os 20 px do Figma embaixo mesmo em celular sem barra
    // de gestos; com barra, vale o espaço maior que o sistema pedir.
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: NexaSpacing.lg),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          NexaSpacing.xl,
          NexaSpacing.sm,
          NexaSpacing.xl,
          0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // A alça é só um desenho: arrastar a folha já funciona em
            // qualquer ponto dela, então o leitor de tela não precisa dela.
            const ExcludeSemantics(child: _Alca()),
            const SizedBox(height: NexaSpacing.md),
            Semantics(
              header: true,
              child: Text(titulo, style: NexaText.title),
            ),
            for (final filho in children) ...[
              const SizedBox(height: NexaSpacing.md),
              filho,
            ],
            const SizedBox(height: NexaSpacing.md),
            NexaButton(
              label: rotuloFechar,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

/// A barrinha cinza no alto da folha (40 x 4).
class _Alca extends StatelessWidget {
  const _Alca();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: NexaColors.outline,
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ),
        child: SizedBox(width: 40, height: 4),
      ),
    );
  }
}

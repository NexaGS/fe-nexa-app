import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:flutter/material.dart';

/// Botão-filtro em forma de pílula, com uma setinha para baixo: "Estado: Todos".
class NexaFiltroChip extends StatelessWidget {
  const NexaFiltroChip({
    super.key,
    required this.rotulo,
    required this.aoTocar,
    this.ativo = false,
    this.rotuloSemantico,
  });

  /// O texto da pílula.
  final String rotulo;

  /// `true` quando há um filtro valendo (a pessoa escolheu algo).
  final bool ativo;

  final VoidCallback aoTocar;

  /// O que o leitor de tela diz. Sem ele, lê o próprio [rotulo].
  final String? rotuloSemantico;

  @override
  Widget build(BuildContext context) {
    final corDoTexto = ativo ? NexaColors.greenDark : NexaColors.ink;

    return Semantics(
      button: true,
      label: rotuloSemantico ?? rotulo,
      excludeSemantics: true,
      child: Material(
        color: ativo ? NexaColors.cream : NexaColors.white,
        shape: StadiumBorder(
          side: BorderSide(
            color: ativo ? NexaColors.green : NexaColors.divider,
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: aoTocar,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: NexaSizes.minTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 12, 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    rotulo,
                    style: NexaText.smallStrong.copyWith(color: corDoTexto),
                  ),
                  const SizedBox(width: 6),
                  // Só existe a seta para a direita; girada um quarto de volta
                  // ela aponta para baixo.
                  RotatedBox(
                    quarterTurns: 1,
                    child: NexaIcon(
                      'chevron_right',
                      size: 18,
                      color: corDoTexto,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:flutter/material.dart';

/// Escolha de uma opção entre poucas, lado a lado ("3", "5", "10").
///
/// A opção escolhida ganha fundo claro e um "visto". Trabalha com posições
/// (0, 1, 2...), e a tela converte para o valor que quiser.
class NexaSegmentado extends StatelessWidget {
  const NexaSegmentado({
    super.key,
    required this.opcoes,
    required this.indiceAtual,
    required this.aoSelecionar,
  });

  /// Os textos, na ordem em que aparecem.
  final List<String> opcoes;

  /// Posição da opção escolhida em [opcoes].
  final int indiceAtual;

  /// Recebe a posição da opção tocada.
  final ValueChanged<int> aoSelecionar;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Corta o fundo das pontas para acompanhar a borda arredondada.
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: NexaColors.white,
        borderRadius: BorderRadius.circular(NexaRadius.pill),
        border: Border.all(color: NexaColors.outline),
      ),
      child: Row(
        children: [
          for (var i = 0; i < opcoes.length; i++)
            Expanded(
              child: _Segmento(
                rotulo: opcoes[i],
                ativo: i == indiceAtual,
                temDivisor: i > 0,
                aoTocar: () => aoSelecionar(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segmento extends StatelessWidget {
  const _Segmento({
    required this.rotulo,
    required this.ativo,
    required this.temDivisor,
    required this.aoTocar,
  });

  final String rotulo;
  final bool ativo;
  final bool temDivisor;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: ativo,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: ativo ? NexaColors.cream : Colors.transparent,
        child: InkWell(
          onTap: aoTocar,
          child: Container(
            // 44 px é o mínimo de toque do app (o Figma desenha 40).
            height: NexaSizes.minTouchTarget,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: temDivisor
                  ? const Border(left: BorderSide(color: NexaColors.outline))
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (ativo) ...[
                  const NexaIcon('check', size: 18),
                  const SizedBox(width: 4),
                ],
                Text(
                  rotulo,
                  style: ativo
                      ? NexaText.smallStrong
                      : NexaText.small.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

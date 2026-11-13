import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:flutter/material.dart';

/// Linha de configuração com chave liga/desliga: título, texto de apoio e o
/// interruptor à direita ("Usar minha localização").
class NexaLinhaConfig extends StatelessWidget {
  const NexaLinhaConfig({
    super.key,
    required this.titulo,
    required this.ativa,
    required this.aoAlterar,
    this.descricao,
  });

  final String titulo;

  /// Texto pequeno embaixo do título.
  final String? descricao;
  final bool ativa;

  /// Nulo deixa a chave desabilitada.
  final ValueChanged<bool>? aoAlterar;

  @override
  Widget build(BuildContext context) {
    final apoio = descricao;

    return MergeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: NexaText.bodyStrong),
                if (apoio != null)
                  Text(
                    apoio,
                    style: NexaText.small.copyWith(color: NexaColors.inkSoft),
                  ),
              ],
            ),
          ),
          const SizedBox(width: NexaSpacing.sm),
          Switch(
            value: ativa,
            onChanged: aoAlterar,
            trackColor: WidgetStateProperty.resolveWith<Color?>(
              (estados) => estados.contains(WidgetState.selected)
                  ? NexaColors.lime
                  : NexaColors.cardBorder,
            ),
            trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
              (estados) => estados.contains(WidgetState.selected)
                  ? Colors.transparent
                  : NexaColors.outline,
            ),
            thumbColor: WidgetStateProperty.resolveWith<Color?>(
              (estados) => estados.contains(WidgetState.selected)
                  ? NexaColors.ink
                  : NexaColors.outline,
            ),
            thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
              (estados) => estados.contains(WidgetState.selected)
                  ? const Icon(Icons.check, size: 16, color: NexaColors.white)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

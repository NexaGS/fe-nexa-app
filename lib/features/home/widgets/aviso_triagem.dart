import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:flutter/material.dart';

/// Rodapé fixo da Home, como no Figma: a espera é uma estimativa e não decide
/// quem é atendido primeiro.
class AvisoTriagem extends StatelessWidget {
  const AvisoTriagem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: NexaSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: NexaIcon('info', size: 14, color: NexaColors.inkSoft),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Estimativas podem mudar. A prioridade é definida pela triagem.',
              style: NexaText.caption.copyWith(color: NexaColors.inkSoft),
            ),
          ),
        ],
      ),
    );
  }
}

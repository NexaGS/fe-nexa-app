import 'dart:async';

import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/features/unidades/nexa_folha_espera.dart';
import 'package:fe_nexa_app/shared/utils/espera.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_button.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_espera_chip.dart';
import 'package:flutter/material.dart';

/// O bloco verde-claro do alto: espera estimada, selo da faixa e aviso da
/// triagem.
class CartaoDeEspera extends StatelessWidget {
  const CartaoDeEspera({super.key, required this.tempoEspera});

  final double? tempoEspera;

  @override
  Widget build(BuildContext context) {
    final minutos = tempoEspera;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: NexaColors.cream,
        borderRadius: BorderRadius.circular(NexaRadius.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(NexaSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Espera estimada',
              style: NexaText.small.copyWith(color: NexaColors.inkSoft),
            ),
            const SizedBox(height: 10),
            Text(
              minutos == null
                  ? 'Estimativa indisponível'
                  : textoCurtoDaEspera(minutos),
              style: minutos == null
                  ? NexaText.title.copyWith(color: NexaColors.inkSoft)
                  : NexaText.bigNumber.copyWith(letterSpacing: -1.32),
            ),
            const SizedBox(height: 10),
            NexaEsperaChip(nivel: nivelDaEspera(minutos)),
            const SizedBox(height: NexaSpacing.sm),
            const Divider(height: 1, thickness: 1, color: NexaColors.lime),
            const SizedBox(height: NexaSpacing.sm),
            const Text(
              'A triagem define a ordem de atendimento. Por isso a sua espera '
              'pode ser maior ou menor.',
              style: NexaText.small,
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: NexaButton(
                label: 'Como calculamos?',
                iconName: 'help',
                variant: NexaButtonVariant.link,
                onPressed: () => unawaited(mostrarFolhaEspera(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

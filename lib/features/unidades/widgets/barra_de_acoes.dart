import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_button.dart';
import 'package:flutter/material.dart';

/// A barra fixa de baixo: "Como chegar" e "Compartilhar".
class BarraDeAcoes extends StatelessWidget {
  const BarraDeAcoes({
    super.key,
    required this.aoComoChegar,
    required this.aoCompartilhar,
  });

  final VoidCallback aoComoChegar;
  final VoidCallback aoCompartilhar;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: NexaColors.white,
        border: Border(top: BorderSide(color: NexaColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(NexaSpacing.sm).copyWith(
            left: NexaSpacing.md,
            right: NexaSpacing.md,
          ),
          child: Row(
            spacing: NexaSpacing.sm,
            children: [
              Expanded(
                child: NexaButton(
                  label: 'Como chegar',
                  iconName: 'navigation',
                  onPressed: aoComoChegar,
                ),
              ),
              Expanded(
                child: NexaButton(
                  label: 'Compartilhar',
                  iconName: 'share',
                  variant: NexaButtonVariant.outline,
                  onPressed: aoCompartilhar,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

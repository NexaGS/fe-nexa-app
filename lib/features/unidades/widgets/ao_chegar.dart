import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_cartao.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:flutter/material.dart';

/// "Ao chegar": os três passos de quem chega à unidade.
class AoChegar extends StatelessWidget {
  const AoChegar({super.key});

  @override
  Widget build(BuildContext context) {
    return const NexaCartao(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          NexaSpacing.md,
          NexaSpacing.md,
          NexaSpacing.md,
          NexaSpacing.xs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ao chegar', style: NexaText.section),
            _Passo(
              iconName: 'user_check',
              numero: 1,
              texto: 'Faça o check-in no totem',
            ),
            _Passo(iconName: 'ticket', numero: 2, texto: 'Receba sua senha'),
            _Passo(
              iconName: 'monitor',
              numero: 3,
              texto: 'Acompanhe a chamada no painel',
            ),
          ],
        ),
      ),
    );
  }
}

class _Passo extends StatelessWidget {
  const _Passo({
    required this.iconName,
    required this.numero,
    required this.texto,
  });

  final String iconName;
  final int numero;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          spacing: NexaSpacing.sm,
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                color: NexaColors.primrose,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(
                dimension: 44,
                child: Center(child: NexaIcon(iconName)),
              ),
            ),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$numero.',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: ' $texto'),
                  ],
                ),
                style: NexaText.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

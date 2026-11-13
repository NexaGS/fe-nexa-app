import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_button.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:flutter/material.dart';

/// Linha do local usado na busca: pin, nome do local e, se houver, um link de ação.
class NexaLocalAtual extends StatelessWidget {
  const NexaLocalAtual({
    super.key,
    required this.local,
    this.aoAlterar,
    this.rotuloAcao = 'Alterar',
  });

  /// Texto pronto, por exemplo "Bela Vista, São Paulo".
  final String local;

  /// O que o link da direita faz. Sem ele (nulo), o link nem aparece: é o caso
  /// da Home, onde o local vem sempre do GPS e não se escolhe à mão.
  final VoidCallback? aoAlterar;

  /// Texto do link da direita. Normalmente "Alterar".
  final String rotuloAcao;

  @override
  Widget build(BuildContext context) {
    final acao = aoAlterar;
    return Row(
      children: [
        const NexaIcon('pin', size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            local,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: NexaText.bodyMedium,
          ),
        ),
        if (acao != null)
          NexaButton(
            label: rotuloAcao,
            variant: NexaButtonVariant.link,
            onPressed: acao,
          ),
      ],
    );
  }
}

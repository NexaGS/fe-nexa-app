import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/shared/utils/primeiro_nome.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_samu_button.dart';
import 'package:flutter/material.dart';

/// Linha do topo das telas: saudação à esquerda e o botão SAMU à direita.
/// Sem [nome] (visitante), mostra só "Olá".
class NexaSaudacao extends StatelessWidget {
  const NexaSaudacao({super.key, this.nome});

  final String? nome;

  @override
  Widget build(BuildContext context) {
    final primeiro = primeiroNome(nome);
    final texto = primeiro == null ? 'Olá' : 'Olá, $primeiro';

    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: NexaText.title,
            ),
          ),
          const SizedBox(width: 12),
          const NexaSamuButton(),
        ],
      ),
    );
  }
}
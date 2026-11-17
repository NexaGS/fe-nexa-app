import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/shared/utils/iniciais.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:flutter/material.dart';

/// Círculo com as iniciais do nome ("AS" para Ana Souza).
/// Sem nome, mostra o ícone de pessoa.
class NexaAvatar extends StatelessWidget {
  const NexaAvatar({super.key, required this.nome, this.visitante = false});

  final String? nome;

  /// Visitante: círculo cinza com borda e o ícone de pessoa maior, em vez do
  /// verde-claro de quem tem conta.
  final bool visitante;

  @override
  Widget build(BuildContext context) {
    final iniciais = iniciaisDoNome(nome);

    return ExcludeSemantics(
      child: Container(
        width: NexaSizes.avatar,
        height: NexaSizes.avatar,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: visitante ? NexaColors.cardBorder : NexaColors.primrose,
          shape: BoxShape.circle,
          border: visitante ? Border.all(color: NexaColors.divider) : null,
        ),
        child: iniciais.isEmpty
            ? NexaIcon('user', size: visitante ? 40 : 32)
            : Text(iniciais, style: NexaText.display),
      ),
    );
  }
}

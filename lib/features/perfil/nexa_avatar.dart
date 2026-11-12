import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/shared/utils/iniciais.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:flutter/material.dart';

/// Círculo com as iniciais do nome ("AS" para Ana Souza).
/// Sem nome, mostra o ícone de pessoa.
class NexaAvatar extends StatelessWidget {
  const NexaAvatar({super.key, required this.nome});

  final String? nome;

  @override
  Widget build(BuildContext context) {
    final iniciais = iniciaisDoNome(nome);

    // O nome já aparece escrito ao lado, então o leitor de tela não precisa
    // ler o avatar.
    return ExcludeSemantics(
      child: Container(
        width: NexaSizes.avatar,
        height: NexaSizes.avatar,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: NexaColors.primrose,
          shape: BoxShape.circle,
        ),
        child: iniciais.isEmpty
            ? const NexaIcon('user', size: 32)
            : Text(iniciais, style: NexaText.display),
      ),
    );
  }
}

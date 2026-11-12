import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:flutter/material.dart';

/// Botão de coração: liga e desliga a favorita de uma unidade.
///
/// Não guarda nada: quem decide o que fazer ao tocar é [aoAlternar]. A área
/// de toque tem 48 px, mais que o mínimo de 44 px do app.
class NexaFavoritoButton extends StatelessWidget {
  const NexaFavoritoButton({
    super.key,
    required this.favorita,
    required this.aoAlternar,
    this.nomeDaUnidade,
  });

  /// `true` desenha o coração cheio e verde.
  final bool favorita;

  /// Nulo deixa o botão desabilitado.
  final VoidCallback? aoAlternar;

  /// Entra no texto do leitor de tela: "Adicionar às favoritas: Unidade B".
  final String? nomeDaUnidade;

  @override
  Widget build(BuildContext context) {
    final acao = favorita ? 'Remover das favoritas' : 'Adicionar às favoritas';
    final nome = nomeDaUnidade;

    return IconButton(
      tooltip: nome == null ? acao : '$acao: $nome',
      onPressed: aoAlternar,
      style: IconButton.styleFrom(
        fixedSize: const Size.square(NexaSizes.heartButton),
        padding: EdgeInsets.zero,
      ),
      icon: NexaIcon(
        favorita ? 'heart_filled' : 'heart',
        color: favorita ? NexaColors.green : NexaColors.ink,
      ),
    );
  }
}

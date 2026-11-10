import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:flutter/material.dart';

/// Avisinhos que aparecem por cima da tela e somem sozinhos.
abstract final class NexaSnackbar {
  /// Aviso vermelho: algo deu errado.
  static void erro(BuildContext context, String mensagem) {
    _mostrar(context, mensagem, cor: NexaColors.red, icone: 'alert');
  }

  /// Aviso escuro e neutro: uma informação que não é erro.
  static void aviso(BuildContext context, String mensagem) {
    _mostrar(context, mensagem, cor: NexaColors.ink, icone: 'info');
  }

  static void _mostrar(
    BuildContext context,
    String mensagem, {
    required Color cor,
    required String icone,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: cor,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NexaRadius.snackbar),
          ),
          content: Row(
            children: [
              NexaIcon(icone, color: NexaColors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  mensagem,
                  style: NexaText.small.copyWith(color: NexaColors.white),
                ),
              ),
            ],
          ),
        ),
      );
  }
}

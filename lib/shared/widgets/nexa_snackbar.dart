import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:flutter/material.dart';

/// Avisos que aparecem por cima da tela e somem sozinhos.
abstract final class NexaSnackbar {
  /// Aviso vermelho: algo deu errado.
  static void erro(
    BuildContext context,
    String mensagem, {
    String? rotuloAcao,
    VoidCallback? aoAcionar,
  }) {
    _mostrar(
      context,
      mensagem,
      cor: NexaColors.red,
      icone: 'alert',
      rotuloAcao: rotuloAcao,
      aoAcionar: aoAcionar,
    );
  }

  /// Aviso escuro e neutro: uma informação que não é erro.
  static void aviso(
    BuildContext context,
    String mensagem, {
    String? rotuloAcao,
    VoidCallback? aoAcionar,
  }) {
    _mostrar(
      context,
      mensagem,
      cor: NexaColors.ink,
      icone: 'info',
      rotuloAcao: rotuloAcao,
      aoAcionar: aoAcionar,
    );
  }

  static void desfazer(
    BuildContext context,
    String mensagem, {
    required VoidCallback aoDesfazer,
    String rotuloAcao = 'Desfazer',
  }) {
    _mostrar(
      context,
      mensagem,
      cor: NexaColors.greenDark,
      rotuloAcao: rotuloAcao,
      aoAcionar: aoDesfazer,
    );
  }

  static void _mostrar(
    BuildContext context,
    String mensagem, {
    required Color cor,
    String? icone,
    String? rotuloAcao,
    VoidCallback? aoAcionar,
  }) {
    final nomeDoIcone = icone;
    final rotulo = rotuloAcao;
    final aoTocar = aoAcionar;
    final acao = (rotulo == null || aoTocar == null)
        ? null
        : SnackBarAction(
            label: rotulo,
            textColor: NexaColors.primrose,
            onPressed: aoTocar,
          );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: cor,
          action: acao,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NexaRadius.snackbar),
          ),
          content: Row(
            children: [
              if (nomeDoIcone != null) ...[
                NexaIcon(nomeDoIcone, color: NexaColors.white),
                const SizedBox(width: 12),
              ],
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

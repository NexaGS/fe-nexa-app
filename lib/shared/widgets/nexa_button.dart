import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:flutter/material.dart';

enum NexaButtonVariant { primary, outline, text, link }

class NexaButton extends StatelessWidget {
  const NexaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = NexaButtonVariant.primary,
    this.carregando = false,
    this.labelCarregando,
  });

  final String label;
  final VoidCallback? onPressed;
  final NexaButtonVariant variant;

  /// Enquanto for `true`, o botão fica travado e mostra o círculo girando.
  final bool carregando;

  /// Texto durante o carregamento (por exemplo, "Entrando…").
  /// Se for nulo, continua mostrando o [label].
  final String? labelCarregando;

  @override
  Widget build(BuildContext context) {
    // Travar o botão enquanto carrega evita o toque duplo.
    final VoidCallback? acao = carregando ? null : onPressed;
    final Widget conteudo = carregando
        ? _Carregando(texto: labelCarregando ?? label)
        : Text(label);

    return switch (variant) {
      NexaButtonVariant.primary => FilledButton(
        onPressed: acao,
        style: FilledButton.styleFrom(
          backgroundColor: NexaColors.lime,
          foregroundColor: NexaColors.ink,
          // Carregando não é "desabilitado": o botão continua verde-lima.
          disabledBackgroundColor: carregando ? NexaColors.lime : null,
          disabledForegroundColor: carregando ? NexaColors.ink : null,
          minimumSize: const Size.fromHeight(52),
          shape: const StadiumBorder(),
          textStyle: NexaText.bodyStrong,
        ),
        child: conteudo,
      ),
      NexaButtonVariant.outline => OutlinedButton(
        onPressed: acao,
        style: OutlinedButton.styleFrom(
          backgroundColor: NexaColors.white,
          foregroundColor: NexaColors.ink,
          minimumSize: const Size.fromHeight(52),
          shape: const StadiumBorder(),
          side: const BorderSide(color: NexaColors.outline),
          textStyle: NexaText.bodyStrong,
        ),
        child: conteudo,
      ),
      NexaButtonVariant.text => TextButton(
        onPressed: acao,
        style: TextButton.styleFrom(
          foregroundColor: NexaColors.ink,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: const StadiumBorder(),
          textStyle: NexaText.bodyStrong.copyWith(
            decoration: TextDecoration.underline,
          ),
        ),
        child: conteudo,
      ),
      NexaButtonVariant.link => TextButton(
        onPressed: acao,
        style: TextButton.styleFrom(
          foregroundColor: NexaColors.ink,
          disabledForegroundColor: NexaColors.inkSoft,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: const StadiumBorder(),
          textStyle: NexaText.smallStrong.copyWith(
            decoration: TextDecoration.underline,
          ),
        ),
        child: conteudo,
      ),
    };
  }
}

/// O conteúdo do botão enquanto carrega: círculo girando + texto.
class _Carregando extends StatelessWidget {
  const _Carregando({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: NexaColors.ink,
            backgroundColor: NexaColors.ink.withValues(alpha: 0.25),
          ),
        ),
        const SizedBox(width: 8),
        Text(texto),
      ],
    );
  }
}
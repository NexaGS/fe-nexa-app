import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:flutter/material.dart';

/// Cor do aviso: [neutro] (cinza-azulado) para situação do app, como "sem
/// internet"; [informativo] (azul) para uma dica.
enum NexaBannerTom { neutro, informativo }

/// Aviso fixo no alto de uma lista, com ícone, mensagem e uma ação opcional.
class NexaBanner extends StatelessWidget {
  const NexaBanner({
    super.key,
    required this.mensagem,
    this.tom = NexaBannerTom.neutro,
    this.iconName,
    this.rotuloAcao,
    this.aoAcionar,
    this.acaoEmBotao = false,
  });

  final String mensagem;
  final NexaBannerTom tom;

  /// Nome do ícone. Se for nulo, cada tom usa o seu: "wifi_off" ou "info".
  final String? iconName;

  /// A ação só aparece se [rotuloAcao] e [aoAcionar] forem os dois informados.
  final String? rotuloAcao;
  final VoidCallback? aoAcionar;

  /// `false`: a ação é um link sublinhado ao lado da mensagem.
  /// `true`: a ação é um botão de contorno embaixo da mensagem.
  final bool acaoEmBotao;

  @override
  Widget build(BuildContext context) {
    final (corDoTexto, corDoFundo, iconePadrao) = switch (tom) {
      NexaBannerTom.neutro => (
        NexaColors.slate,
        NexaColors.slateSurface,
        'wifi_off',
      ),
      NexaBannerTom.informativo => (
        NexaColors.info,
        NexaColors.infoSurface,
        'info',
      ),
    };

    // Cópias locais: o Dart só garante que um campo não é nulo depois do
    // `if (x != null)` quando x é uma variável local.
    final rotulo = rotuloAcao;
    final acao = aoAcionar;
    final temAcao = rotulo != null && acao != null;

    final icone = NexaIcon(iconName ?? iconePadrao, size: 20, color: corDoTexto);
    final texto = Text(
      mensagem,
      style: NexaText.smallStrong.copyWith(color: corDoTexto),
    );

    final Widget conteudo;
    if (rotulo != null && acao != null && acaoEmBotao) {
      conteudo = Padding(
        padding: const EdgeInsets.all(NexaSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                icone,
                const SizedBox(width: NexaSpacing.xs),
                Expanded(child: texto),
              ],
            ),
            const SizedBox(height: NexaSpacing.sm),
            OutlinedButton(
              onPressed: acao,
              style: OutlinedButton.styleFrom(
                backgroundColor: NexaColors.white,
                foregroundColor: corDoTexto,
                side: BorderSide(color: corDoTexto),
                shape: const StadiumBorder(),
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: NexaSpacing.lg),
                textStyle: NexaText.smallStrong,
              ),
              child: Text(rotulo),
            ),
          ],
        ),
      );
    } else {
      conteudo = Padding(
        padding: EdgeInsets.fromLTRB(
          NexaSpacing.md,
          0,
          temAcao ? NexaSpacing.xs : NexaSpacing.md,
          0,
        ),
        child: Row(
          children: [
            icone,
            const SizedBox(width: NexaSpacing.xs),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: NexaSpacing.sm),
                child: texto,
              ),
            ),
            if (rotulo != null && acao != null)
              TextButton(
                onPressed: acao,
                style: TextButton.styleFrom(
                  foregroundColor: corDoTexto,
                  minimumSize: const Size(0, NexaSizes.minTouchTarget),
                  padding: const EdgeInsets.symmetric(horizontal: NexaSpacing.xs),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: const StadiumBorder(),
                  textStyle: NexaText.smallStrong.copyWith(
                    decoration: TextDecoration.underline,
                  ),
                ),
                child: Text(rotulo),
              ),
          ],
        ),
      );
    }

    return Semantics(
      container: true,
      liveRegion: true,
      child: SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: corDoFundo,
            borderRadius: BorderRadius.circular(NexaRadius.banner),
          ),
          child: conteudo,
        ),
      ),
    );
  }
}

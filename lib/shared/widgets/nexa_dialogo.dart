import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_button.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:flutter/material.dart';

/// Abre o [NexaDialogo] e devolve o que a pessoa escolheu.
Future<bool> mostrarNexaDialogo(
  BuildContext context, {
  required String titulo,
  required String texto,
  required String rotuloConfirmar,
  required String rotuloCancelar,
  String? iconName,
  String? iconeConfirmar,
  bool destrutivo = false,
}) async {
  final resposta = await showDialog<bool>(
    context: context,
    barrierColor: NexaColors.scrim,
    builder: (_) => NexaDialogo(
      titulo: titulo,
      texto: texto,
      rotuloConfirmar: rotuloConfirmar,
      rotuloCancelar: rotuloCancelar,
      iconName: iconName,
      iconeConfirmar: iconeConfirmar,
      destrutivo: destrutivo,
    ),
  );
  return resposta ?? false;
}

/// Diálogo de pergunta com duas saídas: confirmar ou cancelar.
class NexaDialogo extends StatelessWidget {
  const NexaDialogo({
    super.key,
    required this.titulo,
    required this.texto,
    required this.rotuloConfirmar,
    required this.rotuloCancelar,
    this.iconName,
    this.iconeConfirmar,
    this.destrutivo = false,
  });

  final String titulo;
  final String texto;
  final String rotuloConfirmar;
  final String rotuloCancelar;

  /// Ícone vermelho de 32 px no alto do diálogo. Sem ele, o título abre o texto.
  final String? iconName;

  /// Ícone dentro do botão de confirmar (por exemplo, o telefone do SAMU).
  final String? iconeConfirmar;

  /// `true` para o jeito destrutivo (botões lado a lado, confirmar vermelho).
  final bool destrutivo;

  @override
  Widget build(BuildContext context) {
    final icone = iconName;
    void confirmar() => Navigator.of(context).pop(true);
    void cancelar() => Navigator.of(context).pop(false);

    return Dialog(
      backgroundColor: NexaColors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NexaRadius.dialog),
      ),
      child: Semantics(
        scopesRoute: true,
        namesRoute: true,
        explicitChildNodes: true,
        label: titulo,
        child: Padding(
          padding: const EdgeInsets.all(NexaSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (icone != null) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: NexaIcon(icone, size: 32, color: NexaColors.red),
                ),
                const SizedBox(height: NexaSpacing.md),
              ],
              Semantics(
                header: true,
                child: Text(titulo, style: NexaText.title),
              ),
              const SizedBox(height: NexaSpacing.md),
              Text(
                texto,
                style: NexaText.body.copyWith(color: NexaColors.inkSoft),
              ),
              const SizedBox(height: NexaSpacing.md),
              if (destrutivo)
                _AcoesLadoALado(
                  rotuloConfirmar: rotuloConfirmar,
                  rotuloCancelar: rotuloCancelar,
                  iconeConfirmar: iconeConfirmar,
                  aoConfirmar: confirmar,
                  aoCancelar: cancelar,
                )
              else
                _AcoesEmpilhadas(
                  rotuloConfirmar: rotuloConfirmar,
                  rotuloCancelar: rotuloCancelar,
                  iconeConfirmar: iconeConfirmar,
                  aoConfirmar: confirmar,
                  aoCancelar: cancelar,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Jeito padrão: confirmar (verde-lima) em cima, cancelar (texto) embaixo,
/// os dois na largura toda.
class _AcoesEmpilhadas extends StatelessWidget {
  const _AcoesEmpilhadas({
    required this.rotuloConfirmar,
    required this.rotuloCancelar,
    required this.iconeConfirmar,
    required this.aoConfirmar,
    required this.aoCancelar,
  });

  final String rotuloConfirmar;
  final String rotuloCancelar;
  final String? iconeConfirmar;
  final VoidCallback aoConfirmar;
  final VoidCallback aoCancelar;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NexaButton(
          label: rotuloConfirmar,
          iconName: iconeConfirmar,
          onPressed: aoConfirmar,
        ),
        const SizedBox(height: 4),
        _BotaoCancelar(
          rotulo: rotuloCancelar,
          larguraTotal: true,
          aoTocar: aoCancelar,
        ),
      ],
    );
  }
}

/// Jeito destrutivo: cancelar e confirmar lado a lado, à direita.
class _AcoesLadoALado extends StatelessWidget {
  const _AcoesLadoALado({
    required this.rotuloConfirmar,
    required this.rotuloCancelar,
    required this.iconeConfirmar,
    required this.aoConfirmar,
    required this.aoCancelar,
  });

  final String rotuloConfirmar;
  final String rotuloCancelar;
  final String? iconeConfirmar;
  final VoidCallback aoConfirmar;
  final VoidCallback aoCancelar;

  @override
  Widget build(BuildContext context) {
    final icone = iconeConfirmar;

    return Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: NexaSpacing.xs,
      runSpacing: NexaSpacing.xs,
      children: [
        _BotaoCancelar(
          rotulo: rotuloCancelar,
          larguraTotal: false,
          aoTocar: aoCancelar,
        ),
        FilledButton(
          onPressed: aoConfirmar,
          style: FilledButton.styleFrom(
            backgroundColor: NexaColors.red,
            // No Figma o texto sobre o vermelho é o cinza-claro "grey/93",
            // o mesmo tom da borda dos cartões.
            foregroundColor: NexaColors.cardBorder,
            minimumSize: const Size(0, NexaSizes.buttonHeight),
            padding: const EdgeInsets.symmetric(horizontal: NexaSpacing.xl),
            shape: const StadiumBorder(),
            textStyle: NexaText.bodyStrong,
          ),
          child: icone == null
              ? Text(rotuloConfirmar)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: NexaSpacing.xs,
                  children: [
                    NexaIcon(icone, size: 20, color: NexaColors.cardBorder),
                    Text(rotuloConfirmar),
                  ],
                ),
        ),
      ],
    );
  }
}

/// Botão de texto "Cancelar". Fica sem sublinhado, como no Figma.
class _BotaoCancelar extends StatelessWidget {
  const _BotaoCancelar({
    required this.rotulo,
    required this.larguraTotal,
    required this.aoTocar,
  });

  final String rotulo;
  final bool larguraTotal;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: aoTocar,
      style: TextButton.styleFrom(
        foregroundColor: NexaColors.ink,
        minimumSize: larguraTotal
            ? const Size.fromHeight(NexaSizes.textButtonHeight)
            : const Size(0, NexaSizes.textButtonHeight),
        padding: const EdgeInsets.symmetric(horizontal: NexaSpacing.md),
        shape: const StadiumBorder(),
        textStyle: NexaText.bodyStrong,
      ),
      child: Text(rotulo),
    );
  }
}

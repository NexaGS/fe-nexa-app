import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/shared/utils/espera.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:flutter/material.dart';

/// O selo que diz como está a espera: ponto colorido (ou ícone) e texto.
///
/// A cor nunca é o único sinal: toda faixa tem texto ("Espera curta"), para
/// quem não enxerga a diferença entre verde e vermelho.
class NexaEsperaChip extends StatelessWidget {
  const NexaEsperaChip({super.key, required this.nivel});

  final NivelEspera nivel;

  /// Texto, cores e ícone de cada nível. Só as faixas têm ponto; "Dados
  /// antigos" e "Sem dados" trocam o ponto por um ícone.
  static ({String texto, Color corDoTexto, Color corDoPonto, String? icone})
  _aparenciaDe(NivelEspera nivel) {
    return switch (nivel) {
      NivelEspera.curta => (
        texto: 'Espera curta',
        corDoTexto: NexaColors.greenDark,
        corDoPonto: NexaColors.green,
        icone: null,
      ),
      NivelEspera.media => (
        texto: 'Espera média',
        corDoTexto: NexaColors.orange,
        corDoPonto: NexaColors.orange,
        icone: null,
      ),
      NivelEspera.longa => (
        texto: 'Espera longa',
        corDoTexto: NexaColors.red,
        corDoPonto: NexaColors.red,
        icone: null,
      ),
      NivelEspera.dadosAntigos => (
        texto: 'Dados antigos',
        corDoTexto: NexaColors.orange,
        corDoPonto: NexaColors.orange,
        icone: 'history',
      ),
      // O Figma usa uma nuvem cortada; o ícone mais próximo que temos é este.
      NivelEspera.semDados => (
        texto: 'Sem dados recentes',
        corDoTexto: NexaColors.slate,
        corDoPonto: NexaColors.slate,
        icone: 'wifi_off',
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final aparencia = _aparenciaDe(nivel);
    final icone = aparencia.icone;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icone == null)
          DecoratedBox(
            decoration: BoxDecoration(
              color: aparencia.corDoPonto,
              shape: BoxShape.circle,
            ),
            child: const SizedBox.square(dimension: 8),
          )
        else
          NexaIcon(icone, size: 16, color: aparencia.corDoTexto),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            aparencia.texto,
            style: NexaText.smallStrong.copyWith(color: aparencia.corDoTexto),
          ),
        ),
      ],
    );
  }
}

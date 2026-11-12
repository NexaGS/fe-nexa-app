import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/shared/utils/espera.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_espera_chip.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_folha.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:flutter/material.dart';

/// Abre a folha "Como calculamos a espera".
///
/// É a mesma folha para quem chega pelo Perfil ("Como calculamos a espera")
/// e pelo detalhe da unidade ("Como calculamos?"). Por isso o texto mora aqui,
/// em um lugar só.
Future<void> mostrarFolhaEspera(BuildContext context) {
  return mostrarNexaFolha(
    context,
    titulo: 'Como calculamos a espera',
    children: const [
      _Explicacao(
        iconName: 'users',
        texto: 'Contamos quantas pessoas estão aguardando agora.',
      ),
      _Explicacao(
        iconName: 'timer',
        texto:
            'Comparamos com o tempo que a unidade levou para atender nas '
            'últimas horas.',
      ),
      _LegendaDasFaixas(),
    ],
  );
}

/// Uma explicação: círculo verde-claro com ícone e o texto ao lado.
class _Explicacao extends StatelessWidget {
  const _Explicacao({required this.iconName, required this.texto});

  final String iconName;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: NexaSpacing.sm,
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            color: NexaColors.primrose,
            shape: BoxShape.circle,
          ),
          child: SizedBox.square(
            dimension: 40,
            child: Center(child: NexaIcon(iconName, size: 22)),
          ),
        ),
        // 7 px no alto alinham a primeira linha com o centro do círculo.
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Text(texto, style: NexaText.body),
          ),
        ),
      ],
    );
  }
}

/// O quadro cinza que diz o que cada faixa quer dizer em horas.
///
/// Os números saem de [limiteEsperaCurtaMin] e [limiteEsperaMediaMin], os
/// mesmos que [nivelDaEspera] usa. Se a regra mudar, a legenda muda junto.
class _LegendaDasFaixas extends StatelessWidget {
  const _LegendaDasFaixas();

  static String _horas(double minutos) {
    final horas = (minutos / 60).round();
    return horas == 1 ? '1 hora' : '$horas horas';
  }

  @override
  Widget build(BuildContext context) {
    final curta = _horas(limiteEsperaCurtaMin);
    final media = _horas(limiteEsperaMediaMin);
    final inicioDaMedia = (limiteEsperaCurtaMin / 60).round();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: NexaColors.cardBorder,
        borderRadius: BorderRadius.circular(NexaRadius.banner),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: NexaSpacing.md,
          vertical: 14,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 7.5,
          children: [
            _LinhaDaLegenda(
              nivel: NivelEspera.curta,
              faixa: 'até $curta',
            ),
            _LinhaDaLegenda(
              nivel: NivelEspera.media,
              faixa: 'de $inicioDaMedia a $media',
            ),
            _LinhaDaLegenda(
              nivel: NivelEspera.longa,
              faixa: 'mais de $media',
            ),
          ],
        ),
      ),
    );
  }
}

class _LinhaDaLegenda extends StatelessWidget {
  const _LinhaDaLegenda({required this.nivel, required this.faixa});

  final NivelEspera nivel;
  final String faixa;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 4,
      children: [
        NexaEsperaChip(nivel: nivel),
        Flexible(
          child: Text(
            '· $faixa',
            style: NexaText.small.copyWith(color: NexaColors.inkSoft),
          ),
        ),
      ],
    );
  }
}

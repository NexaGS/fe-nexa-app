import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/shared/utils/espera.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_cartao.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_espera_chip.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_favorito_button.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_skeleton.dart';
import 'package:flutter/material.dart';

/// Cartão de uma unidade de saúde nas listas (Home, Favoritas, Busca).
class NexaUnidadeCard extends StatelessWidget {
  const NexaUnidadeCard({
    super.key,
    required this.nome,
    required this.tempoEspera,
    required this.favorita,
    required this.aoAlternarFavorita,
    this.aoTocar,
    this.detalhes = const [],
    this.chegada,
    this.menorEspera = false,
    this.dadosAntigos = false,
  });

  final String nome;

  /// Espera em minutos, como o Java devolve (`tempoEspera`). `null` = sem dado.
  final double? tempoEspera;

  final bool favorita;

  /// Toque no coração. `null` desabilita o botão.
  final VoidCallback? aoAlternarFavorita;

  /// Toque no cartão (abrir o detalhe da unidade).
  final VoidCallback? aoTocar;

  /// Pedaços de texto pequeno da linha de baixo, separados por "·":
  /// por exemplo `['3 km', '4 aguardando', 'há 2 min']`. Vazio = sem linha.
  final List<String> detalhes;

  /// Frase extra com um ícone de pessoa andando, por exemplo "Se sair agora,
  /// você chega por volta das 14h20". Nulo = sem frase.
  final String? chegada;

  /// Põe o selo "Menor espera perto de você" no alto do cartão.
  final bool menorEspera;

  /// `true` quando o dado é velho. Quem decide é a tela, pela hora da última
  /// atualização (ver `espera.dart`). Sem número, vale "Estimativa indisponível".
  final bool dadosAntigos;

  @override
  Widget build(BuildContext context) {
    final minutos = tempoEspera;
    final frase = chegada;
    final nivel = minutos == null
        ? NivelEspera.semDados
        : dadosAntigos
        ? NivelEspera.dadosAntigos
        : nivelDaEspera(minutos);

    return NexaCartao(
      aoTocar: aoTocar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // A linha do nome tem 48 px por causa do coração (área de toque do
          // Figma) e começa 12 px acima do texto. Por isso o espaço de cima é
          // 16 com selo (ele vem primeiro) e 4 sem selo (16 - 12).
          if (menorEspera) ...[
            const SizedBox(height: NexaSpacing.md),
            const _Linha(child: Align(
              alignment: Alignment.centerLeft,
              child: _Selo(),
            )),
          ] else
            const SizedBox(height: 4),
          Padding(
            // 4 e não 16 na direita: o botão de 48 px tem 12 px de ar de cada
            // lado do ícone, e o ícone precisa terminar na margem de 16.
            padding: const EdgeInsets.only(left: NexaSpacing.md, right: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    nome,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: NexaText.bodyStrong,
                  ),
                ),
                const SizedBox(width: NexaSpacing.xs),
                NexaFavoritoButton(
                  favorita: favorita,
                  aoAlternar: aoAlternarFavorita,
                  nomeDaUnidade: nome,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          _Linha(
            child: minutos == null
                ? const _SemEstimativa()
                : Wrap(
                    spacing: NexaSpacing.sm,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(textoDaEspera(minutos), style: NexaText.waitBand),
                      NexaEsperaChip(nivel: nivel),
                    ],
                  ),
          ),
          if (detalhes.isNotEmpty) ...[
            const SizedBox(height: NexaSpacing.sm),
            _Linha(
              child: Text(
                detalhes.join(' · '),
                style: NexaText.small.copyWith(color: NexaColors.inkSoft),
              ),
            ),
          ],
          if (frase != null) ...[
            const SizedBox(height: NexaSpacing.sm),
            _Linha(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  const NexaIcon('walk', size: 18),
                  Expanded(child: Text(frase, style: NexaText.small)),
                ],
              ),
            ),
          ],
          const SizedBox(height: NexaSpacing.md),
        ],
      ),
    );
  }
}

/// Cartão de unidade enquanto a lista carrega: quatro blocos que pulsam, com
/// a mesma altura aproximada do cartão de verdade (150 px).
class NexaUnidadeCardCarregando extends StatelessWidget {
  const NexaUnidadeCardCarregando({super.key});

  @override
  Widget build(BuildContext context) {
    return const NexaCartao(
      child: Padding(
        padding: EdgeInsets.all(NexaSpacing.md),
        // `infinity` faz o cartão ocupar a largura toda, mesmo com blocos
        // mais estreitos dentro.
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: NexaSpacing.sm,
            children: [
              NexaSkeleton(altura: 20, largura: 120),
              NexaSkeleton(altura: 28, largura: 180),
              NexaSkeleton(altura: 18, largura: 240),
              NexaSkeleton(altura: 14, largura: 140),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dá a uma linha do cartão a margem lateral de 16 px.
class _Linha extends StatelessWidget {
  const _Linha({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NexaSpacing.md),
      child: child,
    );
  }
}

/// O selo verde-claro "Menor espera perto de você".
class _Selo extends StatelessWidget {
  const _Selo();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: NexaColors.cream,
        borderRadius: BorderRadius.circular(NexaRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 4, 10, 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            const NexaIcon('seal_check', size: 16, color: NexaColors.greenDark),
            Flexible(
              child: Text(
                'Menor espera perto de você',
                style: NexaText.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: NexaColors.greenDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// O que aparece no lugar do tempo quando o Java não mandou o número.
class _SemEstimativa extends StatelessWidget {
  const _SemEstimativa();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 3.5,
      children: [
        Text(
          'Estimativa indisponível',
          style: NexaText.section.copyWith(color: NexaColors.inkSoft),
        ),
        const NexaEsperaChip(nivel: NivelEspera.semDados),
      ],
    );
  }
}

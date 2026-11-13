import 'dart:async';

import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/features/unidades/data/acoes_unidade.dart';
import 'package:fe_nexa_app/features/unidades/data/favoritas_repository.dart';
import 'package:fe_nexa_app/features/unidades/data/unidade_resumo.dart';
import 'package:fe_nexa_app/features/unidades/nexa_folha_espera.dart';
import 'package:fe_nexa_app/features/unidades/nexa_linha_info.dart';
import 'package:fe_nexa_app/shared/utils/espera.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_app_bar.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_button.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_cartao.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_espera_chip.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_favorito_button.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_snackbar.dart';
import 'package:flutter/material.dart';

/// Abre o detalhe de [unidade] por cima da tela atual.
Future<void> abrirDetalheDaUnidade(
  BuildContext context,
  UnidadeResumo unidade, {
  FavoritasRepository? favoritas,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => UnidadeDetalhePage(unidade: unidade, favoritas: favoritas),
    ),
  );
}

/// Detalhe de uma unidade: espera estimada, endereço, distância, "Ao chegar" e
/// os botões "Como chegar" e "Compartilhar".
///
/// Tudo vem do [UnidadeResumo] que o cartão já tinha: não há chamada extra ao
/// Java. O que o Java ainda não manda não aparece, e a tela nunca inventa dado:
/// faixa mínima e máxima da espera, "atualizado há", pessoas aguardando e
/// telefone.
///
/// Os parâmetros opcionais existem para os testes e a galeria passarem versões
/// falsas; sem passar nada, a tela usa as reais.
class UnidadeDetalhePage extends StatefulWidget {
  const UnidadeDetalhePage({
    super.key,
    required this.unidade,
    this.favoritas,
    this.acoes,
  });

  final UnidadeResumo unidade;
  final FavoritasRepository? favoritas;
  final AcoesUnidade? acoes;

  @override
  State<UnidadeDetalhePage> createState() => _UnidadeDetalhePageState();
}

class _UnidadeDetalhePageState extends State<UnidadeDetalhePage> {
  FavoritasRepository get _repoFavoritas =>
      widget.favoritas ?? favoritasRepository;
  AcoesUnidade get _acoes => widget.acoes ?? acoesUnidade;

  UnidadeResumo get _unidade => widget.unidade;

  Future<void> _alternarFavorita() async {
    final vaiFavoritar = !_repoFavoritas.ids.value.contains(_unidade.id);
    try {
      await _repoFavoritas.definir(_unidade.id, favorita: vaiFavoritar);
    } on FavoritaNaoSalva {
      if (!mounted) return;
      NexaSnackbar.erro(
        context,
        'Não consegui salvar a favorita. Tente de novo.',
      );
    }
  }

  Future<void> _comoChegar() async {
    final destino = _unidade.enderecoParaRota ?? _unidade.nome;
    var abriu = false;
    try {
      abriu = await _acoes.abrirRota(destino);
    } catch (_) {
      abriu = false;
    }
    if (!abriu && mounted) {
      NexaSnackbar.erro(context, 'Não consegui abrir o mapa neste aparelho.');
    }
  }

  Future<void> _compartilhar() async {
    try {
      await _acoes.compartilhar(_textoParaCompartilhar());
    } catch (_) {
      if (!mounted) return;
      NexaSnackbar.erro(context, 'Não consegui compartilhar agora.');
    }
  }

  String _textoParaCompartilhar() {
    final endereco = _unidade.endereco;
    final espera = _unidade.tempoEspera;
    final destino = _unidade.enderecoParaRota;
    return [
      _unidade.nome,
      ?endereco,
      if (espera != null) 'Espera estimada: ${textoDaEspera(espera)}',
      if (destino != null) 'Como chegar: ${linkDaRota(destino)}',
    ].join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final endereco = _unidade.endereco;
    final distancia = _unidade.distanciaKm;
    final linhas = [
      if (endereco != null)
        (icone: 'pin', rotulo: 'Endereço', valor: endereco),
      if (distancia != null)
        (
          icone: 'navigation',
          rotulo: 'Distância',
          valor: '${textoDaDistancia(distancia)} de você',
        ),
    ];

    return Scaffold(
      backgroundColor: NexaColors.background,
      appBar: NexaAppBar(
        title: _unidade.nome,
        acoes: [
          ValueListenableBuilder<Set<int>>(
            valueListenable: _repoFavoritas.ids,
            builder: (context, favoritas, _) => NexaFavoritoButton(
              favorita: favoritas.contains(_unidade.id),
              aoAlternar: _alternarFavorita,
              nomeDaUnidade: _unidade.nome,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          NexaSpacing.md,
          NexaSpacing.xs,
          NexaSpacing.md,
          NexaSpacing.md,
        ),
        children: [
          _CartaoDeEspera(tempoEspera: _unidade.tempoEspera),
          if (linhas.isNotEmpty) ...[
            const SizedBox(height: NexaSpacing.sm),
            NexaCartao(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: NexaSpacing.md,
                  vertical: 4,
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < linhas.length; i++)
                      NexaLinhaInfo(
                        iconName: linhas[i].icone,
                        rotulo: linhas[i].rotulo,
                        valor: linhas[i].valor,
                        mostrarDivisor: i < linhas.length - 1,
                      ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: NexaSpacing.sm),
          const _AoChegar(),
        ],
      ),
      bottomNavigationBar: _BarraDeAcoes(
        aoComoChegar: () => unawaited(_comoChegar()),
        aoCompartilhar: () => unawaited(_compartilhar()),
      ),
    );
  }
}

/// O bloco verde-claro do alto: espera estimada, selo da faixa e aviso da
/// triagem.
class _CartaoDeEspera extends StatelessWidget {
  const _CartaoDeEspera({required this.tempoEspera});

  final double? tempoEspera;

  @override
  Widget build(BuildContext context) {
    final minutos = tempoEspera;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: NexaColors.cream,
        borderRadius: BorderRadius.circular(NexaRadius.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(NexaSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Espera estimada',
              style: NexaText.small.copyWith(color: NexaColors.inkSoft),
            ),
            const SizedBox(height: 10),
            Text(
              minutos == null
                  ? 'Estimativa indisponível'
                  : textoCurtoDaEspera(minutos),
              style: minutos == null
                  ? NexaText.title.copyWith(color: NexaColors.inkSoft)
                  : NexaText.bigNumber.copyWith(letterSpacing: -1.32),
            ),
            const SizedBox(height: 10),
            NexaEsperaChip(nivel: nivelDaEspera(minutos)),
            const SizedBox(height: NexaSpacing.sm),
            const Divider(height: 1, thickness: 1, color: NexaColors.lime),
            const SizedBox(height: NexaSpacing.sm),
            const Text(
              'A triagem define a ordem de atendimento. Por isso a sua espera '
              'pode ser maior ou menor.',
              style: NexaText.small,
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: NexaButton(
                label: 'Como calculamos?',
                iconName: 'help',
                variant: NexaButtonVariant.link,
                onPressed: () => unawaited(mostrarFolhaEspera(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Ao chegar": os três passos de quem chega à unidade.
class _AoChegar extends StatelessWidget {
  const _AoChegar();

  @override
  Widget build(BuildContext context) {
    return const NexaCartao(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          NexaSpacing.md,
          NexaSpacing.md,
          NexaSpacing.md,
          NexaSpacing.xs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ao chegar', style: NexaText.section),
            _Passo(
              iconName: 'user_check',
              numero: 1,
              texto: 'Faça o check-in no totem',
            ),
            _Passo(iconName: 'ticket', numero: 2, texto: 'Receba sua senha'),
            _Passo(
              iconName: 'monitor',
              numero: 3,
              texto: 'Acompanhe a chamada no painel',
            ),
          ],
        ),
      ),
    );
  }
}

class _Passo extends StatelessWidget {
  const _Passo({
    required this.iconName,
    required this.numero,
    required this.texto,
  });

  final String iconName;
  final int numero;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          spacing: NexaSpacing.sm,
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                color: NexaColors.primrose,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(
                dimension: 44,
                child: Center(child: NexaIcon(iconName)),
              ),
            ),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$numero.',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: ' $texto'),
                  ],
                ),
                style: NexaText.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A barra fixa de baixo: "Como chegar" e "Compartilhar".
class _BarraDeAcoes extends StatelessWidget {
  const _BarraDeAcoes({
    required this.aoComoChegar,
    required this.aoCompartilhar,
  });

  final VoidCallback aoComoChegar;
  final VoidCallback aoCompartilhar;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: NexaColors.white,
        border: Border(top: BorderSide(color: NexaColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(NexaSpacing.sm).copyWith(
            left: NexaSpacing.md,
            right: NexaSpacing.md,
          ),
          child: Row(
            spacing: NexaSpacing.sm,
            children: [
              Expanded(
                child: NexaButton(
                  label: 'Como chegar',
                  iconName: 'navigation',
                  onPressed: aoComoChegar,
                ),
              ),
              Expanded(
                child: NexaButton(
                  label: 'Compartilhar',
                  iconName: 'share',
                  variant: NexaButtonVariant.outline,
                  onPressed: aoCompartilhar,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

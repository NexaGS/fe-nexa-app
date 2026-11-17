import 'dart:async';

import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/features/unidades/data/acoes_unidade.dart';
import 'package:fe_nexa_app/features/unidades/data/favoritas_repository.dart';
import 'package:fe_nexa_app/features/unidades/data/unidade_resumo.dart';
import 'package:fe_nexa_app/features/unidades/data/unidades_repository.dart';
import 'package:fe_nexa_app/features/unidades/nexa_linha_info.dart';
import 'package:fe_nexa_app/features/unidades/widgets/ao_chegar.dart';
import 'package:fe_nexa_app/features/unidades/widgets/barra_de_acoes.dart';
import 'package:fe_nexa_app/features/unidades/widgets/cartao_de_espera.dart';
import 'package:fe_nexa_app/shared/utils/atualizador_periodico.dart';
import 'package:fe_nexa_app/shared/utils/espera.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_app_bar.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_cartao.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_favorito_button.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_snackbar.dart';
import 'package:flutter/material.dart';

/// Abre o detalhe de [unidade] por cima da tela atual.
Future<void> abrirDetalheDaUnidade(
  BuildContext context,
  UnidadeResumo unidade, {
  FavoritasRepository? favoritas,
  UnidadesRepository? unidades,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => UnidadeDetalhePage(
        unidade: unidade,
        favoritas: favoritas,
        unidades: unidades,
      ),
    ),
  );
}

/// Detalhe de uma unidade: espera estimada, endereço, distância, "Ao chegar" e
/// os botões "Como chegar" e "Compartilhar".
class UnidadeDetalhePage extends StatefulWidget {
  const UnidadeDetalhePage({
    super.key,
    required this.unidade,
    this.favoritas,
    this.acoes,
    this.unidades,
  });

  final UnidadeResumo unidade;
  final FavoritasRepository? favoritas;
  final AcoesUnidade? acoes;
  final UnidadesRepository? unidades;

  @override
  State<UnidadeDetalhePage> createState() => _UnidadeDetalhePageState();
}

class _UnidadeDetalhePageState extends State<UnidadeDetalhePage> {
  FavoritasRepository get _repoFavoritas =>
      widget.favoritas ?? favoritasRepository;
  UnidadesRepository get _repoUnidades => widget.unidades ?? unidadesRepository;
  AcoesUnidade get _acoes => widget.acoes ?? acoesUnidade;

  UnidadeResumo get _unidade => widget.unidade;

  // Só a espera muda com o tempo. A distância vem da Home e fica como está,
  // porque `/{id}` não manda `distanciaKm`.
  late double? _tempoEspera = widget.unidade.tempoEspera;

  late final AtualizadorPeriodico _atualizador = AtualizadorPeriodico(
    nome: 'Detalhe',
    atualizar: _atualizarEspera,
  );

  @override
  void initState() {
    super.initState();
    _atualizador.iniciar();
  }

  @override
  void dispose() {
    _atualizador.parar();
    super.dispose();
  }

  Future<void> _atualizarEspera() async {
    final atual = await _repoUnidades.porId(widget.unidade.id);
    if (!mounted) return;
    setState(() => _tempoEspera = atual.tempoEspera ?? _tempoEspera);
  }

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
    final espera = _tempoEspera;
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
          CartaoDeEspera(tempoEspera: _tempoEspera),
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
          const AoChegar(),
        ],
      ),
      bottomNavigationBar: BarraDeAcoes(
        aoComoChegar: () => unawaited(_comoChegar()),
        aoCompartilhar: () => unawaited(_compartilhar()),
      ),
    );
  }
}

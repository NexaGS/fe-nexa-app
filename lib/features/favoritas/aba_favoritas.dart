import 'dart:async';

import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/features/auth/data/auth_repository.dart'
    show ErroInesperado, SemConexao;
import 'package:fe_nexa_app/features/favoritas/data/favoritas_conta_repository.dart';
import 'package:fe_nexa_app/features/home/data/localizacao_service.dart';
import 'package:fe_nexa_app/features/unidades/data/favoritas_repository.dart';
import 'package:fe_nexa_app/features/unidades/data/unidade_resumo.dart';
import 'package:fe_nexa_app/features/unidades/nexa_unidade_card.dart';
import 'package:fe_nexa_app/features/unidades/unidade_detalhe_page.dart';
import 'package:fe_nexa_app/shared/utils/espera.dart';
import 'package:fe_nexa_app/shared/widgets/guia_view.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_banner.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_estado_vazio.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_samu_button.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_snackbar.dart';
import 'package:flutter/material.dart';

enum _Falha { servidor, semConexao }

const double _espacoEntreCartoes = NexaSpacing.sm;

class AbaFavoritas extends StatefulWidget {
  const AbaFavoritas({
    super.key,
    this.temConta = false,
    this.aoVerUnidades,
    this.aoCriarConta,
    this.favoritas,
    this.lista,
    this.localizacao,
  });

  final bool temConta;

  final VoidCallback? aoVerUnidades;

  final VoidCallback? aoCriarConta;

  final FavoritasRepository? favoritas;
  final FavoritasLista? lista;
  final LocalizacaoService? localizacao;

  @override
  State<AbaFavoritas> createState() => _AbaFavoritasState();
}

class _AbaFavoritasState extends State<AbaFavoritas> {
  FavoritasRepository get _repoFavoritas =>
      widget.favoritas ?? favoritasRepository;
  FavoritasLista get _repoLista => widget.lista ?? favoritasDaConta;
  LocalizacaoService get _repoGps => widget.localizacao ?? localizacaoService;

  List<UnidadeResumo>? _todas;
  bool _carregando = true;
  _Falha? _falha;

  @override
  void initState() {
    super.initState();
    _repoFavoritas.ids.addListener(_favoritasMudaram);
    unawaited(_iniciar());
  }

  @override
  void dispose() {
    _repoFavoritas.ids.removeListener(_favoritasMudaram);
    super.dispose();
  }

  Future<void> _iniciar() async {
    try {
      await _repoFavoritas.carregar();
    } catch (_) {
    }
    await _carregarUnidades();
  }

  final _buscandoNovas = <int>{};

  void _favoritasMudaram() {
    final todas = _todas;
    if (!mounted || todas == null || _carregando) return;
    final conhecidas = {for (final unidade in todas) unidade.id};
    final novas = [
      for (final id in _repoFavoritas.ids.value)
        if (!conhecidas.contains(id) && !_buscandoNovas.contains(id)) id,
    ];
    if (novas.isNotEmpty) unawaited(_buscarNovas(novas));
  }

  Future<void> _buscarNovas(List<int> ids) async {
    _buscandoNovas.addAll(ids);
    try {
      final achadas = await Future.wait([
        for (final id in ids) _repoLista.carregarUnidade(id),
      ]);
      if (!mounted) return;
      final novas = achadas.whereType<UnidadeResumo>().toList();
      if (novas.isEmpty) return;
      setState(() {
        final jaTem = {for (final unidade in _todas ?? const []) unidade.id};
        _todas = [
          ...?_todas,
          for (final unidade in novas)
            if (!jaTem.contains(unidade.id)) unidade,
        ];
      });
    } catch (_) {
    } finally {
      _buscandoNovas.removeAll(ids);
    }
  }

  Future<Posicao?> _posicaoOpcional() async {
    if (!widget.temConta) return null;
    try {
      return await _repoGps.posicaoAtual();
    } catch (_) {
      return null;
    }
  }

  Future<void> _carregarUnidades({bool silencioso = false}) async {
    final posicao = await _posicaoOpcional();
    try {
      final lista = await _repoLista.carregarUnidades(
        latitude: posicao?.latitude,
        longitude: posicao?.longitude,
      );
      if (!mounted) return;
      setState(() {
        _todas = lista;
        _falha = null;
        _carregando = false;
      });
    } on SemConexao {
      _falhou(_Falha.semConexao, silencioso: silencioso);
    } on ErroInesperado {
      _falhou(_Falha.servidor, silencioso: silencioso);
    }
  }

  void _falhou(_Falha falha, {required bool silencioso}) {
    if (!mounted) return;
    final temLista = _todas != null;
    setState(() {
      _carregando = false;
      if (!temLista) _falha = falha;
    });
    if (temLista && !silencioso) {
      NexaSnackbar.erro(context, 'Não consegui atualizar agora.');
    }
  }

  Future<void> _recarregar({bool silencioso = false}) async {
    if (_carregando) return;
    if (!silencioso && _todas == null) {
      setState(() {
        _carregando = true;
        _falha = null;
      });
    }
    await _carregarUnidades(silencioso: silencioso);
  }

  Future<void> _remover(UnidadeResumo unidade) async {
    try {
      await _repoFavoritas.definir(unidade.id, favorita: false);
    } on FavoritaNaoSalva {
      if (!mounted) return;
      NexaSnackbar.erro(context, 'Não consegui remover. Tente de novo.');
      return;
    }
    if (!mounted) return;
    NexaSnackbar.desfazer(
      context,
      'Unidade removida das favoritas',
      aoDesfazer: () => unawaited(_desfazer(unidade)),
    );
  }

  Future<void> _desfazer(UnidadeResumo unidade) async {
    try {
      await _repoFavoritas.definir(unidade.id, favorita: true);
    } on FavoritaNaoSalva {
      if (!mounted) return;
      NexaSnackbar.erro(context, 'Não consegui desfazer. Tente de novo.');
    }
  }

  List<UnidadeResumo> _exibidas(Set<int> ids) {
    final lista = [
      for (final unidade in _todas ?? const <UnidadeResumo>[])
        if (ids.contains(unidade.id)) unidade,
    ];
    lista.sort((a, b) {
      final esperaA = a.tempoEspera;
      final esperaB = b.tempoEspera;
      if (esperaA != null && esperaB != null && esperaA != esperaB) {
        return esperaA.compareTo(esperaB);
      }
      if (esperaA == null && esperaB != null) return 1;
      if (esperaA != null && esperaB == null) return -1;
      return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
    });
    return lista;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: _repoFavoritas.ids,
      builder: (context, ids, _) {
        final carregada = _todas != null;
        final unidades = _exibidas(ids);

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Cabecalho(quantidade: carregada ? unidades.length : null),
              if (carregada && unidades.isNotEmpty) _aviso(unidades),
              Expanded(child: _conteudo(unidades)),
            ],
          ),
        );
      },
    );
  }

  Widget _aviso(List<UnidadeResumo> unidades) {
    final criarConta = widget.aoCriarConta;
    if (!widget.temConta) {
      if (criarConta == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: NexaSpacing.xs),
        child: NexaBanner(
          tom: NexaBannerTom.informativo,
          mensagem:
              'Suas favoritas estão só neste aparelho. Crie uma conta para '
              'não perdê-las.',
          rotuloAcao: 'Criar conta',
          aoAcionar: criarConta,
          acaoEmBotao: true,
        ),
      );
    }

    final comEspera = unidades.where((u) => u.tempoEspera != null).toList();
    if (unidades.length < 2 || comEspera.isEmpty) {
      return const SizedBox.shrink();
    }
    final menor = comEspera.first;
    return Padding(
      padding: const EdgeInsets.only(top: NexaSpacing.xs),
      child: _BannerMenorEspera(
        nome: menor.nome,
        espera: textoCurtoDaEspera(menor.tempoEspera!),
      ),
    );
  }

  Widget _conteudo(List<UnidadeResumo> unidades) {
    if (_todas == null) {
      final falha = _falha;
      if (_carregando || falha == null) return const _ListaCarregando();
      return switch (falha) {
        _Falha.semConexao => _estado(
          mood: GuiaMood.erro,
          rotuloDoGuia: 'Guia do Nexa preocupado',
          titulo: 'Sem conexão com a internet',
          texto: 'Confira sua internet e tente de novo.',
          rotuloAcao: 'Tentar de novo',
          iconeAcao: 'refresh',
          aoAcionar: _recarregar,
        ),
        _Falha.servidor => _estado(
          mood: GuiaMood.erro,
          rotuloDoGuia: 'Guia do Nexa preocupado',
          titulo: 'Algo deu errado do nosso lado',
          texto:
              'Não conseguimos carregar suas favoritas agora. Isso não é '
              'culpa sua. Tente de novo em instantes.',
          rotuloAcao: 'Tentar de novo',
          iconeAcao: 'refresh',
          aoAcionar: _recarregar,
        ),
      };
    }

    if (unidades.isEmpty) {
      final verUnidades = widget.aoVerUnidades;
      return _estado(
        mood: GuiaMood.vazio,
        rotuloDoGuia: 'Guia do Nexa procurando',
        titulo: 'Você ainda não tem favoritas',
        texto: 'Toque no coração de uma unidade para guardá-la aqui.',
        rotuloAcao: verUnidades == null ? null : 'Ver unidades próximas',
        iconeAcao: 'home',
        aoAcionar: verUnidades,
      );
    }

    return RefreshIndicator(
      onRefresh: _recarregar,
      color: NexaColors.green,
      backgroundColor: NexaColors.white,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          top: NexaSpacing.sm,
          bottom: NexaSpacing.md,
        ),
        itemCount: unidades.length,
        separatorBuilder: (_, _) => const SizedBox(height: _espacoEntreCartoes),
        itemBuilder: (context, indice) {
          final unidade = unidades[indice];
          return NexaUnidadeCard(
            key: ValueKey(unidade.id),
            nome: unidade.nome,
            tempoEspera: unidade.tempoEspera,
            favorita: true,
            aoAlternarFavorita: () => unawaited(_remover(unidade)),
            aoTocar: () => unawaited(
              abrirDetalheDaUnidade(
                context,
                unidade,
                favoritas: _repoFavoritas,
              ),
            ),
            detalhes: unidade.detalhes,
          );
        },
      ),
    );
  }

  Widget _estado({
    required GuiaMood mood,
    required String rotuloDoGuia,
    required String titulo,
    required String texto,
    required String? rotuloAcao,
    required String iconeAcao,
    required VoidCallback? aoAcionar,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        NexaSpacing.xs,
        48,
        NexaSpacing.xs,
        NexaSpacing.md,
      ),
      child: NexaEstadoVazio(
        mood: mood,
        rotuloDoGuia: rotuloDoGuia,
        titulo: titulo,
        texto: texto,
        rotuloAcao: rotuloAcao,
        iconeAcao: iconeAcao,
        aoAcionar: aoAcionar,
      ),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.quantidade});

  final int? quantidade;

  @override
  Widget build(BuildContext context) {
    final total = quantidade;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 40),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Favoritas', style: NexaText.title),
                if (total != null)
                  Text(
                    total == 1 ? '1 unidade' : '$total unidades',
                    style: NexaText.small.copyWith(color: NexaColors.inkSoft),
                  ),
              ],
            ),
          ),
          const SizedBox(width: NexaSpacing.sm),
          const NexaSamuButton(),
        ],
      ),
    );
  }
}

class _BannerMenorEspera extends StatelessWidget {
  const _BannerMenorEspera({required this.nome, required this.espera});

  final String nome;
  final String espera;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: NexaColors.cream,
            borderRadius: BorderRadius.circular(NexaRadius.banner),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: NexaSpacing.md,
              vertical: NexaSpacing.sm,
            ),
            child: Row(
              spacing: NexaSpacing.sm,
              children: [
                const NexaIcon('bolt', size: 24),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: NexaText.small,
                      children: [
                        const TextSpan(
                          text: 'A menor espera entre as suas favoritas agora:\n',
                        ),
                        TextSpan(
                          text: '$nome, $espera',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ListaCarregando extends StatelessWidget {
  const _ListaCarregando();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: NexaSpacing.sm),
      children: const [
        NexaUnidadeCardCarregando(),
        SizedBox(height: _espacoEntreCartoes),
        NexaUnidadeCardCarregando(),
        SizedBox(height: _espacoEntreCartoes),
        NexaUnidadeCardCarregando(),
      ],
    );
  }
}

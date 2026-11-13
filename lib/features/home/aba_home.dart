import 'dart:async';

import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/features/auth/data/auth_repository.dart'
    show ErroInesperado, SemConexao;
import 'package:fe_nexa_app/features/home/data/local_repository.dart';
import 'package:fe_nexa_app/features/home/data/localizacao_service.dart';
import 'package:fe_nexa_app/features/unidades/data/favoritas_repository.dart';
import 'package:fe_nexa_app/features/unidades/data/unidade_resumo.dart';
import 'package:fe_nexa_app/features/unidades/data/unidades_repository.dart';
import 'package:fe_nexa_app/features/unidades/nexa_unidade_card.dart';
import 'package:fe_nexa_app/features/unidades/unidade_detalhe_page.dart';
import 'package:fe_nexa_app/shared/utils/tempo.dart';
import 'package:fe_nexa_app/shared/widgets/guia_view.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_banner.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_estado_vazio.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_local_atual.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_saudacao.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_snackbar.dart';
import 'package:flutter/material.dart';

/// Por que a lista de unidades não carregou.
enum _Falha { servidor, semConexao }

/// Espaço entre os cartões da lista, como no Figma.
const double _espacoEntreCartoes = 14;

/// Aba Home: saudação, local atual e a lista das unidades mais próximas.
class AbaHome extends StatefulWidget {
  const AbaHome({
    super.key,
    this.nome,
    this.aoVerTodasAsUnidades,
    this.localizacao,
    this.locais,
    this.unidades,
    this.favoritas,
    this.agora,
  });

  /// Nome da pessoa para a saudação. Nulo = visitante.
  final String? nome;

  /// Leva a pessoa para a aba Buscar, onde estão todas as unidades. Aparece nos
  /// estados "nenhuma unidade perto" e "sem GPS". Nulo = a tela só avisa.
  final VoidCallback? aoVerTodasAsUnidades;

  final LocalizacaoService? localizacao;
  final LocalRepository? locais;
  final UnidadesRepository? unidades;
  final FavoritasRepository? favoritas;

  /// O relógio da tela, para o "há 12 min". Nulo = a hora do celular.
  final DateTime Function()? agora;

  @override
  State<AbaHome> createState() => _AbaHomeState();
}

class _AbaHomeState extends State<AbaHome> with WidgetsBindingObserver {
  LocalizacaoService get _repoGps => widget.localizacao ?? localizacaoService;
  LocalRepository get _repoLocais => widget.locais ?? localRepository;
  UnidadesRepository get _repoUnidades => widget.unidades ?? unidadesRepository;
  FavoritasRepository get _repoFavoritas =>
      widget.favoritas ?? favoritasRepository;
  DateTime _agora() => (widget.agora ?? DateTime.now)();

  bool _buscandoLocal = true;
  String? _local;
  Posicao? _posicao;
  bool _semPosicao = false;

  String? _aviso;
  String _rotuloAviso = 'Tentar de novo';
  VoidCallback? _acaoDoAviso;

  // Nulo = ainda não chegou lista nenhuma. Depois de chegar, fica guardada
  // mesmo que uma nova busca falhe: é o que a tela mostra "sem internet".
  List<UnidadeResumo>? _unidades;
  bool _carregandoUnidades = true;
  _Falha? _falha;
  DateTime? _atualizadoEm;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _carregarFavoritas();
    _iniciar();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Quando a pessoa volta dos ajustes do celular (ligou o GPS ou deu a
  /// permissão), tenta de novo sozinho. Só nesses casos: se fosse sempre, uma
  /// permissão negada pediria de novo em loop.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        !_buscandoLocal &&
        _acaoDoAviso != null) {
      _recarregar();
    }
  }

  Future<void> _carregarFavoritas() async {
    try {
      await _repoFavoritas.carregar();
    } catch (_) {
      // Sem conseguir ler as favoritas, a lista funciona igual: os corações
      // só aparecem vazios.
    }
  }

  /// Primeira carga: GPS, depois local e unidades.
  Future<void> _iniciar() async {
    final posicao = await _obterPosicao();
    if (!mounted || posicao == null) return;
    _posicao = posicao;
    await _buscarPara(posicao);
  }

  /// A posição do GPS, ou nulo depois de mostrar na tela por que não deu.
  Future<Posicao?> _obterPosicao() async {
    try {
      return await _repoGps.posicaoAtual();
    } on GpsDesligado {
      _semLocalizacao(
        'GPS desligado. Ative a localização do celular.',
        rotulo: 'Ativar GPS',
        acao: _repoGps.abrirAjustesDoGps,
      );
    } on PermissaoNegada {
      _semLocalizacao('Sem permissão de localização.');
    } on PermissaoNegadaParaSempre {
      _semLocalizacao(
        'Permita a localização nos ajustes do app.',
        rotulo: 'Abrir ajustes',
        acao: _repoGps.abrirAjustesDoApp,
      );
    } on PosicaoIndisponivel {
      _semLocalizacao('Não consegui pegar sua localização agora.');
    }
    return null;
  }

  void _semLocalizacao(
    String mensagem, {
    String rotulo = 'Tentar de novo',
    VoidCallback? acao,
  }) {
    if (!mounted) return;
    setState(() {
      _aviso = mensagem;
      _rotuloAviso = rotulo;
      _acaoDoAviso = acao;
      _semPosicao = true;
      _buscandoLocal = false;
      _carregandoUnidades = false;
    });
  }

  /// Com a posição na mão, pede o nome do local (se ainda não tem) e as
  /// unidades ao mesmo tempo.
  Future<void> _buscarPara(Posicao posicao) async {
    await Future.wait([
      if (_local == null) _descreverLocal(posicao),
      _carregarUnidades(posicao),
    ]);
  }

  Future<void> _descreverLocal(Posicao posicao) async {
    try {
      final local = await _repoLocais.descrever(posicao);
      if (!mounted) return;
      setState(() {
        _local = local.rotulo;
        _aviso = null;
        _acaoDoAviso = null;
        _buscandoLocal = false;
      });
    } on SemConexao {
      _falhaDoLocal('Sem conexão com o servidor.');
    } on ErroInesperado {
      _falhaDoLocal('Não consegui identificar o local.');
    }
  }

  void _falhaDoLocal(String mensagem) {
    if (!mounted) return;
    setState(() {
      _aviso = mensagem;
      _rotuloAviso = 'Tentar de novo';
      _acaoDoAviso = null;
      _buscandoLocal = false;
    });
  }

  Future<void> _carregarUnidades(Posicao posicao) async {
    try {
      final lista = await _repoUnidades.proximas(
        latitude: posicao.latitude,
        longitude: posicao.longitude,
      );
      if (!mounted) return;
      setState(() {
        _unidades = lista;
        _atualizadoEm = _agora();
        _falha = null;
        _carregandoUnidades = false;
      });
    } on SemConexao {
      _unidadesFalharam(_Falha.semConexao);
    } on ErroInesperado {
      _unidadesFalharam(_Falha.servidor);
    }
  }

  void _unidadesFalharam(_Falha falha) {
    if (!mounted) return;
    setState(() {
      _falha = falha;
      _carregandoUnidades = false;
    });
  }

  /// "Tentar de novo" e puxar a lista para baixo. Devolve o [Future] para o
  /// círculo do `RefreshIndicator` saber quando parar de girar.
  Future<void> _recarregar() async {
    if (_carregandoUnidades || _buscandoLocal) return;

    setState(() {
      _aviso = null;
      _acaoDoAviso = null;
      _semPosicao = false;
      _carregandoUnidades = true;
      _buscandoLocal = _local == null;
      // Com unidades na tela, o aviso de "dados antigos" fica até chegar a
      // resposta (não pisca). Sem unidades, volta o esqueleto.
      if (_unidades == null) _falha = null;
    });

    final posicao = _posicao;
    if (posicao == null) {
      await _iniciar();
    } else {
      await _buscarPara(posicao);
    }
  }

  void _verTodasAsUnidades() {
    final ir = widget.aoVerTodasAsUnidades;
    if (ir == null) {
      NexaSnackbar.aviso(context, 'Funcionalidade indisponível no momento.');
      return;
    }
    ir();
  }

  Future<void> _alternarFavorita(UnidadeResumo unidade) async {
    final vaiFavoritar = !_repoFavoritas.ids.value.contains(unidade.id);
    try {
      await _repoFavoritas.definir(unidade.id, favorita: vaiFavoritar);
    } on FavoritaNaoSalva {
      if (!mounted) return;
      NexaSnackbar.erro(
        context,
        'Não consegui salvar a favorita. Tente de novo.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final temAviso = _aviso != null;
    final textoLocal = _buscandoLocal
        ? 'Buscando sua localização…'
        : (_aviso ?? _local ?? 'Local não identificado');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NexaSaudacao(nome: widget.nome),
          NexaLocalAtual(
            local: textoLocal,
            rotuloAcao: temAviso ? _rotuloAviso : 'Alterar',
            aoAlterar: temAviso ? (_acaoDoAviso ?? _recarregar) : null,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              'Das mais próximas para as mais distantes',
              style: NexaText.small.copyWith(color: NexaColors.inkSoft),
            ),
          ),
          Expanded(child: _conteudo()),
          const _AvisoTriagem(),
        ],
      ),
    );
  }

  /// Escolhe o que ocupa o meio da tela, do mais específico para o mais geral.
  Widget _conteudo() {
    final unidades = _unidades;
    if (unidades != null) {
      return unidades.isEmpty ? _semUnidades() : _lista(unidades);
    }

    if (_semPosicao) return _semLocalizacaoNaTela();

    final falha = _falha;
    if (_carregandoUnidades || falha == null) return const _ListaCarregando();

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
            'Não conseguimos carregar as unidades agora. Isso não é culpa '
            'sua. Tente de novo em instantes.',
        rotuloAcao: 'Tentar de novo',
        iconeAcao: 'refresh',
        aoAcionar: _recarregar,
      ),
    };
  }

  Widget _semUnidades() => _estado(
    mood: GuiaMood.vazio,
    rotuloDoGuia: 'Guia do Nexa procurando',
    titulo: 'Não achamos unidades perto daqui',
    texto:
        'Não há unidades cadastradas perto de você. Veja todas as unidades na '
        'aba Buscar.',
    rotuloAcao: 'Ver todas as unidades',
    iconeAcao: 'search',
    aoAcionar: _verTodasAsUnidades,
  );

  /// Sem GPS não há "perto daqui": o caminho é ligar a localização ou olhar a
  /// lista de todas as unidades.
  Widget _semLocalizacaoNaTela() => _estado(
    mood: GuiaMood.vazio,
    rotuloDoGuia: 'Guia do Nexa procurando',
    titulo: 'Não sabemos onde você está',
    texto:
        'Ative a localização do celular para ver as unidades mais próximas, '
        'ou veja todas as unidades na aba Buscar.',
    rotuloAcao: 'Ver todas as unidades',
    iconeAcao: 'search',
    aoAcionar: _verTodasAsUnidades,
  );

  /// Guia, título, texto e botão no meio da área da lista. Rola se a letra
  /// estiver grande demais para caber.
  Widget _estado({
    required GuiaMood mood,
    required String rotuloDoGuia,
    required String titulo,
    required String texto,
    required String rotuloAcao,
    required String iconeAcao,
    required VoidCallback aoAcionar,
  }) {
    return Center(
      child: SingleChildScrollView(
        // 16 da tela + 8 = os 24 de margem do Figma.
        padding: const EdgeInsets.symmetric(horizontal: NexaSpacing.xs),
        child: NexaEstadoVazio(
          mood: mood,
          rotuloDoGuia: rotuloDoGuia,
          titulo: titulo,
          texto: texto,
          rotuloAcao: rotuloAcao,
          iconeAcao: iconeAcao,
          aoAcionar: aoAcionar,
        ),
      ),
    );
  }

  Widget _lista(List<UnidadeResumo> unidades) {
    final falha = _falha;
    final atualizadoEm = _atualizadoEm;
    // Só o espaço de cima usa este bool. O `if` abaixo repete a condição de
    // propósito: o Dart só promove `atualizadoEm` a não nulo dentro dele.
    final mostraAviso = falha != null && atualizadoEm != null;
    final indiceDoSelo = indiceDaMenorEspera(unidades);

    return Column(
      children: [
        if (falha != null && atualizadoEm != null)
          Padding(
            padding: const EdgeInsets.only(top: NexaSpacing.sm),
            child: NexaBanner(
              mensagem:
                  'Mostrando dados de '
                  '${textoHaQuantoTempo(_agora().difference(atualizadoEm))}',
              // O ícone padrão do banner é o de "sem internet": só serve
              // quando o problema é mesmo a conexão.
              iconName: falha == _Falha.servidor ? 'alert' : null,
              rotuloAcao: _carregandoUnidades ? null : 'Tentar de novo',
              aoAcionar: _carregandoUnidades ? null : _recarregar,
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _recarregar,
            color: NexaColors.green,
            backgroundColor: NexaColors.white,
            child: ValueListenableBuilder<Set<int>>(
              valueListenable: _repoFavoritas.ids,
              builder: (context, favoritas, _) {
                return ListView.separated(
                  // Sempre "rolável", senão o puxar-para-atualizar não
                  // funciona quando há poucas unidades.
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    top: mostraAviso ? NexaSpacing.sm : NexaSpacing.lg,
                    bottom: NexaSpacing.md,
                  ),
                  itemCount: unidades.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: _espacoEntreCartoes),
                  itemBuilder: (context, indice) {
                    final unidade = unidades[indice];
                    return NexaUnidadeCard(
                      key: ValueKey(unidade.id),
                      nome: unidade.nome,
                      tempoEspera: unidade.tempoEspera,
                      favorita: favoritas.contains(unidade.id),
                      aoAlternarFavorita: () => _alternarFavorita(unidade),
                      aoTocar: () => unawaited(
                        abrirDetalheDaUnidade(
                          context,
                          unidade,
                          favoritas: _repoFavoritas,
                        ),
                      ),
                      detalhes: unidade.detalhes,
                      menorEspera: indice == indiceDoSelo,
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// "Buscando unidades perto de você…" e três cartões esqueleto.
class _ListaCarregando extends StatelessWidget {
  const _ListaCarregando();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: NexaSpacing.lg),
      children: const [
        _BuscandoUnidades(),
        SizedBox(height: _espacoEntreCartoes),
        NexaUnidadeCardCarregando(),
        SizedBox(height: _espacoEntreCartoes),
        NexaUnidadeCardCarregando(),
        SizedBox(height: _espacoEntreCartoes),
        NexaUnidadeCardCarregando(),
      ],
    );
  }
}

class _BuscandoUnidades extends StatelessWidget {
  const _BuscandoUnidades();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Row(
        children: [
          const ExcludeSemantics(
            child: SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: NexaColors.green,
                backgroundColor: NexaColors.divider,
              ),
            ),
          ),
          const SizedBox(width: NexaSpacing.sm),
          Expanded(
            child: Text('Buscando unidades perto de você…', style: NexaText.small),
          ),
        ],
      ),
    );
  }
}

/// Rodapé fixo da Home, como no Figma: a espera é uma estimativa e não decide
/// quem é atendido primeiro.
class _AvisoTriagem extends StatelessWidget {
  const _AvisoTriagem();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: NexaSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: NexaIcon('info', size: 14, color: NexaColors.inkSoft),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Estimativas podem mudar. A prioridade é definida pela triagem.',
              style: NexaText.caption.copyWith(color: NexaColors.inkSoft),
            ),
          ),
        ],
      ),
    );
  }
}

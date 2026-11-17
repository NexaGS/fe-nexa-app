import 'dart:async';

import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/features/auth/data/auth_repository.dart'
    show ErroInesperado, SemConexao;
import 'package:fe_nexa_app/features/home/data/local_repository.dart';
import 'package:fe_nexa_app/features/home/data/localizacao_service.dart';
import 'package:fe_nexa_app/features/home/widgets/aviso_triagem.dart';
import 'package:fe_nexa_app/features/home/widgets/estado_home.dart';
import 'package:fe_nexa_app/features/home/widgets/falha_unidades.dart';
import 'package:fe_nexa_app/features/home/widgets/lista_carregando.dart';
import 'package:fe_nexa_app/features/home/widgets/lista_unidades.dart';
import 'package:fe_nexa_app/features/unidades/data/favoritas_repository.dart';
import 'package:fe_nexa_app/features/unidades/data/unidade_resumo.dart';
import 'package:fe_nexa_app/features/unidades/data/unidades_repository.dart';
import 'package:fe_nexa_app/shared/utils/atualizador_periodico.dart';
import 'package:fe_nexa_app/shared/widgets/guia_view.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_local_atual.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_saudacao.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_snackbar.dart';
import 'package:flutter/material.dart';

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
    this.ativa = true,
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

  /// A aba está na frente? Fora dela a atualização periódica pausa e, ao
  /// voltar, atualiza na hora.
  final bool ativa;

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

  late final AtualizadorPeriodico _atualizador = AtualizadorPeriodico(
    nome: 'Home',
    atualizar: _atualizarEmSilencio,
  );

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
  FalhaUnidades? _falha;
  DateTime? _atualizadoEm;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _carregarFavoritas();
    _iniciar();
    if (widget.ativa) _atualizador.iniciar();
  }

  @override
  void didUpdateWidget(AbaHome antigo) {
    super.didUpdateWidget(antigo);
    if (widget.ativa != antigo.ativa) _atualizador.definirAtivo(widget.ativa);
  }

  @override
  void dispose() {
    _atualizador.parar();
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
      _unidadesFalharam(FalhaUnidades.semConexao);
    } on ErroInesperado {
      _unidadesFalharam(FalhaUnidades.servidor);
    }
  }

  void _unidadesFalharam(FalhaUnidades falha) {
    if (!mounted) return;
    setState(() {
      _falha = falha;
      _carregandoUnidades = false;
    });
  }

  /// Atualização periódica: refaz a busca sem mexer na tela de carregando.
  Future<void> _atualizarEmSilencio() async {
    final posicao = _posicao;
    if (posicao == null || _carregandoUnidades || _buscandoLocal) return;
    await _carregarUnidades(posicao);
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
          const AvisoTriagem(),
        ],
      ),
    );
  }

  /// Escolhe o que ocupa o meio da tela, do mais específico para o mais geral.
  Widget _conteudo() {
    final unidades = _unidades;
    if (unidades != null) {
      return unidades.isEmpty
          ? _semUnidades()
          : ListaUnidades(
              unidades: unidades,
              favoritas: _repoFavoritas,
              carregando: _carregandoUnidades,
              aoRecarregar: _recarregar,
              aoAlternarFavorita: _alternarFavorita,
              agora: _agora,
              falha: _falha,
              atualizadoEm: _atualizadoEm,
            );
    }

    if (_semPosicao) return _semLocalizacaoNaTela();

    final falha = _falha;
    if (_carregandoUnidades || falha == null) return const ListaCarregando();

    return switch (falha) {
      FalhaUnidades.semConexao => EstadoHome(
        mood: GuiaMood.erro,
        rotuloDoGuia: 'Guia do Nexa preocupado',
        titulo: 'Sem conexão com a internet',
        texto: 'Confira sua internet e tente de novo.',
        rotuloAcao: 'Tentar de novo',
        iconeAcao: 'refresh',
        aoAcionar: _recarregar,
      ),
      FalhaUnidades.servidor => EstadoHome(
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

  Widget _semUnidades() => EstadoHome(
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
  Widget _semLocalizacaoNaTela() => EstadoHome(
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
}

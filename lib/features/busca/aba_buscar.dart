import 'dart:async';

import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/features/auth/data/auth_repository.dart'
    show ErroInesperado, SemConexao;
import 'package:fe_nexa_app/features/busca/data/catalogo_repository.dart';
import 'package:fe_nexa_app/features/busca/data/estados.dart';
import 'package:fe_nexa_app/features/busca/folha_estados.dart';
import 'package:fe_nexa_app/features/busca/nexa_campo_busca.dart';
import 'package:fe_nexa_app/features/busca/nexa_filtro_chip.dart';
import 'package:fe_nexa_app/features/unidades/data/favoritas_repository.dart';
import 'package:fe_nexa_app/features/unidades/data/unidade_resumo.dart';
import 'package:fe_nexa_app/features/unidades/nexa_unidade_card.dart';
import 'package:fe_nexa_app/features/unidades/unidade_detalhe_page.dart';
import 'package:fe_nexa_app/shared/widgets/guia_view.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_button.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_estado_vazio.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_samu_button.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_snackbar.dart';
import 'package:flutter/material.dart';

/// Por que a lista não carregou.
enum _Falha { servidor, semConexao }

/// Espaço entre os cartões da lista, como na Home.
const double _espacoEntreCartoes = 14;

/// Quando faltarem menos que isto (em pixels) para o fim da lista, pede a
/// próxima página. Assim ela chega antes de a pessoa bater no fim.
const double _distanciaParaCarregarMais = 600;

/// Aba Buscar: o catálogo de todas as unidades cadastradas.
///
/// Sem filtro, mostra todas, de todos os estados, em ordem alfabética, e vai
/// pedindo mais ao Java conforme a pessoa rola (paginação). Dois filtros:
/// - **nome**: o texto do campo, que o Java procura em qualquer parte do nome;
/// - **estado**: a sigla escolhida na folha "Filtrar por estado".
///
/// A busca por perto, com o GPS, é da Home. Aqui não há ponto de partida.
///
/// O repositório e as favoritas são opcionais no construtor: sem passar nada,
/// a tela usa os reais; os testes e a galeria passam versões falsas.
class AbaBuscar extends StatefulWidget {
  const AbaBuscar({
    super.key,
    this.catalogo,
    this.favoritas,
    this.tamanhoDaPagina = 10,
    this.atrasoDaDigitacao = const Duration(milliseconds: 400),
  });

  final CatalogoRepository? catalogo;
  final FavoritasRepository? favoritas;

  /// Quantas unidades pedir por vez.
  final int tamanhoDaPagina;

  /// Quanto esperar depois da última letra antes de buscar. Sem esperar, cada
  /// letra faria uma chamada ao Java.
  final Duration atrasoDaDigitacao;

  @override
  State<AbaBuscar> createState() => _AbaBuscarState();
}

class _AbaBuscarState extends State<AbaBuscar> {
  final _controller = TextEditingController();
  final _foco = FocusNode();
  final _rolagem = ScrollController();

  /// O relógio do "esperar a pessoa parar de digitar".
  Timer? _digitando;

  CatalogoRepository get _repo => widget.catalogo ?? catalogoRepository;
  FavoritasRepository get _repoFavoritas =>
      widget.favoritas ?? favoritasRepository;

  // --- Os filtros que estão valendo ---
  String _nome = '';

  /// Sigla do estado; vazia = todos.
  String _uf = '';

  // --- O que já chegou do Java ---
  List<UnidadeResumo> _itens = const [];
  int _total = 0;
  int _proximaPagina = 0;
  bool _ultima = false;

  // --- Em que momento a lista está ---
  bool _carregandoPrimeira = true;
  bool _carregandoMais = false;
  _Falha? _falhaPrimeira;
  bool _falhouAoCarregarMais = false;

  /// Número da busca atual. Cada busca nova (filtro mudou) soma 1. A resposta
  /// de uma busca velha, que chega depois, é jogada fora: sem isso, quem
  /// digita rápido veria a lista do texto antigo por cima da do texto novo.
  int _busca = 0;

  @override
  void initState() {
    super.initState();
    _rolagem.addListener(_aoRolar);
    unawaited(_repoFavoritas.carregar());
    unawaited(_carregarPrimeiraPagina());
  }

  @override
  void dispose() {
    _digitando?.cancel();
    _rolagem
      ..removeListener(_aoRolar)
      ..dispose();
    _foco.dispose();
    _controller.dispose();
    super.dispose();
  }

  // --- Carregar ---

  /// Zera a lista e busca a primeira página com os filtros de agora.
  void _recomecar() {
    setState(() {
      _itens = const [];
      _total = 0;
      _proximaPagina = 0;
      _ultima = false;
      _carregandoPrimeira = true;
      _carregandoMais = false;
      _falhaPrimeira = null;
      _falhouAoCarregarMais = false;
    });
    unawaited(_carregarPrimeiraPagina());
  }

  Future<void> _carregarPrimeiraPagina() async {
    final busca = ++_busca;
    try {
      final pagina = await _repo.pagina(
        nome: _nome,
        uf: _uf,
        pagina: 0,
        tamanho: widget.tamanhoDaPagina,
      );
      if (!mounted || busca != _busca) return;
      setState(() {
        _itens = pagina.unidades;
        _total = pagina.totalElementos;
        _proximaPagina = pagina.pagina + 1;
        _ultima = pagina.ultima;
        _carregandoPrimeira = false;
      });
      _verificarDepoisDoQuadro();
    } on SemConexao {
      _primeiraFalhou(busca, _Falha.semConexao);
    } on ErroInesperado {
      _primeiraFalhou(busca, _Falha.servidor);
    }
  }

  void _primeiraFalhou(int busca, _Falha falha) {
    if (!mounted || busca != _busca) return;
    setState(() {
      _falhaPrimeira = falha;
      _carregandoPrimeira = false;
    });
  }

  /// Pede a página seguinte e a coloca no fim da lista.
  Future<void> _carregarMais() async {
    if (_carregandoPrimeira ||
        _carregandoMais ||
        _ultima ||
        _falhaPrimeira != null) {
      return;
    }
    final busca = _busca;
    setState(() {
      _carregandoMais = true;
      _falhouAoCarregarMais = false;
    });
    try {
      final pagina = await _repo.pagina(
        nome: _nome,
        uf: _uf,
        pagina: _proximaPagina,
        tamanho: widget.tamanhoDaPagina,
      );
      if (!mounted || busca != _busca) return;
      setState(() {
        _itens = [..._itens, ...pagina.unidades];
        _total = pagina.totalElementos;
        _proximaPagina = pagina.pagina + 1;
        _ultima = pagina.ultima;
        _carregandoMais = false;
      });
      _verificarDepoisDoQuadro();
    } on SemConexao {
      _maisFalhou(busca);
    } on ErroInesperado {
      _maisFalhou(busca);
    }
  }

  void _maisFalhou(int busca) {
    if (!mounted || busca != _busca) return;
    setState(() {
      _carregandoMais = false;
      _falhouAoCarregarMais = true;
    });
  }

  // --- Rolagem ---

  void _aoRolar() {
    if (_falhouAoCarregarMais || !_rolagem.hasClients) return;
    if (_rolagem.position.extentAfter < _distanciaParaCarregarMais) {
      unawaited(_carregarMais());
    }
  }

  /// Depois que uma página entra, a lista pode continuar curta demais para
  /// rolar (letra pequena, tela alta). Sem rolagem, `_aoRolar` nunca dispara e a
  /// segunda página nunca viria. Esperar o quadro seguinte deixa a lista nova
  /// ser medida antes da conta.
  void _verificarDepoisDoQuadro() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _aoRolar();
    });
  }

  // --- Ações ---

  void _aoMudarTexto(String texto) {
    _digitando?.cancel();
    _digitando = Timer(widget.atrasoDaDigitacao, () => _aplicarNome(texto));
  }

  void _aoEnviarTexto(String texto) {
    _digitando?.cancel();
    _aplicarNome(texto);
    // Fecha o teclado para o resultado aparecer inteiro.
    _foco.unfocus();
  }

  void _aplicarNome(String texto) {
    if (!mounted) return;
    final novo = texto.trim();
    if (novo == _nome) return;
    _nome = novo;
    _recomecar();
  }

  Future<void> _escolherEstado() async {
    _foco.unfocus();
    final escolhida = await escolherEstado(context, siglaAtual: _uf);
    // `null` = fechou sem escolher; igual ao que já vale = nada a refazer.
    if (!mounted || escolhida == null || escolhida == _uf) return;
    _uf = escolhida;
    _recomecar();
  }

  void _limparFiltros() {
    _digitando?.cancel();
    _controller.clear();
    _nome = '';
    _uf = '';
    _recomecar();
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

  // --- Desenho ---

  @override
  Widget build(BuildContext context) {
    final nomeDoEstadoAtual = nomeDoEstado(_uf);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Cabecalho(),
          const SizedBox(height: NexaSpacing.sm),
          NexaCampoBusca(
            controller: _controller,
            focusNode: _foco,
            hint: 'Buscar unidade pelo nome',
            aoMudar: _aoMudarTexto,
            aoEnviar: _aoEnviarTexto,
          ),
          const SizedBox(height: NexaSpacing.sm),
          NexaFiltroChip(
            rotulo: _uf.isEmpty ? 'Estado: Todos' : 'Estado: $_uf',
            rotuloSemantico: nomeDoEstadoAtual == null
                ? 'Filtrar por estado. Mostrando todos os estados'
                : 'Filtrar por estado. Mostrando $nomeDoEstadoAtual',
            ativo: _uf.isNotEmpty,
            aoTocar: () => unawaited(_escolherEstado()),
          ),
          if (!_carregandoPrimeira && _falhaPrimeira == null)
            Padding(
              padding: const EdgeInsets.only(top: NexaSpacing.xs),
              child: _Contagem(total: _total),
            ),
          Expanded(child: _conteudo()),
        ],
      ),
    );
  }

  /// Escolhe o que ocupa o meio da tela.
  Widget _conteudo() {
    if (_carregandoPrimeira) return const _ListaCarregando();

    final falha = _falhaPrimeira;
    if (falha != null) {
      return switch (falha) {
        _Falha.semConexao => _estado(
          mood: GuiaMood.erro,
          rotuloDoGuia: 'Guia do Nexa preocupado',
          titulo: 'Sem conexão com a internet',
          texto: 'Confira sua internet e tente de novo.',
          rotuloAcao: 'Tentar de novo',
          iconeAcao: 'refresh',
          aoAcionar: _recomecar,
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
          aoAcionar: _recomecar,
        ),
      };
    }

    if (_itens.isEmpty) return _semResultado();
    return _lista();
  }

  Widget _semResultado() {
    final comFiltro = _nome.isNotEmpty || _uf.isNotEmpty;
    return _estado(
      mood: GuiaMood.vazio,
      rotuloDoGuia: 'Guia do Nexa procurando',
      titulo: comFiltro ? 'Nenhuma unidade encontrada' : 'Ainda não há unidades',
      texto: comFiltro
          ? 'Tente outro nome ou veja as unidades de todos os estados.'
          : 'Quando houver unidades cadastradas, elas aparecem aqui.',
      rotuloAcao: comFiltro ? 'Limpar filtros' : null,
      iconeAcao: 'close',
      aoAcionar: comFiltro ? _limparFiltros : null,
    );
  }

  /// Guia, título, texto e botão (opcional) no meio da área da lista. Rola se a
  /// letra estiver grande demais para caber.
  Widget _estado({
    required GuiaMood mood,
    required String rotuloDoGuia,
    required String titulo,
    required String texto,
    String? rotuloAcao,
    String? iconeAcao,
    VoidCallback? aoAcionar,
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

  Widget _lista() {
    // Escuta as favoritas: tocar no coração (aqui ou em outra aba) redesenha só
    // a lista, sem pedir nada ao Java.
    return ValueListenableBuilder<Set<int>>(
      valueListenable: _repoFavoritas.ids,
      builder: (context, favoritas, _) {
        // Uma linha a mais no fim da lista: o "carregando mais" ou o erro.
        final temRodape = _carregandoMais || _falhouAoCarregarMais;

        return ListView.separated(
          controller: _rolagem,
          // Arrastar a lista fecha o teclado.
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(
            top: NexaSpacing.sm,
            bottom: NexaSpacing.md,
          ),
          itemCount: _itens.length + (temRodape ? 1 : 0),
          separatorBuilder: (_, _) =>
              const SizedBox(height: _espacoEntreCartoes),
          itemBuilder: (context, indice) {
            if (indice == _itens.length) {
              return _falhouAoCarregarMais
                  ? _FalhaAoCarregarMais(
                      aoTentarDeNovo: () => unawaited(_carregarMais()),
                    )
                  : const _CarregandoMais();
            }
            final unidade = _itens[indice];
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
              detalhes: unidade.detalhesComCidade,
            );
          },
        );
      },
    );
  }
}

/// "Buscar" à esquerda e o botão SAMU à direita, como no Figma.
class _Cabecalho extends StatelessWidget {
  const _Cabecalho();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                'Buscar',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: NexaText.title,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const NexaSamuButton(),
        ],
      ),
    );
  }
}

/// "12 unidades · em ordem alfabética".
class _Contagem extends StatelessWidget {
  const _Contagem({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final quantas = total == 1 ? '1 unidade' : '$total unidades';
    // `liveRegion`: o leitor de tela lê de novo quando o número muda.
    return Semantics(
      liveRegion: true,
      child: Text(
        '$quantas · em ordem alfabética',
        style: NexaText.small.copyWith(color: NexaColors.inkSoft),
      ),
    );
  }
}

/// "Buscando unidades…" e três cartões esqueleto.
class _ListaCarregando extends StatelessWidget {
  const _ListaCarregando();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: NexaSpacing.lg),
      children: const [
        _MensagemComRoda(texto: 'Buscando unidades…'),
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

/// A linha do fim da lista enquanto a próxima página chega.
class _CarregandoMais extends StatelessWidget {
  const _CarregandoMais();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: NexaSpacing.sm),
      child: _MensagemComRoda(texto: 'Carregando mais unidades…'),
    );
  }
}

/// Roda girando e um texto. O leitor de tela lê o texto quando ele aparece.
class _MensagemComRoda extends StatelessWidget {
  const _MensagemComRoda({required this.texto});

  final String texto;

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
          Expanded(child: Text(texto, style: NexaText.small)),
        ],
      ),
    );
  }
}

/// O fim da lista quando a página seguinte falhou: a lista de cima fica como
/// está e um botão tenta de novo só essa página.
class _FalhaAoCarregarMais extends StatelessWidget {
  const _FalhaAoCarregarMais({required this.aoTentarDeNovo});

  final VoidCallback aoTentarDeNovo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: NexaSpacing.xs),
      child: Row(
        children: [
          const NexaIcon('wifi_off', size: 20, color: NexaColors.inkSoft),
          const SizedBox(width: NexaSpacing.sm),
          Expanded(
            child: Text(
              'Não deu para carregar mais unidades.',
              style: NexaText.small.copyWith(color: NexaColors.inkSoft),
            ),
          ),
          NexaButton(
            label: 'Tentar de novo',
            variant: NexaButtonVariant.link,
            onPressed: aoTentarDeNovo,
          ),
        ],
      ),
    );
  }
}

import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/features/auth/data/auth_repository.dart'
    show ErroInesperado, SemConexao;
import 'package:fe_nexa_app/features/home/data/local_repository.dart';
import 'package:fe_nexa_app/features/home/data/localizacao_service.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_local_atual.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_snackbar.dart';
import 'package:flutter/material.dart';

import '../../shared/widgets/nexa_bottom_nav.dart';
import '../../shared/widgets/nexa_saudacao.dart';

/// Tela provisória: ainda não há conteúdo depois do login.
/// Quem entra com conta e quem segue como visitante chegam aqui.
///

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.nome});

  final String? nome;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _aba = 0;

  @override
  Widget build(BuildContext context) {
    final abas = [
      _AbaHome(nome: widget.nome),
      const _AbaProvisoria('Buscar'),
      const _AbaProvisoria('Favoritas'),
      const _AbaProvisoria('Perfil'),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false, // a barra de baixo já cuida da área de gestos
        child: IndexedStack(index: _aba, children: abas),
      ),
      bottomNavigationBar: NexaBottomNav(
        indiceAtual: _aba,
        aoSelecionar: (indice) => setState(() => _aba = indice),
      ),
    );
  }
}



/// Aba Home: saudação, local atual e (próxima etapa) a lista de unidades.
class _AbaHome extends StatefulWidget {
  const _AbaHome({required this.nome});

  final String? nome;

  @override
  State<_AbaHome> createState() => _AbaHomeState();
}

class _AbaHomeState extends State<_AbaHome> with WidgetsBindingObserver {
  bool _buscandoLocal = true;
  String? _local; // "Bela Vista, São Paulo"

  // Quando algo falha, no lugar do local aparece um aviso e um link de ação.
  String? _aviso;
  String _rotuloAviso = 'Tentar de novo';
  VoidCallback? _acaoDoAviso; // se nulo, a ação é tentar de novo

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _carregarLocal();
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
      _tentarDeNovo();
    }
  }

  Future<void> _carregarLocal() async {
    try {
      final posicao = await localizacaoService.posicaoAtual();
      final local = await localRepository.descrever(posicao);
      if (!mounted) return;
      setState(() => _local = local.rotulo);
    } on GpsDesligado {
      _falhou(
        'GPS desligado. Ative a localização do celular.',
        rotulo: 'Ativar GPS',
        acao: localizacaoService.abrirAjustesDoGps,
      );
    } on PermissaoNegada {
      _falhou('Sem permissão de localização.');
    } on PermissaoNegadaParaSempre {
      _falhou(
        'Permita a localização nos ajustes do app.',
        rotulo: 'Abrir ajustes',
        acao: localizacaoService.abrirAjustesDoApp,
      );
    } on PosicaoIndisponivel {
      _falhou('Não consegui pegar sua localização agora.');
    } on SemConexao {
      _falhou('Sem conexão com o servidor.');
    } on ErroInesperado {
      _falhou('Não consegui identificar o local.');
    } finally {
      if (mounted) setState(() => _buscandoLocal = false);
    }
  }

  void _falhou(
    String mensagem, {
    String rotulo = 'Tentar de novo',
    VoidCallback? acao,
  }) {
    if (!mounted) return;
    setState(() {
      _aviso = mensagem;
      _rotuloAviso = rotulo;
      _acaoDoAviso = acao;
    });
  }

  void _tentarDeNovo() {
    setState(() {
      _buscandoLocal = true;
      _aviso = null;
      _acaoDoAviso = null;
      _local = null;
    });
    _carregarLocal();
  }

  void _alterarLocal() {
    NexaSnackbar.aviso(context, 'Funcionalidade indisponível no momento.');
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
            aoAlterar: temAviso ? (_acaoDoAviso ?? _tentarDeNovo) : _alterarLocal,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              'Da menor para a maior espera',
              style: NexaText.small.copyWith(color: NexaColors.inkSoft),
            ),
          ),
          const Expanded(
            child: Center(child: Text('Lista de unidades: próxima etapa')),
          ),
        ],
      ),
    );
  }
}

/// Texto no meio da tela, para as abas que ainda não existem.
class _AbaProvisoria extends StatelessWidget {
  const _AbaProvisoria(this.titulo);

  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(titulo, style: NexaText.title));
  }
}

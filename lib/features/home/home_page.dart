import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/features/auth/data/auth_repository.dart';
import 'package:fe_nexa_app/features/busca/aba_buscar.dart';
import 'package:fe_nexa_app/features/favoritas/aba_favoritas.dart';
import 'package:fe_nexa_app/features/home/aba_home.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_bottom_nav.dart';
import 'package:flutter/material.dart';

/// A casca do app depois do login: o conteúdo de cada aba e a barra de baixo.
/// Quem entra com conta e quem segue como visitante chegam aqui.
class HomePage extends StatefulWidget {
  const HomePage({super.key, this.sessao});

  /// Quem está logado. Nulo = visitante.
  final Sessao? sessao;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Posição de "Buscar" em [NexaBottomNav].
  static const _abaHome = 0;
  static const _abaBuscar = 1;
  static const _abaFavoritas = 2;

  int _aba = 0;

  @override
  Widget build(BuildContext context) {
    final abas = [
      AbaHome(
        nome: widget.sessao?.nome,
        ativa: _aba == _abaHome,
        aoVerTodasAsUnidades: () => setState(() => _aba = _abaBuscar),
      ),
      AbaBuscar(ativa: _aba == _abaBuscar),
      AbaFavoritas(
        temConta: widget.sessao != null,
        ativa: _aba == _abaFavoritas,
        aoVerUnidades: () => setState(() => _aba = _abaHome),
        aoCriarConta: () =>
            Navigator.of(context).popUntil((rota) => rota.isFirst),
      ),
      const _AbaProvisoria('Perfil'),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _aba, children: abas),
      ),
      bottomNavigationBar: NexaBottomNav(
        indiceAtual: _aba,
        aoSelecionar: (indice) => setState(() => _aba = indice),
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

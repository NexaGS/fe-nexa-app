import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/features/busca/aba_buscar.dart';
import 'package:fe_nexa_app/features/home/aba_home.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_bottom_nav.dart';
import 'package:flutter/material.dart';

/// A casca do app depois do login: o conteúdo de cada aba e a barra de baixo.
/// Quem entra com conta e quem segue como visitante chegam aqui.
///
/// Só as abas Home e Buscar têm conteúdo por enquanto; as outras são provisórias.
class HomePage extends StatefulWidget {
  const HomePage({super.key, this.nome});

  final String? nome;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Posição de "Buscar" em [NexaBottomNav].
  static const _abaBuscar = 1;

  int _aba = 0;

  @override
  Widget build(BuildContext context) {
    final abas = [
      AbaHome(
        nome: widget.nome,
        aoVerTodasAsUnidades: () => setState(() => _aba = _abaBuscar),
      ),
      const AbaBuscar(),
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

/// Texto no meio da tela, para as abas que ainda não existem.
class _AbaProvisoria extends StatelessWidget {
  const _AbaProvisoria(this.titulo);

  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(titulo, style: NexaText.title));
  }
}

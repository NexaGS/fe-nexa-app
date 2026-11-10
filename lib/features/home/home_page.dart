import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:flutter/material.dart';

import '../../shared/widgets/nexa_bottom_nav.dart';

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



/// Aba Home. Por enquanto só um texto; vira o cabeçalho + a lista.
class _AbaHome extends StatelessWidget {
  const _AbaHome({required this.nome});

  final String? nome;

  @override
  Widget build(BuildContext context) {
    return const _AbaProvisoria('Home');
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

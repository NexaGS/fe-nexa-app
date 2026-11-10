import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:flutter/material.dart';

/// Tela provisória: ainda não há conteúdo depois do login.
/// Quem entra com conta e quem segue como visitante chegam aqui.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text('Home', style: NexaText.title),
        ),
      ),
    );
  }
}

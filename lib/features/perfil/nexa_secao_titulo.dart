import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:flutter/material.dart';

/// Título de um bloco do Perfil ("Minha busca", "Privacidade", "Sobre").
///
/// Marca o texto como cabeçalho para o leitor de tela pular de bloco em bloco.
class NexaSecaoTitulo extends StatelessWidget {
  const NexaSecaoTitulo(this.titulo, {super.key});

  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(titulo, style: NexaText.section),
    );
  }
}

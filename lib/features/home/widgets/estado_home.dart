import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/shared/widgets/guia_view.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_estado_vazio.dart';
import 'package:flutter/material.dart';

/// Guia, título, texto e botão no meio da área da lista. Rola se a letra
/// estiver grande demais para caber.
class EstadoHome extends StatelessWidget {
  const EstadoHome({
    super.key,
    required this.mood,
    required this.rotuloDoGuia,
    required this.titulo,
    required this.texto,
    required this.rotuloAcao,
    required this.iconeAcao,
    required this.aoAcionar,
  });

  final GuiaMood mood;
  final String rotuloDoGuia;
  final String titulo;
  final String texto;
  final String rotuloAcao;
  final String iconeAcao;
  final VoidCallback aoAcionar;

  @override
  Widget build(BuildContext context) {
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
}

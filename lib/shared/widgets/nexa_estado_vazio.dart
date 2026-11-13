import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/shared/widgets/guia_view.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_button.dart';
import 'package:flutter/material.dart';

/// Tela de "nada para mostrar": o Guia, um título, um texto e um botão.
class NexaEstadoVazio extends StatelessWidget {
  const NexaEstadoVazio({
    super.key,
    required this.mood,
    required this.titulo,
    required this.texto,
    this.rotuloAcao,
    this.iconeAcao,
    this.aoAcionar,
    this.rotuloDoGuia = 'Guia do Nexa',
  });

  /// Qual momento do Guia aparece (erro, vazio...).
  final GuiaMood mood;
  final String titulo;
  final String texto;

  /// O botão só aparece se [rotuloAcao] e [aoAcionar] forem informados.
  final String? rotuloAcao;
  final String? iconeAcao;
  final VoidCallback? aoAcionar;

  /// O que o leitor de tela diz no lugar do desenho.
  final String rotuloDoGuia;

  @override
  Widget build(BuildContext context) {
    final rotulo = rotuloAcao;
    final acao = aoAcionar;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: GuiaView(mood: mood, semanticLabel: rotuloDoGuia, size: 160),
        ),
        const SizedBox(height: 24),
        Text(titulo, textAlign: TextAlign.center, style: NexaText.title),
        const SizedBox(height: 12),
        Text(
          texto,
          textAlign: TextAlign.center,
          style: NexaText.body.copyWith(color: NexaColors.inkSoft),
        ),
        if (rotulo != null && acao != null) ...[
          const SizedBox(height: 24),
          NexaButton(label: rotulo, iconName: iconeAcao, onPressed: acao),
        ],
      ],
    );
  }
}

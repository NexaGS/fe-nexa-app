import 'package:flutter/material.dart';

/// Paleta Porcelana do Nexa, copiada do Figma.
abstract final class NexaColors {
  // Texto, bordas e fundos neutros
  static const ink = Color(0xFF151C18); // texto principal
  static const inkSoft = Color(0xFF566159); // texto secundário
  static const outline = Color(0xFF78857D); // borda de campos e botão contorno
  static const background = Color(0xFFF6F7F3); // fundo das telas
  static const cardBorder = Color(0xFFEEF0E9); // borda de cartões
  static const divider = Color(0xFFE1E5DC); // linhas divisórias
  static const white = Color(0xFFFFFFFF);
  static const scrim = Color(0x80151C18); // fundo escurecido atrás de diálogos

  // Marca
  static const lime = Color(0xFFB7D36B); // botão primário
  static const primrose = Color(0xFFDDEFA4); // item ativo do menu, avatar
  static const cream = Color(0xFFEEF6D5); // fundo suave (Coconut Cream)
  static const peach = Color(0xFFFFE6D3); // acento do Guia

  // Estados e indicadores
  static const green = Color(0xFF3F6B10);
  static const greenDark = Color(0xFF2F4F10);
  static const orange = Color(0xFF92400E);
  static const red = Color(0xFFB42318); // erro
  static const slate = Color(0xFF4F646B); // neutro / sem dado
  static const slateSurface = Color(0xFFEEF2F3); // fundo do slate
  static const info = Color(0xFF1D5FA8); // aviso informativo
  static const infoSurface = Color(0xFFE3F0FB); // fundo do aviso informativo
}

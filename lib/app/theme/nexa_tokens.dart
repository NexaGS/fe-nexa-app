import 'package:flutter/material.dart';

/// Raios de borda. Valores do Figma.
abstract final class NexaRadius {
  /// Botões e chips: totalmente arredondados. (Para formas, prefira
  /// `StadiumBorder()`; este número serve para `BorderRadius.circular`.)
  static const double pill = 999;

  /// Cartões de unidade.
  static const double card = 20;

  /// Campos de texto.
  static const double input = 16;

  /// Diálogos.
  static const double dialog = 28;
}

/// Espaçamentos que se repetem no Figma: 8, 12, 16, 20 e 24.
abstract final class NexaSpacing {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;

  /// Margem lateral padrão das telas.
  static const double screenPadding = 24;
}

/// Tamanhos fixos de componentes. Valores do Figma.
abstract final class NexaSizes {
  /// Altura de botões primário e contorno.
  static const double buttonHeight = 52;

  /// Altura do botão de texto.
  static const double textButtonHeight = 48;

  /// Altura de campos de texto.
  static const double inputHeight = 52;

  /// Altura da barra de navegação inferior.
  static const double bottomNavHeight = 80;

  /// Pílula do item ativo da barra de navegação (largura x altura).
  static const double navPillWidth = 64;
  static const double navPillHeight = 32;

  /// Menor área de toque aceitável (acessibilidade).
  static const double minTouchTarget = 44;

  /// Botão de coração (favoritar).
  static const double heartButton = 48;

  /// Símbolo da logo.
  static const double logoMark = 36;

  /// Tamanho padrão do Guia nas telas.
  static const double guia = 220;
}

/// Sombras. Valores do Figma.
abstract final class NexaShadows {
  /// Sombra leve dos cartões: 0 1px 1.5px com a tinta a 6%.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0F151C18),
      offset: Offset(0, 1),
      blurRadius: 1.5,
    ),
  ];
}

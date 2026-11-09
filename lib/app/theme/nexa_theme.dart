import 'package:flutter/material.dart';
import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';

/// Tema Porcelana do Nexa.
///
/// Diz ao Material (o conjunto de widgets padrão do Flutter) qual é o fundo,
/// a cor principal, a fonte e os estilos de texto do app. Widgets feitos à
/// mão continuam usando `NexaColors` e `NexaText` diretamente.
ThemeData buildNexaTheme() {
  return ThemeData(
    fontFamily: 'Figtree',
    scaffoldBackgroundColor: NexaColors.background,
    colorScheme: const ColorScheme.light(
      primary: NexaColors.lime,
      onPrimary: NexaColors.ink,
      surface: NexaColors.background,
      onSurface: NexaColors.ink,
      error: NexaColors.red,
    ),
    textTheme: const TextTheme(
      headlineMedium: NexaText.display,
      titleLarge: NexaText.title,
      bodyLarge: NexaText.body,
      bodyMedium: NexaText.body,
      bodySmall: NexaText.caption,
      labelLarge: NexaText.bodyStrong,
    ),
  );
}

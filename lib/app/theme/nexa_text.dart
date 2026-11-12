import 'package:flutter/material.dart';
import 'package:fe_nexa_app/app/theme/nexa_colors.dart';

/// Estilos de texto do Nexa (fonte Figtree), copiados do Figma.
///
/// No Flutter, `height` é um multiplicador do tamanho da fonte. Uma linha de
/// 34 px com fonte de 28 px vira `height: 34 / 28`.
///
/// Todos os estilos usam a cor de texto principal. Para outra cor, use
/// `copyWith`, por exemplo:
/// `NexaText.body.copyWith(color: NexaColors.inkSoft)`.
abstract final class NexaText {
  static const _family = 'Figtree';

  /// Título de abertura (tela Início). 28/34, Bold.
  static const display = TextStyle(
    fontFamily: _family,
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.56,
    color: NexaColors.ink,
  );

  /// Título de tela e de seção. 22/28, SemiBold.
  static const title = TextStyle(
    fontFamily: _family,
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w600,
    color: NexaColors.ink,
  );

  /// Título de bloco dentro de uma tela (Perfil: "Minha busca"). 18/24, SemiBold.
  static const section = TextStyle(
    fontFamily: _family,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
    color: NexaColors.ink,
  );

  /// Faixa de tempo de espera nos cartões. 22/28, SemiBold, tracking -0,22.
  static const waitBand = TextStyle(
    fontFamily: _family,
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.22,
    color: NexaColors.ink,
  );

  /// Número grande do detalhe da unidade. 44/48, Bold.
  static const bigNumber = TextStyle(
    fontFamily: _family,
    fontSize: 44,
    height: 48 / 44,
    fontWeight: FontWeight.w700,
    color: NexaColors.ink,
  );

  /// Texto corrido. 16/24, Regular.
  static const body = TextStyle(
    fontFamily: _family,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    color: NexaColors.ink,
  );

  /// Texto de peso médio, como o nome do local no cabeçalho. 16/24, Medium.
  static const bodyMedium = TextStyle(
    fontFamily: _family,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w500,
    color: NexaColors.ink,
  );

  /// Rótulo de botão e destaque em texto corrido. 16/24, SemiBold.
  static const bodyStrong = TextStyle(
    fontFamily: _family,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w600,
    color: NexaColors.ink,
  );

  /// Texto pequeno. 14/20, Regular.
  static const small = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: NexaColors.ink,
  );

  /// Texto pequeno em destaque, links. 14/20, SemiBold.
  static const smallStrong = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
    color: NexaColors.ink,
  );

  /// Legendas e avisos. 12/16, Regular.
  static const caption = TextStyle(
    fontFamily: _family,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
    color: NexaColors.ink,
  );

  /// A palavra "Nexa" ao lado da logo. 21/21, Bold, tracking -0,63.
  static const wordmark = TextStyle(
    fontFamily: _family,
    fontSize: 21,
    height: 1,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.63,
    color: NexaColors.ink,
  );
}

import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:flutter/material.dart';

/// Ajustes da abertura animada do Nexa. Mexeu aqui? Pare o app e rode de novo
/// (hot reload não pega constantes `const`).
abstract final class SplashConfig {
  /// COR DE FUNDO DO COMEÇO DA ABERTURA (antes da íris clara se abrir).
  /// É só trocar esta linha para testar. Exemplos:
  ///   NexaColors.green      verde da marca (atual)
  ///   NexaColors.greenDark  verde mais fechado
  ///   Color(0xFF1E5A4A)     verde-azulado
  static const Color corInicial = NexaColors.green;

  /// Cor do pulso, do radar e do anel da íris.
  static const Color corRadar = NexaColors.lime;

  /// Cor da marca enquanto o radar a desenha (sobre [corInicial]). Se trocar o
  /// fundo por uma cor clara, troque esta por uma escura.
  static const Color corMarca = NexaColors.background;

  /// Cor da tela que aparece depois da íris.
  static const Color corFinal = NexaColors.background;

  /// 1.0 = velocidade normal. 0.5 = câmera lenta, boa para testar.
  static const double velocidade = 1.0;

  /// `false` pula a abertura e vai direto ao Início/Home.
  static const bool ativa = true;
}

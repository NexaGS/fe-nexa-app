import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

/// Os momentos em que o Guia pode aparecer. Cada um sabe qual animação
/// tocar e qual pose parada mostrar quando o celular pede menos movimento.
enum GuiaMood {
  boasVindas('boas_vindas', 'neutro', repeat: true),
  carregando('carregando', 'esperando', repeat: true),
  vazio('vazio', 'procurando', repeat: true),
  erro('erro', 'preocupado', repeat: false),
  sucesso('sucesso', 'alegre', repeat: false);

  const GuiaMood(this.animation, this.pose, {required this.repeat});

  final String animation;
  final String pose;
  final bool repeat;

  String get lottiePath => 'assets/guia/lottie/$animation.json';
  String get posePath => 'assets/guia/poses/$pose.svg';
}

class GuiaView extends StatelessWidget {
  const GuiaView({
    super.key,
    required this.mood,
    required this.semanticLabel,
    this.size = 320,
  });

  final GuiaMood mood;

  /// O que o leitor de tela diz no lugar do desenho.
  final String semanticLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      label: semanticLabel,
      image: true,
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: size,
          child: reduceMotion
              ? SvgPicture.asset(mood.posePath)
              : Lottie.asset(mood.lottiePath, repeat: mood.repeat),
        ),
      ),
    );
  }
}
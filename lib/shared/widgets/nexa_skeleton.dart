import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:flutter/material.dart';

/// Bloco cinza que pulsa enquanto o conteúdo carrega.
///
/// Se o celular pede menos movimento (`MediaQuery.disableAnimationsOf`), o
/// bloco fica parado. Precisa ser `StatefulWidget` porque guarda o relógio da
/// animação ([AnimationController]).
class NexaSkeleton extends StatefulWidget {
  const NexaSkeleton({super.key, required this.altura, this.largura});

  final double altura;

  /// Nulo faz o bloco ocupar toda a largura disponível.
  final double? largura;

  @override
  State<NexaSkeleton> createState() => _NexaSkeletonState();
}

class _NexaSkeletonState extends State<NexaSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _relogio = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  // O bloco vai de 100% a 45% de opacidade e volta.
  late final Animation<double> _opacidade = Tween<double>(begin: 1, end: 0.45)
      .animate(CurvedAnimation(parent: _relogio, curve: Curves.easeInOut));

  /// Roda toda vez que o sistema muda a preferência de movimento.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _relogio.stop();
      _relogio.value = 0;
    } else if (!_relogio.isAnimating) {
      _relogio.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _relogio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Desenho decorativo: o leitor de tela lê o aviso "Buscando…" da tela.
    return ExcludeSemantics(
      child: FadeTransition(
        opacity: _opacidade,
        child: Container(
          width: widget.largura,
          height: widget.altura,
          decoration: BoxDecoration(
            color: NexaColors.cardBorder,
            borderRadius: BorderRadius.circular(NexaRadius.skeleton),
          ),
        ),
      ),
    );
  }
}

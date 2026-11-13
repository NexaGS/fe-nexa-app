import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:flutter/material.dart';

/// Bloco cinza que pulsa enquanto o conteúdo carrega.
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

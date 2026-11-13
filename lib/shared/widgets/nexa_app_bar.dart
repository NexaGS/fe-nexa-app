import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:flutter/material.dart';

/// Barra de cima das telas internas: seta de voltar e título.
/// Implementa [PreferredSizeWidget] porque o `Scaffold` precisa saber a altura
/// da barra antes de desenhá-la.
class NexaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NexaAppBar({super.key, required this.title, this.acoes});

  final String title;

  /// Widgets no canto direito, como o coração de favoritar.
  final List<Widget>? acoes;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: NexaColors.background,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      leading: IconButton(
        tooltip: 'Voltar',
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const NexaIcon('back'),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: NexaText.title,
      ),
      actions: acoes,
    );
  }
}
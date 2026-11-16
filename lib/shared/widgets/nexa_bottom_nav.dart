import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:flutter/material.dart';

import '../../app/theme/nexa_colors.dart';
import '../../app/theme/nexa_text.dart';

class NexaBottomNav extends StatelessWidget {
  const NexaBottomNav({
    super.key,
    required this.indiceAtual,
    required this.aoSelecionar,
  });

  final int indiceAtual;
  final ValueChanged<int> aoSelecionar;

  static const _destinos = [
    (rotulo: 'Home', icone: 'home', iconeAtivo: 'home'),
    (rotulo: 'Buscar', icone: 'search', iconeAtivo: 'search'),
    (rotulo: 'Favoritas', icone: 'heart', iconeAtivo: 'heart_filled'),
    (rotulo: 'Perfil', icone: 'user', iconeAtivo: 'user'),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: NexaColors.divider)),
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: NexaSizes.bottomNavHeight,
          backgroundColor: NexaColors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          indicatorColor: NexaColors.primrose,
          labelTextStyle: WidgetStateProperty.resolveWith((estados) {
            final ativa = estados.contains(WidgetState.selected);
            return NexaText.caption.copyWith(
              fontWeight: ativa ? FontWeight.w700 : FontWeight.w500,
              color: ativa ? NexaColors.ink : NexaColors.inkSoft,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: indiceAtual,
          onDestinationSelected: aoSelecionar,
          destinations: [
            for (final destino in _destinos)
              NavigationDestination(
                icon: NexaIcon(destino.icone, color: NexaColors.inkSoft,),
                selectedIcon: NexaIcon(destino.iconeAtivo),
                label: destino.rotulo,
              )
          ],
        ),
      ),
    );
  }
}
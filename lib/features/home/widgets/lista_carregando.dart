import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/features/unidades/nexa_unidade_card.dart';
import 'package:flutter/material.dart';

/// Espaço entre os cartões da lista, como no Figma.
const double espacoEntreCartoes = 14;

/// "Buscando unidades perto de você…" e três cartões esqueleto.
class ListaCarregando extends StatelessWidget {
  const ListaCarregando({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: NexaSpacing.lg),
      children: const [
        _BuscandoUnidades(),
        SizedBox(height: espacoEntreCartoes),
        NexaUnidadeCardCarregando(),
        SizedBox(height: espacoEntreCartoes),
        NexaUnidadeCardCarregando(),
        SizedBox(height: espacoEntreCartoes),
        NexaUnidadeCardCarregando(),
      ],
    );
  }
}

class _BuscandoUnidades extends StatelessWidget {
  const _BuscandoUnidades();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Row(
        children: [
          const ExcludeSemantics(
            child: SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: NexaColors.green,
                backgroundColor: NexaColors.divider,
              ),
            ),
          ),
          const SizedBox(width: NexaSpacing.sm),
          Expanded(
            child: Text('Buscando unidades perto de você…', style: NexaText.small),
          ),
        ],
      ),
    );
  }
}

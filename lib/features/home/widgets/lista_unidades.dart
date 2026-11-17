import 'dart:async';

import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/features/home/widgets/falha_unidades.dart';
import 'package:fe_nexa_app/features/home/widgets/lista_carregando.dart';
import 'package:fe_nexa_app/features/unidades/data/favoritas_repository.dart';
import 'package:fe_nexa_app/features/unidades/data/unidade_resumo.dart';
import 'package:fe_nexa_app/features/unidades/nexa_unidade_card.dart';
import 'package:fe_nexa_app/features/unidades/unidade_detalhe_page.dart';
import 'package:fe_nexa_app/shared/utils/tempo.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_banner.dart';
import 'package:flutter/material.dart';

/// Lista das unidades mais próximas, com aviso de "dados antigos" quando a
/// última busca falhou.
class ListaUnidades extends StatelessWidget {
  const ListaUnidades({
    super.key,
    required this.unidades,
    required this.favoritas,
    required this.carregando,
    required this.aoRecarregar,
    required this.aoAlternarFavorita,
    required this.agora,
    this.falha,
    this.atualizadoEm,
  });

  final List<UnidadeResumo> unidades;
  final FavoritasRepository favoritas;
  final bool carregando;
  final Future<void> Function() aoRecarregar;
  final void Function(UnidadeResumo unidade) aoAlternarFavorita;
  final DateTime Function() agora;
  final FalhaUnidades? falha;
  final DateTime? atualizadoEm;

  @override
  Widget build(BuildContext context) {
    final falha = this.falha;
    final atualizadoEm = this.atualizadoEm;
    // Só o espaço de cima usa este bool. O `if` abaixo repete a condição de
    // propósito: o Dart só promove `atualizadoEm` a não nulo dentro dele.
    final mostraAviso = falha != null && atualizadoEm != null;
    final indiceDoSelo = indiceDaMenorEspera(unidades);

    return Column(
      children: [
        if (falha != null && atualizadoEm != null)
          Padding(
            padding: const EdgeInsets.only(top: NexaSpacing.sm),
            child: NexaBanner(
              mensagem:
                  'Mostrando dados de '
                  '${textoHaQuantoTempo(agora().difference(atualizadoEm))}',
              // O ícone padrão do banner é o de "sem internet": só serve
              // quando o problema é mesmo a conexão.
              iconName: falha == FalhaUnidades.servidor ? 'alert' : null,
              rotuloAcao: carregando ? null : 'Tentar de novo',
              aoAcionar: carregando ? null : aoRecarregar,
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: aoRecarregar,
            color: NexaColors.green,
            backgroundColor: NexaColors.white,
            child: ValueListenableBuilder<Set<int>>(
              valueListenable: favoritas.ids,
              builder: (context, ids, _) {
                return ListView.separated(
                  // Sempre "rolável", senão o puxar-para-atualizar não
                  // funciona quando há poucas unidades.
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    top: mostraAviso ? NexaSpacing.sm : NexaSpacing.lg,
                    bottom: NexaSpacing.md,
                  ),
                  itemCount: unidades.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: espacoEntreCartoes),
                  itemBuilder: (context, indice) {
                    final unidade = unidades[indice];
                    return NexaUnidadeCard(
                      key: ValueKey(unidade.id),
                      nome: unidade.nome,
                      tempoEspera: unidade.tempoEspera,
                      favorita: ids.contains(unidade.id),
                      aoAlternarFavorita: () => aoAlternarFavorita(unidade),
                      aoTocar: () => unawaited(
                        abrirDetalheDaUnidade(
                          context,
                          unidade,
                          favoritas: favoritas,
                        ),
                      ),
                      detalhes: unidade.detalhes,
                      menorEspera: indice == indiceDoSelo,
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/features/busca/data/estados.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_folha.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:flutter/material.dart';

/// Abre a folha "Filtrar por estado" e espera a escolha.
Future<String?> escolherEstado(
  BuildContext context, {
  required String siglaAtual,
}) {
  return mostrarNexaFolha<String>(
    context,
    titulo: 'Filtrar por estado',
    rotuloFechar: 'Fechar',
    // Uma lista só como único filho: a folha põe 16 px entre os filhos, e
    // entre 28 opções isso ficaria enorme.
    children: [_ListaDeEstados(siglaAtual: siglaAtual)],
  );
}

class _ListaDeEstados extends StatelessWidget {
  const _ListaDeEstados({required this.siglaAtual});

  final String siglaAtual;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Opcao(
          rotulo: 'Todos os estados',
          sigla: '',
          selecionada: siglaAtual.isEmpty,
        ),
        for (final estado in estadosDoBrasil)
          _Opcao(
            rotulo: '${estado.nome} (${estado.sigla})',
            sigla: estado.sigla,
            selecionada: estado.sigla == siglaAtual,
          ),
      ],
    );
  }
}

/// Uma linha da folha. Tocar nela fecha a folha devolvendo a [sigla].
class _Opcao extends StatelessWidget {
  const _Opcao({
    required this.rotulo,
    required this.sigla,
    required this.selecionada,
  });

  final String rotulo;
  final String sigla;
  final bool selecionada;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selecionada,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(sigla),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: NexaSizes.minTouchTarget,
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: NexaColors.divider)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  rotulo,
                  style: selecionada ? NexaText.bodyStrong : NexaText.body,
                ),
              ),
              if (selecionada)
                const NexaIcon('check', size: 20, color: NexaColors.green),
            ],
          ),
        ),
      ),
    );
  }
}

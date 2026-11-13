import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:flutter/material.dart';

/// Campo de busca da tela Buscar: lupa, texto e um "X" para limpar.
class NexaCampoBusca extends StatefulWidget {
  const NexaCampoBusca({
    super.key,
    required this.controller,
    this.focusNode,
    this.hint = 'Buscar endereço, bairro ou CEP',
    this.autofocus = false,
    this.aoMudar,
    this.aoEnviar,
    this.rotuloLimpar = 'Limpar busca',
  });

  final TextEditingController controller;

  /// Opcional. Passe um quando a tela precisar tirar ou pôr o foco (por
  /// exemplo, fechar o teclado ao rolar a lista). Sem ele, o campo cria o seu.
  final FocusNode? focusNode;

  final String hint;
  final bool autofocus;

  /// Chamado a cada mudança do texto, inclusive quando o "X" limpa tudo
  /// (nesse caso com `''`).
  final ValueChanged<String>? aoMudar;

  /// Chamado quando a pessoa toca em "buscar" no teclado.
  final ValueChanged<String>? aoEnviar;

  /// O que o leitor de tela diz no "X".
  final String rotuloLimpar;

  @override
  State<NexaCampoBusca> createState() => _NexaCampoBuscaState();
}

class _NexaCampoBuscaState extends State<NexaCampoBusca> {
  /// Só existe quando a tela não passou um [FocusNode]. Quem cria, descarta.
  FocusNode? _focoProprio;

  FocusNode get _foco => widget.focusNode ?? (_focoProprio ??= FocusNode());

  @override
  void dispose() {
    _focoProprio?.dispose();
    super.dispose();
  }

  void _limpar() {
    widget.controller.clear();
    // `clear()` não dispara o `onChanged` do TextField, então avisamos à mão.
    widget.aoMudar?.call('');
    _foco.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_foco, widget.controller]),
      builder: (context, _) {
        final temFoco = _foco.hasFocus;
        final temTexto = widget.controller.text.isNotEmpty;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: NexaColors.white,
            borderRadius: BorderRadius.circular(NexaRadius.pill),
            border: Border.all(color: NexaColors.outline),
            // O Flutter pinta as sombras na ordem da lista (a última fica por
            // cima), ao contrário do CSS do Figma. Então o anel escuro de
            // 4 px vem primeiro e o de 2 px da cor do fundo vem depois,
            // deixando um respiro entre o campo e o anel.
            boxShadow: temFoco
                ? const [
                    BoxShadow(color: NexaColors.ink, spreadRadius: 4),
                    BoxShadow(color: NexaColors.background, spreadRadius: 2),
                  ]
                : null,
          ),
          child: SizedBox(
            height: NexaSizes.inputHeight,
            child: Row(
              children: [
                const SizedBox(width: NexaSpacing.md),
                const NexaIcon('search', color: NexaColors.inkSoft),
                const SizedBox(width: NexaSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _foco,
                    autofocus: widget.autofocus,
                    onChanged: widget.aoMudar,
                    onSubmitted: widget.aoEnviar,
                    textInputAction: TextInputAction.search,
                    textCapitalization: TextCapitalization.words,
                    style: NexaText.bodyMedium,
                    cursorColor: NexaColors.ink,
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle: NexaText.body.copyWith(
                        color: NexaColors.inkSoft,
                      ),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                ),
                if (temTexto)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: IconButton(
                      tooltip: widget.rotuloLimpar,
                      onPressed: _limpar,
                      style: IconButton.styleFrom(
                        fixedSize: const Size.square(NexaSizes.iconButton),
                        padding: EdgeInsets.zero,
                      ),
                      icon: const NexaIcon('close'),
                    ),
                  )
                else
                  const SizedBox(width: NexaSpacing.md),
              ],
            ),
          ),
        );
      },
    );
  }
}

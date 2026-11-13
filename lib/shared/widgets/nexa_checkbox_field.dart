import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:flutter/material.dart';

/// Caixinha de marcar com um texto ao lado, que funciona dentro de um `Form`.
class NexaCheckboxField extends FormField<bool> {
  NexaCheckboxField({
    super.key,
    required String label,
    super.validator,
    bool enabled = true,
    ValueChanged<bool>? onChanged,
  }) : super(
         initialValue: false,
         enabled: enabled,
         builder: (campo) {
           final marcado = campo.value ?? false;
           final temErro = campo.hasError;

           void alternar() {
             campo.didChange(!marcado);
             onChanged?.call(!marcado);
           }

           final corDaBorda = temErro
               ? NexaColors.red
               : marcado
               ? NexaColors.ink
               : NexaColors.outline;

           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Semantics(
                 checked: marcado,
                 enabled: enabled,
                 label: label,
                 excludeSemantics: true,
                 onTap: enabled ? alternar : null,
                 child: InkWell(
                   onTap: enabled ? alternar : null,
                   borderRadius: BorderRadius.circular(NexaRadius.snackbar),
                   child: Padding(
                     // 10 em cima e embaixo + 24 da caixinha = 44, o menor
                     // tamanho de toque aceitável.
                     padding: const EdgeInsets.symmetric(vertical: 10),
                     child: Row(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         AnimatedContainer(
                           duration: const Duration(milliseconds: 120),
                           width: 24,
                           height: 24,
                           decoration: BoxDecoration(
                             color: marcado ? NexaColors.ink : NexaColors.white,
                             borderRadius: BorderRadius.circular(6),
                             border: Border.all(
                               color: corDaBorda,
                               width: temErro ? 2 : 1.5,
                             ),
                           ),
                           child: marcado
                               ? const Center(
                                   child: NexaIcon(
                                     'check',
                                     size: 16,
                                     color: NexaColors.white,
                                   ),
                                 )
                               : null,
                         ),
                         const SizedBox(width: 12),
                         Expanded(
                           child: Text(
                             label,
                             style: NexaText.body.copyWith(
                               color: enabled
                                   ? NexaColors.ink
                                   : NexaColors.inkSoft,
                             ),
                           ),
                         ),
                       ],
                     ),
                   ),
                 ),
               ),
               if (temErro) _MensagemDeErro(campo.errorText ?? ''),
             ],
           );
         },
       );
}

class _MensagemDeErro extends StatelessWidget {
  const _MensagemDeErro(this.mensagem);

  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NexaIcon('alert', size: 18, color: NexaColors.red),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            mensagem,
            style: NexaText.small.copyWith(
              color: NexaColors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

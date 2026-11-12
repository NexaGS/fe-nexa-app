import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:flutter/material.dart';

/// Uma linha do cartão de informações da unidade: ícone, rótulo pequeno e valor.
///
/// Exemplo: pin + "Endereço" + "Rua das Acácias, 120". A [acao] opcional fica
/// à direita (no Figma, o botão de ligar na linha do telefone).
class NexaLinhaInfo extends StatelessWidget {
  const NexaLinhaInfo({
    super.key,
    required this.iconName,
    required this.rotulo,
    required this.valor,
    this.acao,
    this.mostrarDivisor = true,
  });

  final String iconName;

  /// Texto pequeno em cima ("Endereço").
  final String rotulo;

  /// Texto principal embaixo.
  final String valor;

  /// Widget no canto direito, por exemplo um `IconButton`.
  final Widget? acao;

  /// Linha fina embaixo. A última linha do cartão não precisa dela.
  final bool mostrarDivisor;

  @override
  Widget build(BuildContext context) {
    final extra = acao;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: mostrarDivisor
            ? const Border(bottom: BorderSide(color: NexaColors.divider))
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: NexaSpacing.sm),
        child: Row(
          children: [
            NexaIcon(iconName, color: NexaColors.inkSoft),
            const SizedBox(width: NexaSpacing.md),
            // Rótulo e valor viram uma frase só para o leitor de tela.
            Expanded(
              child: Semantics(
                container: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rotulo,
                      style: NexaText.caption.copyWith(
                        color: NexaColors.inkSoft,
                      ),
                    ),
                    Text(valor, style: NexaText.bodyMedium),
                  ],
                ),
              ),
            ),
            if (extra != null) extra,
          ],
        ),
      ),
    );
  }
}

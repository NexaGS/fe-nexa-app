import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:flutter/material.dart';

/// A "casca" de todo cartão do Nexa: fundo branco, borda fina, cantos de 20 px
/// e sombra leve. O miolo é o [child]; a margem de dentro é de quem usa.
///
/// Com [aoTocar], o cartão inteiro vira um botão (com o efeito de toque
/// seguindo o canto arredondado e anunciado como botão pelo leitor de tela).
/// Sem [aoTocar], é só uma moldura.
///
/// Se dentro do cartão houver outro botão (o coração de favoritar), tudo bem:
/// o toque vai para o botão de dentro, e o leitor de tela anuncia os dois.
class NexaCartao extends StatelessWidget {
  const NexaCartao({super.key, required this.child, this.aoTocar});

  final Widget child;
  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) {
    final raio = BorderRadius.circular(NexaRadius.card);
    final acao = aoTocar;

    // `Container` (e não `DecoratedBox`) porque ele empurra o miolo para dentro
    // da borda de 1 px, como no Figma.
    return Container(
      decoration: BoxDecoration(
        color: NexaColors.white,
        borderRadius: raio,
        border: Border.all(color: NexaColors.cardBorder),
        boxShadow: NexaShadows.card,
      ),
      child: acao == null
          ? child
          : Semantics(
              button: true,
              child: Material(
                color: Colors.transparent,
                borderRadius: raio,
                // Corta o efeito de toque no canto arredondado.
                clipBehavior: Clip.antiAlias,
                child: InkWell(onTap: acao, borderRadius: raio, child: child),
              ),
            ),
    );
  }
}

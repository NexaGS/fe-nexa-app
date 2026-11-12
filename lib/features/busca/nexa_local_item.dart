import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:flutter/material.dart';

/// Uma linha da lista da tela Buscar. Existem três, escolhidas pelo
/// construtor:
///
/// - [NexaLocalItem.localizacaoAtual]: "Usar minha localização atual", com o
///   ícone dentro de um círculo verde-claro;
/// - [NexaLocalItem.sugestao]: um resultado enquanto a pessoa digita (pin);
/// - [NexaLocalItem.recente]: um local buscado antes (relógio), com um "X" à
///   direita para tirá-lo da lista.
///
/// A linha toda é um botão. No recente, o "X" é outro botão, ao lado, e não
/// dentro do primeiro: assim cada um tem o seu toque e o leitor de tela anuncia
/// os dois.
class NexaLocalItem extends StatelessWidget {
  const NexaLocalItem._({
    super.key,
    required this.iconName,
    required this.destacado,
    required this.titulo,
    required this.descricao,
    required this.aoTocar,
    required this.aoRemover,
    required this.mostrarDivisor,
  });

  /// "Usar minha localização atual" (pede o GPS).
  const NexaLocalItem.localizacaoAtual({
    Key? key,
    required VoidCallback? aoTocar,
    String titulo = 'Usar minha localização atual',
    String descricao = 'Atualiza o ponto de partida pelo GPS',
    bool mostrarDivisor = true,
  }) : this._(
         key: key,
         iconName: 'locate',
         destacado: true,
         titulo: titulo,
         descricao: descricao,
         aoTocar: aoTocar,
         aoRemover: null,
         mostrarDivisor: mostrarDivisor,
       );

  /// Resultado da busca: "Vila Nova, São Paulo" / "Bairro".
  const NexaLocalItem.sugestao({
    Key? key,
    required String titulo,
    required String descricao,
    required VoidCallback? aoTocar,
    bool mostrarDivisor = true,
  }) : this._(
         key: key,
         iconName: 'pin',
         destacado: false,
         titulo: titulo,
         descricao: descricao,
         aoTocar: aoTocar,
         aoRemover: null,
         mostrarDivisor: mostrarDivisor,
       );

  /// Local buscado antes, com o "X" para remover do histórico.
  const NexaLocalItem.recente({
    Key? key,
    required String titulo,
    required String descricao,
    required VoidCallback? aoTocar,
    required VoidCallback aoRemover,
    bool mostrarDivisor = true,
  }) : this._(
         key: key,
         iconName: 'history',
         destacado: false,
         titulo: titulo,
         descricao: descricao,
         aoTocar: aoTocar,
         aoRemover: aoRemover,
         mostrarDivisor: mostrarDivisor,
       );

  final String iconName;

  /// `true` desenha o ícone dentro do círculo verde-claro (só a localização
  /// atual). `false` deixa o ícone solto, cinza.
  final bool destacado;

  /// Linha de cima, em destaque.
  final String titulo;

  /// Linha de baixo, em texto pequeno ("Bairro", "Local atual").
  final String descricao;

  /// Toque na linha. `null` deixa a linha sem resposta.
  final VoidCallback? aoTocar;

  /// Só o recente tem. Quando existe, aparece o "X".
  final VoidCallback? aoRemover;

  /// Linha fina embaixo. A última da lista pode dispensar.
  final bool mostrarDivisor;

  @override
  Widget build(BuildContext context) {
    final remover = aoRemover;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: mostrarDivisor
            ? const Border(bottom: BorderSide(color: NexaColors.divider))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              button: true,
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: aoTocar,
                  child: ConstrainedBox(
                    // 64 px é a altura do Figma; com letra grande a linha
                    // cresce em vez de cortar o texto.
                    constraints: const BoxConstraints(minHeight: 63),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 9.5),
                      child: Row(
                        children: [
                          _Marca(iconName: iconName, destacada: destacado),
                          const SizedBox(width: NexaSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  titulo,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: NexaText.bodyMedium,
                                ),
                                Text(
                                  descricao,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: NexaText.small.copyWith(
                                    color: NexaColors.inkSoft,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (remover != null)
            IconButton(
              tooltip: 'Remover "$titulo" dos recentes',
              onPressed: remover,
              style: IconButton.styleFrom(
                fixedSize: const Size.square(NexaSizes.minTouchTarget),
                padding: EdgeInsets.zero,
              ),
              icon: const NexaIcon('close', size: 20, color: NexaColors.inkSoft),
            ),
        ],
      ),
    );
  }
}

/// Os 40 x 40 da esquerda: ícone solto ou ícone dentro do círculo verde-claro.
class _Marca extends StatelessWidget {
  const _Marca({required this.iconName, required this.destacada});

  final String iconName;
  final bool destacada;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 40,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: destacada ? NexaColors.primrose : null,
        ),
        child: Center(
          child: NexaIcon(
            iconName,
            size: destacada ? 22 : 24,
            color: destacada ? NexaColors.ink : NexaColors.inkSoft,
          ),
        ),
      ),
    );
  }
}

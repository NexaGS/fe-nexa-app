import 'package:fe_nexa_app/features/unidades/nexa_unidade_card.dart';
import 'package:fe_nexa_app/galeria/galeria_app.dart';
import 'package:flutter/material.dart';

/// Galeria do lote "cartão de unidade".
/// Abra com: `flutter run -t lib/galeria/galeria_unidade_card.dart`
void main() {
  runApp(
    GaleriaApp(
      titulo: 'Componentes · cartão de unidade',
      secoes: [
        GaleriaSecao(
          titulo: 'Menor espera + frase de chegada',
          descricao: 'Toque no coração para alternar. Toque no cartão para ver o efeito.',
          children: [
            _ComFavorita(
              inicial: true,
              construir: (favorita, alternar) => NexaUnidadeCard(
                nome: 'Unidade B',
                tempoEspera: 40,
                favorita: favorita,
                aoAlternarFavorita: alternar,
                aoTocar: () {},
                menorEspera: true,
                detalhes: const ['3 km', '4 aguardando', 'há 2 min'],
                chegada: 'Se sair agora, você chega por volta das 14h20',
              ),
            ),
          ],
        ),
        GaleriaSecao(
          titulo: 'As três faixas',
          descricao: 'Curta até 60 min, média até 180 min, longa acima disso.',
          children: [
            _ComFavorita(
              inicial: false,
              construir: (favorita, alternar) => NexaUnidadeCard(
                nome: 'Unidade C',
                tempoEspera: 100,
                favorita: favorita,
                aoAlternarFavorita: alternar,
                aoTocar: () {},
                detalhes: const ['2 km', '12 aguardando', 'há 5 min'],
              ),
            ),
            _ComFavorita(
              inicial: false,
              construir: (favorita, alternar) => NexaUnidadeCard(
                nome: 'Unidade A',
                tempoEspera: 240,
                favorita: favorita,
                aoAlternarFavorita: alternar,
                aoTocar: () {},
                detalhes: const ['1 km', '38 aguardando', 'há 3 min'],
              ),
            ),
          ],
        ),
        GaleriaSecao(
          titulo: 'Dados antigos e sem dados',
          children: [
            _ComFavorita(
              inicial: false,
              construir: (favorita, alternar) => NexaUnidadeCard(
                nome: 'Unidade D',
                tempoEspera: 70,
                favorita: favorita,
                aoAlternarFavorita: alternar,
                aoTocar: () {},
                dadosAntigos: true,
                detalhes: const ['5 km', '9 aguardando', 'há 41 min'],
              ),
            ),
            _ComFavorita(
              inicial: false,
              construir: (favorita, alternar) => NexaUnidadeCard(
                nome: 'Unidade E',
                tempoEspera: null,
                favorita: favorita,
                aoAlternarFavorita: alternar,
                aoTocar: () {},
                detalhes: const ['7 km'],
              ),
            ),
          ],
        ),
        GaleriaSecao(
          titulo: 'Só o que o Java devolve hoje',
          descricao:
              'Nome e tempoEspera (e o bairro como detalhe). Sem distância, '
              'fila ou hora da atualização: esses campos somem sem deixar buraco.',
          children: [
            _ComFavorita(
              inicial: false,
              construir: (favorita, alternar) => NexaUnidadeCard(
                nome: 'UBS Bela Vista - Paulista',
                tempoEspera: 40,
                favorita: favorita,
                aoAlternarFavorita: alternar,
                aoTocar: () {},
                detalhes: const ['Bela Vista'],
              ),
            ),
            _ComFavorita(
              inicial: false,
              construir: (favorita, alternar) => NexaUnidadeCard(
                nome: 'Nome muito comprido de uma unidade de saúde que quebra em duas linhas',
                tempoEspera: 25,
                favorita: favorita,
                aoAlternarFavorita: alternar,
              ),
            ),
          ],
        ),
        const GaleriaSecao(
          titulo: 'Carregando',
          descricao: 'Pulsa. Com "remover animações" ligado, fica parado.',
          children: [
            NexaUnidadeCardCarregando(),
            NexaUnidadeCardCarregando(),
          ],
        ),
      ],
    ),
  );
}

/// Guarda o "é favorita?" de um cartão da galeria, para o coração funcionar.
class _ComFavorita extends StatefulWidget {
  const _ComFavorita({required this.inicial, required this.construir});

  final bool inicial;
  final Widget Function(bool favorita, VoidCallback alternar) construir;

  @override
  State<_ComFavorita> createState() => _ComFavoritaState();
}

class _ComFavoritaState extends State<_ComFavorita> {
  late bool _favorita = widget.inicial;

  @override
  Widget build(BuildContext context) {
    return widget.construir(
      _favorita,
      () => setState(() => _favorita = !_favorita),
    );
  }
}

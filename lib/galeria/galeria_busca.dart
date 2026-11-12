import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/features/busca/nexa_campo_busca.dart';
import 'package:fe_nexa_app/features/busca/nexa_local_item.dart';
import 'package:fe_nexa_app/features/perfil/nexa_secao_titulo.dart';
import 'package:fe_nexa_app/galeria/galeria_app.dart';
import 'package:fe_nexa_app/shared/widgets/guia_view.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_estado_vazio.dart';
import 'package:flutter/material.dart';

/// Galeria do lote "busca": campo e itens da lista.
/// Abra com: `flutter run -t lib/galeria/galeria_busca.dart`
void main() {
  runApp(
    GaleriaApp(
      titulo: 'Componentes · busca',
      secoes: [
        const GaleriaSecao(
          titulo: 'NexaCampoBusca',
          descricao:
              'Vazio e digitando. Toque no campo para ver o anel de foco; o '
              '"X" aparece quando há texto.',
          children: [
            _CampoComTexto(texto: ''),
            _CampoComTexto(texto: 'Vila'),
          ],
        ),
        GaleriaSecao(
          titulo: 'NexaLocalItem',
          descricao: 'Localização atual, recente (com "X") e sugestão.',
          children: [
            NexaLocalItem.localizacaoAtual(aoTocar: () {}),
            NexaLocalItem.recente(
              titulo: 'Vila Nova, São Paulo',
              descricao: 'Local atual',
              aoTocar: () {},
              aoRemover: () {},
            ),
            NexaLocalItem.recente(
              titulo: '01310-100',
              descricao: 'CEP · Bela Vista, São Paulo',
              aoTocar: () {},
              aoRemover: () {},
            ),
            NexaLocalItem.sugestao(
              titulo: 'Vila Mariana, São Paulo',
              descricao: 'Bairro',
              aoTocar: () {},
            ),
            NexaLocalItem.sugestao(
              titulo: 'Rua Vila Real, Centro',
              descricao: 'Endereço',
              aoTocar: () {},
            ),
          ],
        ),
        GaleriaSecao(
          titulo: 'Sem resultado',
          descricao: 'O estado "Busca errada" do Figma, com o componente do lote base.',
          children: [
            NexaEstadoVazio(
              mood: GuiaMood.vazio,
              titulo: 'Não encontramos esse local',
              texto: 'Confira o nome ou digite o CEP.',
              rotuloAcao: 'Usar minha localização atual',
              iconeAcao: 'locate',
              aoAcionar: () {},
            ),
          ],
        ),
        const GaleriaSecao(
          titulo: 'Tudo junto',
          descricao:
              'Vazio mostra localização atual e recentes. Digite "vila" para '
              'ver sugestões, ou "xyz" para ver o estado sem resultado.',
          children: [_BuscaDemo()],
        ),
      ],
    ),
  );
}

/// Um campo já com um texto, para mostrar o estado sem precisar digitar.
class _CampoComTexto extends StatefulWidget {
  const _CampoComTexto({required this.texto});

  final String texto;

  @override
  State<_CampoComTexto> createState() => _CampoComTextoState();
}

class _CampoComTextoState extends State<_CampoComTexto> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.texto,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 4 px de folga para o anel de foco não ser cortado pela galeria.
    return Padding(
      padding: const EdgeInsets.all(4),
      child: NexaCampoBusca(controller: _controller),
    );
  }
}

/// A busca funcionando com dados de mentira, como a tela vai se comportar.
class _BuscaDemo extends StatefulWidget {
  const _BuscaDemo();

  @override
  State<_BuscaDemo> createState() => _BuscaDemoState();
}

class _BuscaDemoState extends State<_BuscaDemo> {
  static const _locais = [
    ('Vila Nova, São Paulo', 'Bairro'),
    ('Vila Mariana, São Paulo', 'Bairro'),
    ('Vila Madalena, São Paulo', 'Bairro'),
    ('Vila Olímpia, São Paulo', 'Bairro'),
    ('Rua Vila Real, Centro', 'Endereço'),
  ];

  final _controller = TextEditingController();
  final _recentes = <(String, String)>[
    ('Vila Nova, São Paulo', 'Local atual'),
    ('Rua das Acácias, 120', 'Vila Nova, São Paulo'),
    ('01310-100', 'CEP · Bela Vista, São Paulo'),
  ];
  String _escolhido = 'nenhum';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _escolher(String local) => setState(() => _escolhido = local);

  @override
  Widget build(BuildContext context) {
    final busca = _controller.text.trim().toLowerCase();
    final resultados = [
      for (final local in _locais)
        if (local.$1.toLowerCase().contains(busca)) local,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(4),
          child: NexaCampoBusca(
            controller: _controller,
            aoMudar: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: 8),
        if (busca.isEmpty) ...[
          NexaLocalItem.localizacaoAtual(
            aoTocar: () => _escolher('localização atual'),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 20, bottom: 4),
            child: NexaSecaoTitulo('Locais recentes'),
          ),
          for (final recente in _recentes)
            NexaLocalItem.recente(
              titulo: recente.$1,
              descricao: recente.$2,
              aoTocar: () => _escolher(recente.$1),
              aoRemover: () => setState(() => _recentes.remove(recente)),
            ),
        ] else if (resultados.isEmpty)
          NexaEstadoVazio(
            mood: GuiaMood.vazio,
            titulo: 'Não encontramos esse local',
            texto: 'Confira o nome ou digite o CEP.',
            rotuloAcao: 'Usar minha localização atual',
            iconeAcao: 'locate',
            aoAcionar: () => _escolher('localização atual'),
          )
        else
          for (final local in resultados)
            NexaLocalItem.sugestao(
              titulo: local.$1,
              descricao: local.$2,
              aoTocar: () => _escolher(local.$1),
            ),
        const SizedBox(height: 12),
        Text(
          'Escolhido: $_escolhido',
          style: NexaText.small.copyWith(color: NexaColors.inkSoft),
        ),
      ],
    );
  }
}

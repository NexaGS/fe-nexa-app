import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/features/perfil/nexa_avatar.dart';
import 'package:fe_nexa_app/features/perfil/nexa_linha_config.dart';
import 'package:fe_nexa_app/features/perfil/nexa_secao_titulo.dart';
import 'package:fe_nexa_app/features/unidades/nexa_linha_info.dart';
import 'package:fe_nexa_app/galeria/galeria_app.dart';
import 'package:fe_nexa_app/shared/utils/espera.dart';
import 'package:fe_nexa_app/shared/widgets/guia_view.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_banner.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_button.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_espera_chip.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_estado_vazio.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_favorito_button.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_segmentado.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_skeleton.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_snackbar.dart';
import 'package:flutter/material.dart';

/// Galeria do lote "base": os componentes curtos.
/// Abra com: `flutter run -t lib/galeria/galeria_base.dart`
void main() {
  runApp(
    GaleriaApp(
      titulo: 'Componentes · base',
      secoes: [
        GaleriaSecao(
          titulo: 'NexaEsperaChip',
          descricao: 'Sempre ponto (ou ícone) e texto: a cor nunca é o único sinal.',
          children: [
            for (final nivel in NivelEspera.values) NexaEsperaChip(nivel: nivel),
          ],
        ),
        GaleriaSecao(
          titulo: 'Regra da espera',
          descricao: 'Minutos do Java, a faixa que a regra escolhe e o texto.',
          children: [
            for (final minutos in const [0.0, 40.0, 60.0, 65.0, 100.0, 180.0, 240.0])
              Row(
                children: [
                  SizedBox(
                    width: 190,
                    child: Text(
                      '${minutos.round()} min → ${textoDaEspera(minutos)}',
                      style: NexaText.small,
                    ),
                  ),
                  NexaEsperaChip(nivel: nivelDaEspera(minutos)),
                ],
              ),
            const NexaEsperaChip(nivel: NivelEspera.semDados),
          ],
        ),
        const GaleriaSecao(
          titulo: 'NexaFavoritoButton',
          descricao: 'Toque para alternar. O terceiro está desabilitado.',
          children: [
            _FavoritoDemo(),
            NexaFavoritoButton(favorita: false, aoAlternar: null),
          ],
        ),
        GaleriaSecao(
          titulo: 'NexaBanner',
          children: [
            NexaBanner(
              mensagem: 'Mostrando dados de há 12 min',
              rotuloAcao: 'Tentar de novo',
              aoAcionar: () {},
            ),
            NexaBanner(
              tom: NexaBannerTom.informativo,
              mensagem:
                  'Suas favoritas estão só neste aparelho. Crie uma conta para não perdê-las.',
              rotuloAcao: 'Criar conta',
              aoAcionar: () {},
              acaoEmBotao: true,
            ),
            NexaBanner(
              tom: NexaBannerTom.informativo,
              mensagem: 'Mostrando unidades perto de Vila Mariana',
              rotuloAcao: 'Desfazer',
              aoAcionar: () {},
            ),
            const NexaBanner(mensagem: 'Sem ação, só o aviso'),
          ],
        ),
        const GaleriaSecao(
          titulo: 'NexaSkeleton',
          descricao: 'Pulsa. Com "remover animações" ligado no celular, fica parado.',
          children: [
            NexaSkeleton(altura: 20, largura: 120),
            NexaSkeleton(altura: 28, largura: 180),
            NexaSkeleton(altura: 18),
          ],
        ),
        GaleriaSecao(
          titulo: 'NexaEstadoVazio',
          children: [
            NexaEstadoVazio(
              mood: GuiaMood.erro,
              titulo: 'Algo deu errado do nosso lado',
              texto: 'Não conseguimos carregar as unidades. Tente de novo em instantes.',
              rotuloAcao: 'Tentar de novo',
              iconeAcao: 'refresh',
              aoAcionar: () {},
            ),
            NexaEstadoVazio(
              mood: GuiaMood.vazio,
              titulo: 'Não achamos unidades perto daqui',
              texto: 'Tente outro bairro ou CEP para ver as unidades mais próximas.',
              rotuloAcao: 'Buscar outro local',
              iconeAcao: 'search',
              aoAcionar: () {},
            ),
          ],
        ),
        const GaleriaSecao(
          titulo: 'NexaSnackbar',
          descricao: 'Com e sem ação.',
          children: [_SnackbarDemo()],
        ),
        const GaleriaSecao(
          titulo: 'NexaAvatar',
          children: [
            Row(
              spacing: 12,
              children: [
                NexaAvatar(nome: 'Ana Souza'),
                NexaAvatar(nome: 'Julio'),
                NexaAvatar(nome: null),
              ],
            ),
          ],
        ),
        GaleriaSecao(
          titulo: 'NexaSecaoTitulo e NexaLinhaConfig',
          children: [
            const NexaSecaoTitulo('Privacidade'),
            const _LinhaConfigDemo(),
          ],
        ),
        const GaleriaSecao(
          titulo: 'NexaSegmentado',
          children: [_SegmentadoDemo()],
        ),
        GaleriaSecao(
          titulo: 'NexaLinhaInfo',
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: NexaSpacing.md,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: NexaColors.white,
                borderRadius: BorderRadius.circular(NexaRadius.card),
                border: Border.all(color: NexaColors.divider),
              ),
              child: Column(
                children: [
                  const NexaLinhaInfo(
                    iconName: 'pin',
                    rotulo: 'Endereço',
                    valor: 'Rua das Acácias, 120 · Vila Nova, São Paulo',
                  ),
                  const NexaLinhaInfo(
                    iconName: 'navigation',
                    rotulo: 'Distância',
                    valor: '3 km de você',
                  ),
                  NexaLinhaInfo(
                    iconName: 'phone',
                    rotulo: 'Telefone',
                    valor: '(11) 5555-0142',
                    mostrarDivisor: false,
                    acao: IconButton(
                      tooltip: 'Ligar',
                      onPressed: () {},
                      icon: const NexaIcon('phone', color: NexaColors.inkSoft),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        GaleriaSecao(
          titulo: 'Referência: NexaButton',
          children: [
            NexaButton(label: 'Entendi', onPressed: () {}),
            NexaButton(
              label: 'Cancelar',
              variant: NexaButtonVariant.outline,
              onPressed: () {},
            ),
          ],
        ),
      ],
    ),
  );
}

class _FavoritoDemo extends StatefulWidget {
  const _FavoritoDemo();

  @override
  State<_FavoritoDemo> createState() => _FavoritoDemoState();
}

class _FavoritoDemoState extends State<_FavoritoDemo> {
  bool _favorita = false;

  @override
  Widget build(BuildContext context) {
    return NexaFavoritoButton(
      favorita: _favorita,
      nomeDaUnidade: 'Unidade B',
      aoAlternar: () => setState(() => _favorita = !_favorita),
    );
  }
}

class _SegmentadoDemo extends StatefulWidget {
  const _SegmentadoDemo();

  @override
  State<_SegmentadoDemo> createState() => _SegmentadoDemoState();
}

class _SegmentadoDemoState extends State<_SegmentadoDemo> {
  int _indice = 1;

  @override
  Widget build(BuildContext context) {
    return NexaSegmentado(
      opcoes: const ['3', '5', '10'],
      indiceAtual: _indice,
      aoSelecionar: (indice) => setState(() => _indice = indice),
    );
  }
}

class _LinhaConfigDemo extends StatefulWidget {
  const _LinhaConfigDemo();

  @override
  State<_LinhaConfigDemo> createState() => _LinhaConfigDemoState();
}

class _LinhaConfigDemoState extends State<_LinhaConfigDemo> {
  bool _ativa = true;

  @override
  Widget build(BuildContext context) {
    return NexaLinhaConfig(
      titulo: 'Usar minha localização',
      descricao: 'Só usamos para ordenar unidades por distância. Não guardamos seu trajeto.',
      ativa: _ativa,
      aoAlterar: (valor) => setState(() => _ativa = valor),
    );
  }
}

class _SnackbarDemo extends StatelessWidget {
  const _SnackbarDemo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        NexaButton(
          label: 'Aviso com "Desfazer"',
          variant: NexaButtonVariant.outline,
          onPressed: () => NexaSnackbar.aviso(
            context,
            'Unidade removida das favoritas',
            rotuloAcao: 'Desfazer',
            aoAcionar: () {},
          ),
        ),
        NexaButton(
          label: 'Erro sem ação',
          variant: NexaButtonVariant.outline,
          onPressed: () => NexaSnackbar.erro(context, 'Algo deu errado.'),
        ),
      ],
    );
  }
}

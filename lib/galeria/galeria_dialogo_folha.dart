import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/features/unidades/nexa_folha_espera.dart';
import 'package:fe_nexa_app/galeria/galeria_app.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_button.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_dialogo.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_samu_button.dart';
import 'package:flutter/material.dart';

/// Galeria do lote "diálogo e folha".
/// Abra com: `flutter run -t lib/galeria/galeria_dialogo_folha.dart`
void main() {
  runApp(
    const GaleriaApp(
      titulo: 'Componentes · diálogo e folha',
      secoes: [
        GaleriaSecao(
          titulo: 'NexaDialogo · padrão',
          descricao:
              'Botões empilhados, confirmar em verde-lima. É o "Sintomas '
              'graves?". Aqui ele não abre o telefone: só mostra a resposta.',
          children: [
            _DemoDialogo(
              rotulo: 'Abrir "Sintomas graves?"',
              abrir: _abrirPadrao,
            ),
          ],
        ),
        GaleriaSecao(
          titulo: 'NexaDialogo · destrutivo',
          descricao:
              'Botões lado a lado, confirmar em vermelho. É o "Sair da conta?".',
          children: [
            _DemoDialogo(
              rotulo: 'Abrir "Sair da conta?"',
              abrir: _abrirDestrutivo,
            ),
          ],
        ),
        GaleriaSecao(
          titulo: 'NexaSamuButton (real)',
          descricao:
              'O botão do topo das telas. "Ligar para o 192" abre o discador '
              'do aparelho; sem telefone (computador, navegador), mostra o '
              'aviso de erro.',
          children: [
            Align(alignment: Alignment.centerLeft, child: NexaSamuButton()),
          ],
        ),
        GaleriaSecao(
          titulo: 'NexaFolha · Como calculamos a espera',
          descricao:
              'Fecha com "Entendi", tocando fora ou arrastando para baixo. '
              'A legenda lê os limites de espera.dart.',
          children: [_DemoFolha()],
        ),
      ],
    ),
  );
}

Future<bool> _abrirPadrao(BuildContext context) {
  return mostrarNexaDialogo(
    context,
    iconName: 'phone',
    titulo: 'Sintomas graves?',
    texto:
        'Ligue 192 (SAMU). A ligação é gratuita e o atendimento funciona '
        '24 horas.',
    rotuloConfirmar: 'Ligar para o 192',
    iconeConfirmar: 'phone',
    rotuloCancelar: 'Agora não',
  );
}

Future<bool> _abrirDestrutivo(BuildContext context) {
  return mostrarNexaDialogo(
    context,
    iconName: 'logout',
    titulo: 'Sair da conta?',
    texto:
        'Suas favoritas continuam guardadas na sua conta e voltam quando você '
        'entrar de novo.',
    rotuloConfirmar: 'Sair',
    rotuloCancelar: 'Cancelar',
    destrutivo: true,
  );
}

/// Botão que abre um diálogo e escreve embaixo o que a pessoa respondeu.
class _DemoDialogo extends StatefulWidget {
  const _DemoDialogo({required this.rotulo, required this.abrir});

  final String rotulo;
  final Future<bool> Function(BuildContext context) abrir;

  @override
  State<_DemoDialogo> createState() => _DemoDialogoState();
}

class _DemoDialogoState extends State<_DemoDialogo> {
  String _resposta = 'Ainda sem resposta.';

  Future<void> _abrir() async {
    final confirmou = await widget.abrir(context);
    if (!mounted) return;
    setState(() => _resposta = confirmou ? 'Confirmou.' : 'Cancelou.');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NexaButton(
          label: widget.rotulo,
          variant: NexaButtonVariant.outline,
          onPressed: _abrir,
        ),
        const SizedBox(height: 8),
        Text(
          'Resposta: $_resposta',
          style: NexaText.small.copyWith(color: NexaColors.inkSoft),
        ),
      ],
    );
  }
}

class _DemoFolha extends StatelessWidget {
  const _DemoFolha();

  @override
  Widget build(BuildContext context) {
    return NexaButton(
      label: 'Abrir a folha',
      variant: NexaButtonVariant.outline,
      onPressed: () => mostrarFolhaEspera(context),
    );
  }
}

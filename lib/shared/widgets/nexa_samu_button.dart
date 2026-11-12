import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_dialogo.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Botão "SAMU 192" do topo. Ao tocar, pergunta se a pessoa quer ligar.
class NexaSamuButton extends StatelessWidget {
  const NexaSamuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: Material(
        color: NexaColors.white,
        shape: const StadiumBorder(
          side: BorderSide(color: NexaColors.divider),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: () => mostrarDialogoSamu(context),
          child: const Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 14, 0),
            child: SizedBox(
              height: 36,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NexaIcon('phone', size: 18, color: NexaColors.red),
                  SizedBox(width: 6),
                  Text('SAMU 192', style: NexaText.smallStrong),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Mostra o aviso e, se a pessoa aceitar, abre o discador com o 192 digitado.
Future<void> mostrarDialogoSamu(BuildContext context) async {
  final querLigar = await mostrarNexaDialogo(
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
  if (!querLigar || !context.mounted) return;

  final abriu = await _abrirDiscador();
  if (!abriu && context.mounted) {
    NexaSnackbar.erro(
      context,
      'Não foi possível abrir o telefone. Ligue 192 pelo seu aparelho.',
    );
  }
}

Future<bool> _abrirDiscador() async {
  try {
    return await launchUrl(Uri(scheme: 'tel', path: '192'));
  } on Exception {
    return false;
  }
}

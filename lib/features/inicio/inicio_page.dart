import 'package:flutter/material.dart';

import '../../app/theme/nexa_colors.dart';
import '../../app/theme/nexa_text.dart';
import '../../shared/widgets/guia_view.dart';
import '../../shared/widgets/nexa_button.dart';
import '../../shared/widgets/nexa_logo.dart';
import '../auth/criar_conta_page.dart';
import '../auth/entrar_page.dart';
import '../home/home_page.dart';

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  /// Empilha uma tela nova por cima desta.
  void _abrir(BuildContext context, Widget tela) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => tela));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 14),
              const Align(
                alignment: Alignment.centerLeft,
                child: NexaLogo(),
              ),
              const Expanded(
                child: Center(
                  child: GuiaView(
                    mood: GuiaMood.boasVindas,
                    semanticLabel: 'Guia, o mascote do Nexa, dando boas-vindas',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Compare a espera antes de\nsair de casa',
                style: NexaText.display,
              ),
              const SizedBox(height: 8),
              Text(
                'Veja quais unidades próximas atendem o que você precisa '
                    'e quanto tempo pode levar.',
                style: NexaText.body.copyWith(color: NexaColors.inkSoft),
              ),
              const SizedBox(height: 24),
              NexaButton(
                label: 'Entrar',
                onPressed: () => _abrir(context, const EntrarPage()),
              ),
              const SizedBox(height: 12),
              NexaButton(
                label: 'Criar conta',
                variant: NexaButtonVariant.outline,
                onPressed: () => _abrir(context, const CriarContaPage()),
              ),
              const SizedBox(height: 12),
              Center(
                child: NexaButton(
                  label: 'Continuar sem conta',
                  variant: NexaButtonVariant.text,
                  onPressed: () => _abrir(context, const HomePage()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7),
                child: Text(
                  'Você pode favoritar unidades neste aparelho. '
                      'Para guardar na nuvem, crie uma conta.',
                  textAlign: TextAlign.center,
                  style: NexaText.caption.copyWith(color: NexaColors.inkSoft),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:fe_nexa_app/app/theme/nexa_theme.dart';

import '../shared/widgets/nexa_button.dart';

class NexaApp extends StatelessWidget {
  const NexaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexa',
      debugShowCheckedModeBanner: false,
      theme: buildNexaTheme(),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NexaButton(label: 'Entrar', onPressed: () {}),
              const SizedBox(height: 12),
              NexaButton(
                label: 'Criar conta',
                variant: NexaButtonVariant.outline,
                onPressed: () {},
              ),
              const SizedBox(height: 12),
              Center(
                child: NexaButton(
                  label: 'Continuar sem conta',
                  variant: NexaButtonVariant.text,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

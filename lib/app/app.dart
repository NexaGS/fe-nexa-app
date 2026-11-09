import 'package:fe_nexa_app/app/theme/nexa_theme.dart';
import 'package:flutter/material.dart';

import '../features/inicio/inicio_page.dart';

class NexaApp extends StatelessWidget {
  const NexaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexa',
      debugShowCheckedModeBanner: false,
      theme: buildNexaTheme(),
      home: const InicioPage(),
    );
  }
}

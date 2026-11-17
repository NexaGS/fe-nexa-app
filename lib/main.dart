import 'package:flutter/material.dart';
import 'package:fe_nexa_app/app/app.dart';
import 'package:fe_nexa_app/features/perfil/data/preferencias_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Antes de desenhar a primeira tela: as escolhas do Perfil (quantidade da
  // lista e localização) já aparecem como a pessoa deixou.
  try {
    await preferenciasRepository.carregar();
  } catch (_) {
    // Sem ler as preferências, valem os padrões.
  }

  runApp(const NexaApp());
}

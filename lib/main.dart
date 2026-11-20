import 'package:flutter/material.dart';
import 'package:fe_nexa_app/app/app.dart';
import 'package:fe_nexa_app/features/auth/data/sessao.dart';
import 'package:fe_nexa_app/features/auth/data/sessao_service.dart';
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

  // Lê a sessão guardada no aparelho (o token de 8 horas do login). Com ela, o
  // app abre direto na Home; sem ela (ou com o token vencido), no Início.
  Sessao? sessao;
  try {
    await sessaoService.iniciar();
    sessao = sessaoService.atual.value;
  } catch (_) {
    // Sem conseguir ler o cofre, a pessoa entra de novo.
  }

  runApp(NexaApp(sessaoInicial: sessao));
}

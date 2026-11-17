import 'dart:async';

import 'package:fe_nexa_app/shared/utils/atualizador_periodico.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// Como o atualizador não está dentro de uma tela, nada o desliga sozinho no
// fim do teste: cada teste termina com `parar()`, senão o Timer fica pendente.
void main() {
  const intervalo = Duration(seconds: 20);

  testWidgets('chama atualizar a cada intervalo', (tester) async {
    var chamadas = 0;
    final atualizador = AtualizadorPeriodico(atualizar: () async => chamadas++);

    atualizador.iniciar();
    expect(chamadas, 0);

    await tester.pump(intervalo);
    expect(chamadas, 1);

    await tester.pump(intervalo);
    expect(chamadas, 2);

    atualizador.parar();
  });

  testWidgets('respeita o intervalo informado', (tester) async {
    var chamadas = 0;
    final atualizador = AtualizadorPeriodico(
      atualizar: () async => chamadas++,
      intervalo: const Duration(seconds: 5),
    );

    atualizador.iniciar();
    await tester.pump(const Duration(seconds: 4));
    expect(chamadas, 0);
    await tester.pump(const Duration(seconds: 1));
    expect(chamadas, 1);

    atualizador.parar();
  });

  testWidgets('parar() cancela as próximas rodadas', (tester) async {
    var chamadas = 0;
    final atualizador = AtualizadorPeriodico(atualizar: () async => chamadas++);

    atualizador.iniciar();
    await tester.pump(intervalo);
    expect(chamadas, 1);

    atualizador.parar();
    await tester.pump(intervalo * 3);
    expect(chamadas, 1);
  });

  testWidgets('uma falha não interrompe as rodadas seguintes', (tester) async {
    var chamadas = 0;
    final atualizador = AtualizadorPeriodico(
      atualizar: () async {
        chamadas++;
        if (chamadas == 1) throw Exception('servidor fora do ar');
      },
    );

    atualizador.iniciar();
    await tester.pump(intervalo);
    await tester.pump(intervalo);
    expect(chamadas, 2);

    atualizador.parar();
  });

  testWidgets('não começa uma rodada com outra ainda em andamento', (
    tester,
  ) async {
    var chamadas = 0;
    final terminar = Completer<void>();
    final atualizador = AtualizadorPeriodico(
      atualizar: () {
        chamadas++;
        return terminar.future;
      },
    );

    atualizador.iniciar();
    await tester.pump(intervalo);
    expect(chamadas, 1);

    await atualizador.atualizarAgora();
    await tester.pump(intervalo * 3);
    expect(chamadas, 1);

    terminar.complete();
    await tester.pump();
    await tester.pump(intervalo);
    expect(chamadas, 2);

    atualizador.parar();
  });

  testWidgets('atualizarAgora() roda já e recomeça a contagem', (tester) async {
    var chamadas = 0;
    final atualizador = AtualizadorPeriodico(atualizar: () async => chamadas++);

    atualizador.iniciar();
    await tester.pump(const Duration(seconds: 15));
    await atualizador.atualizarAgora();
    expect(chamadas, 1);

    // A contagem recomeçou: 15 s depois ainda não é hora.
    await tester.pump(const Duration(seconds: 15));
    expect(chamadas, 1);
    await tester.pump(const Duration(seconds: 5));
    expect(chamadas, 2);

    atualizador.parar();
  });

  testWidgets('definirAtivo liga com rodada na hora e desliga', (tester) async {
    var chamadas = 0;
    final atualizador = AtualizadorPeriodico(atualizar: () async => chamadas++);

    atualizador.definirAtivo(true);
    expect(chamadas, 1);

    await tester.pump(intervalo);
    expect(chamadas, 2);

    atualizador.definirAtivo(false);
    await tester.pump(intervalo * 3);
    expect(chamadas, 2);

    // Ligar de novo faz outra rodada na hora.
    atualizador.definirAtivo(true);
    expect(chamadas, 3);

    atualizador.parar();
  });

  testWidgets('em segundo plano pausa; ao voltar, atualiza na hora', (
    tester,
  ) async {
    var chamadas = 0;
    final atualizador = AtualizadorPeriodico(atualizar: () async => chamadas++);

    atualizador.iniciar();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(intervalo * 3);
    expect(chamadas, 0);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(chamadas, 1);

    await tester.pump(intervalo);
    expect(chamadas, 2);

    atualizador.parar();
  });
}

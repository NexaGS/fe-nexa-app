import 'package:fe_nexa_app/shared/widgets/nexa_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_de_teste.dart';

void main() {
  testWidgets('pulsa quando o movimento está liberado', (tester) async {
    await tester.pumpWidget(
      appDeTeste(const NexaSkeleton(altura: 20, largura: 120)),
    );

    expect(tester.hasRunningAnimations, isTrue);
  });

  testWidgets('fica parado quando o celular pede menos movimento', (
    tester,
  ) async {
    await tester.pumpWidget(
      appDeTeste(
        const NexaSkeleton(altura: 20, largura: 120),
        semAnimacao: true,
      ),
    );

    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('tem o tamanho pedido', (tester) async {
    await tester.pumpWidget(
      appDeTeste(const NexaSkeleton(altura: 28, largura: 180)),
    );

    expect(tester.getSize(find.byType(NexaSkeleton)), const Size(180, 28));
  });
}

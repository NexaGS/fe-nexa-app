import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_segmentado.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_de_teste.dart';

void main() {
  testWidgets('mostra as opções e marca só a escolhida com o visto', (
    tester,
  ) async {
    await tester.pumpWidget(
      appDeTeste(
        NexaSegmentado(
          opcoes: const ['3', '5', '10'],
          indiceAtual: 1,
          aoSelecionar: (_) {},
        ),
      ),
    );

    expect(find.text('3'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.byType(NexaIcon), findsOneWidget);
  });

  testWidgets('tocar numa opção avisa a posição dela', (tester) async {
    int? posicao;
    await tester.pumpWidget(
      appDeTeste(
        NexaSegmentado(
          opcoes: const ['3', '5', '10'],
          indiceAtual: 1,
          aoSelecionar: (indice) => posicao = indice,
        ),
      ),
    );

    await tester.tap(find.text('10'));

    expect(posicao, 2);
  });
}

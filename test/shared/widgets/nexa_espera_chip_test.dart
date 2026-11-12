import 'package:fe_nexa_app/shared/utils/espera.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_espera_chip.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_de_teste.dart';

void main() {
  const textos = {
    NivelEspera.curta: 'Espera curta',
    NivelEspera.media: 'Espera média',
    NivelEspera.longa: 'Espera longa',
    NivelEspera.dadosAntigos: 'Dados antigos',
    NivelEspera.semDados: 'Sem dados recentes',
  };

  for (final entrada in textos.entries) {
    testWidgets('${entrada.key.name} mostra "${entrada.value}"', (tester) async {
      await tester.pumpWidget(appDeTeste(NexaEsperaChip(nivel: entrada.key)));

      expect(find.text(entrada.value), findsOneWidget);
    });
  }

  testWidgets('as faixas usam ponto; os outros dois usam ícone', (tester) async {
    await tester.pumpWidget(
      appDeTeste(const NexaEsperaChip(nivel: NivelEspera.curta)),
    );
    expect(find.byType(NexaIcon), findsNothing);

    await tester.pumpWidget(
      appDeTeste(const NexaEsperaChip(nivel: NivelEspera.dadosAntigos)),
    );
    expect(find.byType(NexaIcon), findsOneWidget);
  });
}

import 'package:fe_nexa_app/shared/widgets/guia_view.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_estado_vazio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_de_teste.dart';

void main() {
  testWidgets('mostra título, texto e o botão chama a ação', (tester) async {
    var toques = 0;
    await tester.pumpWidget(
      appDeTeste(
        NexaEstadoVazio(
          mood: GuiaMood.vazio,
          titulo: 'Não achamos unidades perto daqui',
          texto: 'Tente outro bairro ou CEP.',
          rotuloAcao: 'Buscar outro local',
          iconeAcao: 'search',
          aoAcionar: () => toques++,
        ),
        // Com "remover animações" o Guia vira uma imagem parada.
        semAnimacao: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Não achamos unidades perto daqui'), findsOneWidget);
    expect(find.text('Tente outro bairro ou CEP.'), findsOneWidget);

    await tester.tap(find.text('Buscar outro local'));

    expect(toques, 1);
  });

  testWidgets('sem ação, o botão não aparece', (tester) async {
    await tester.pumpWidget(
      appDeTeste(
        const NexaEstadoVazio(
          mood: GuiaMood.erro,
          titulo: 'Algo deu errado do nosso lado',
          texto: 'Tente de novo em instantes.',
        ),
        semAnimacao: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Algo deu errado do nosso lado'), findsOneWidget);
    expect(find.text('Tentar de novo'), findsNothing);
  });
}

import 'package:fe_nexa_app/features/perfil/nexa_secao_titulo.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_de_teste.dart';

void main() {
  testWidgets('mostra o título', (tester) async {
    await tester.pumpWidget(appDeTeste(const NexaSecaoTitulo('Minha busca')));

    expect(find.text('Minha busca'), findsOneWidget);
  });
}

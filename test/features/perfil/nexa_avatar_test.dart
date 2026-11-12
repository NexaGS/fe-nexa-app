import 'package:fe_nexa_app/features/perfil/nexa_avatar.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_de_teste.dart';

void main() {
  testWidgets('mostra as iniciais do nome', (tester) async {
    await tester.pumpWidget(appDeTeste(const NexaAvatar(nome: 'Ana Souza')));

    expect(find.text('AS'), findsOneWidget);
    expect(find.byType(NexaIcon), findsNothing);
  });

  testWidgets('sem nome, mostra o ícone de pessoa', (tester) async {
    await tester.pumpWidget(appDeTeste(const NexaAvatar(nome: null)));

    expect(find.byType(NexaIcon), findsOneWidget);
  });
}

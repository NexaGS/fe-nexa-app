import 'package:fe_nexa_app/shared/widgets/nexa_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_de_teste.dart';

Widget _botaoQueAbre(void Function(BuildContext) abrir) {
  return Builder(
    builder: (context) => ElevatedButton(
      onPressed: () => abrir(context),
      child: const Text('abrir'),
    ),
  );
}

void main() {
  testWidgets('aviso com ação mostra o botão e chama o callback', (
    tester,
  ) async {
    var desfez = false;
    await tester.pumpWidget(
      appDeTeste(
        _botaoQueAbre(
          (context) => NexaSnackbar.aviso(
            context,
            'Unidade removida das favoritas',
            rotuloAcao: 'Desfazer',
            aoAcionar: () => desfez = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('abrir'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 750));

    expect(find.text('Unidade removida das favoritas'), findsOneWidget);
    await tester.tap(find.text('Desfazer'));

    expect(desfez, isTrue);
  });

  testWidgets('aviso sem ação continua sem botão', (tester) async {
    await tester.pumpWidget(
      appDeTeste(
        _botaoQueAbre(
          (context) => NexaSnackbar.erro(context, 'Algo deu errado.'),
        ),
      ),
    );

    await tester.tap(find.text('abrir'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 750));

    expect(find.text('Algo deu errado.'), findsOneWidget);
    expect(find.byType(SnackBarAction), findsNothing);
  });
}

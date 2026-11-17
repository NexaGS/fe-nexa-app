import 'package:fe_nexa_app/app/theme/nexa_theme.dart';
import 'package:fe_nexa_app/features/auth/data/auth_repository.dart';
import 'package:fe_nexa_app/features/auth/data/sessao_service.dart';
import 'package:fe_nexa_app/features/perfil/aba_perfil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes_auth.dart';
import '../../helpers/fakes_perfil.dart';

final _ana = sessaoDeTeste(email: 'ana.souza@exemplo.com');

/// Abre a aba Perfil numa tela do tamanho do Figma (390 x 844).
Future<void> abrir(
  WidgetTester tester, {
  Sessao? sessao,
  PreferenciasFalso? preferencias,
  SessaoService? sessoes,
  VoidCallback? aoSair,
  VoidCallback? aoEntrarOuCriarConta,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: buildNexaTheme(),
      home: Scaffold(
        body: SafeArea(
          child: AbaPerfil(
            sessao: sessao,
            preferencias: preferencias ?? PreferenciasFalso(),
            sessoes:
                sessoes ??
                SessaoService(
                  auth: AuthFalso(),
                  armazenamento: SessoesFalso(),
                ),
            aoSair: aoSair,
            aoEntrarOuCriarConta: aoEntrarOuCriarConta,
            versaoDoApp: () async => '0.1.0',
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Toca em "Sair" (rolando até ele, se preciso) e espera o diálogo abrir.
Future<void> tocarEmSair(WidgetTester tester) async {
  final botaoSair = find.widgetWithText(TextButton, 'Sair');
  await tester.ensureVisible(botaoSair);
  await tester.pumpAndSettle();
  await tester.tap(botaoSair);
  await tester.pumpAndSettle();
}

void main() {
  group('com conta', () {
    testWidgets('mostra iniciais, nome, e-mail e os três blocos', (
      tester,
    ) async {
      await abrir(tester, sessao: _ana);

      expect(find.text('AS'), findsOneWidget);
      expect(find.text('Ana Souza'), findsOneWidget);
      expect(find.text('ana.souza@exemplo.com'), findsOneWidget);
      expect(find.text('Minha busca'), findsOneWidget);
      expect(
        find.text('Quantidade padrão de unidades na lista'),
        findsOneWidget,
      );
      expect(find.text('Privacidade'), findsOneWidget);
      expect(find.text('Usar minha localização'), findsOneWidget);
      expect(find.text('Sobre'), findsOneWidget);
      expect(find.text('Versão do app'), findsOneWidget);
      expect(find.text('0.1.0'), findsOneWidget);
      expect(find.text('Entrar ou criar conta'), findsNothing);
    });

    testWidgets('conta sem nome no token mostra "Minha conta"', (tester) async {
      await abrir(tester, sessao: sessaoDeTeste(nome: null));

      expect(find.text('Minha conta'), findsOneWidget);
    });

    testWidgets('escolher 10 guarda a preferência', (tester) async {
      final prefs = PreferenciasFalso();
      await abrir(tester, sessao: _ana, preferencias: prefs);

      await tester.tap(find.text('10'));
      await tester.pump();

      expect(prefs.tamanhoDaLista.value, 10);
    });

    testWidgets('a chave de localização liga e desliga', (tester) async {
      final prefs = PreferenciasFalso();
      await abrir(tester, sessao: _ana, preferencias: prefs);

      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(prefs.usarLocalizacao.value, isFalse);
    });

    testWidgets('"Como calculamos a espera" abre a folha', (tester) async {
      await abrir(tester, sessao: _ana);

      await tester.tap(find.text('Como calculamos a espera'));
      await tester.pumpAndSettle();

      expect(
        find.text('Contamos quantas pessoas estão aguardando agora.'),
        findsOneWidget,
      );
    });

    testWidgets('Sair: confirmar apaga a sessão e avisa a casca do app', (
      tester,
    ) async {
      final armazenamento = SessoesFalso(_ana);
      final auth = AuthFalso();
      final sessoes = SessaoService(auth: auth, armazenamento: armazenamento);
      await sessoes.iniciar();
      var saiu = false;
      await abrir(
        tester,
        sessao: _ana,
        sessoes: sessoes,
        aoSair: () => saiu = true,
      );

      await tocarEmSair(tester);
      expect(find.text('Sair da conta?'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Sair'));
      await tester.pumpAndSettle();

      expect(armazenamento.limpezas, 1);
      expect(armazenamento.guardada, isNull);
      expect(auth.saidas, 1);
      expect(saiu, isTrue);
    });

    testWidgets('Sair: cancelar não apaga nada', (tester) async {
      final armazenamento = SessoesFalso(_ana);
      final auth = AuthFalso();
      final sessoes = SessaoService(auth: auth, armazenamento: armazenamento);
      await sessoes.iniciar();
      var saiu = false;
      await abrir(
        tester,
        sessao: _ana,
        sessoes: sessoes,
        aoSair: () => saiu = true,
      );

      await tocarEmSair(tester);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(armazenamento.limpezas, 0);
      expect(auth.saidas, 0);
      expect(saiu, isFalse);
    });
  });

  group('visitante', () {
    testWidgets('mostra "Visitante" e o botão de entrar, sem Sobre nem Sair', (
      tester,
    ) async {
      var abriuLogin = false;
      await abrir(tester, aoEntrarOuCriarConta: () => abriuLogin = true);

      expect(find.text('Visitante'), findsOneWidget);
      expect(find.text('Seus dados ficam só neste aparelho.'), findsOneWidget);
      expect(find.text('Quantidade de unidades na lista'), findsOneWidget);
      expect(find.text('Minha busca'), findsOneWidget);
      expect(find.text('Privacidade'), findsOneWidget);
      expect(find.text('Sobre'), findsNothing);
      expect(find.text('Sair'), findsNothing);

      await tester.tap(find.text('Entrar ou criar conta'));
      expect(abriuLogin, isTrue);
    });

    testWidgets('também escolhe a quantidade e liga ou desliga a localização', (
      tester,
    ) async {
      final prefs = PreferenciasFalso();
      await abrir(tester, preferencias: prefs);

      await tester.tap(find.text('3'));
      await tester.pump();
      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(prefs.tamanhoDaLista.value, 3);
      expect(prefs.usarLocalizacao.value, isFalse);
    });
  });
}

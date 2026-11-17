import 'package:fe_nexa_app/features/perfil/data/preferencias_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('sem nada guardado: 5 unidades e localização ligada', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = PreferenciasRepositoryLocal();

    await repo.carregar();

    expect(repo.tamanhoDaLista.value, 5);
    expect(repo.usarLocalizacao.value, isTrue);
  });

  test('a escolha fica guardada para a próxima abertura', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = PreferenciasRepositoryLocal();
    await repo.definirTamanhoDaLista(10);
    await repo.definirUsarLocalizacao(false);

    final outraAbertura = PreferenciasRepositoryLocal();
    await outraAbertura.carregar();

    expect(outraAbertura.tamanhoDaLista.value, 10);
    expect(outraAbertura.usarLocalizacao.value, isFalse);
  });

  test('quantidade fora de 3, 5 e 10 é ignorada', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = PreferenciasRepositoryLocal();

    await repo.definirTamanhoDaLista(7);

    expect(repo.tamanhoDaLista.value, 5);
  });

  test('valor guardado inválido volta para o padrão', () async {
    SharedPreferences.setMockInitialValues({'preferencia_tamanho_lista': 99});
    final repo = PreferenciasRepositoryLocal();

    await repo.carregar();

    expect(repo.tamanhoDaLista.value, 5);
  });
}

import 'package:fe_nexa_app/features/unidades/data/favoritas_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('começa vazio', () async {
    final repositorio = FavoritasRepositoryLocal();
    await repositorio.carregar();
    expect(repositorio.ids.value, isEmpty);
  });

  test('carregar lê o que está guardado e ignora lixo', () async {
    SharedPreferences.setMockInitialValues({
      'favoritas_unidades': ['1', '2', 'x'],
    });
    final repositorio = FavoritasRepositoryLocal();
    await repositorio.carregar();
    expect(repositorio.ids.value, {1, 2});
  });

  test('definir liga e desliga, e guarda no aparelho', () async {
    final repositorio = FavoritasRepositoryLocal();

    await repositorio.definir(7, favorita: true);
    await repositorio.definir(9, favorita: true);
    expect(repositorio.ids.value, {7, 9});

    await repositorio.definir(7, favorita: false);
    expect(repositorio.ids.value, {9});

    // Um repositório novo (como se o app tivesse fechado e aberto) lê o mesmo.
    final outro = FavoritasRepositoryLocal();
    await outro.carregar();
    expect(outro.ids.value, {9});
  });

  test('avisa quem escuta a cada mudança', () async {
    final repositorio = FavoritasRepositoryLocal();
    final vistos = <Set<int>>[];
    repositorio.ids.addListener(() => vistos.add(repositorio.ids.value));

    await repositorio.definir(1, favorita: true);
    await repositorio.definir(1, favorita: false);

    expect(vistos, [
      {1},
      <int>{},
    ]);
  });

  test('dois toques seguidos sem esperar não se atropelam', () async {
    final repositorio = FavoritasRepositoryLocal();

    // Sem `await` entre eles: o segundo parte do resultado do primeiro.
    final primeiro = repositorio.definir(1, favorita: true);
    final segundo = repositorio.definir(2, favorita: true);
    await Future.wait([primeiro, segundo]);

    expect(repositorio.ids.value, {1, 2});
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('favoritas_unidades')!.toSet(), {'1', '2'});
  });
}

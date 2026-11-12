import 'package:fe_nexa_app/shared/utils/iniciais.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('primeiro e último nome', () {
    expect(iniciaisDoNome('Ana Souza'), 'AS');
    expect(iniciaisDoNome('Maria da Silva Costa'), 'MC');
  });

  test('nome só com uma palavra', () {
    expect(iniciaisDoNome('Julio'), 'J');
  });

  test('ignora espaços sobrando', () {
    expect(iniciaisDoNome('  ana   souza  '), 'AS');
  });

  test('letra minúscula e acentuada vira maiúscula', () {
    expect(iniciaisDoNome('ágata ôlga'), 'ÁÔ');
  });

  test('nulo ou vazio devolve texto vazio', () {
    expect(iniciaisDoNome(null), '');
    expect(iniciaisDoNome(''), '');
    expect(iniciaisDoNome('   '), '');
  });
}

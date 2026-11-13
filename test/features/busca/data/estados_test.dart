import 'package:fe_nexa_app/features/busca/data/estados.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('são 27 unidades da federação, sem sigla repetida', () {
    expect(estadosDoBrasil, hasLength(27));
    final siglas = estadosDoBrasil.map((e) => e.sigla).toSet();
    expect(siglas, hasLength(27));
  });

  test('toda sigla tem duas letras maiúsculas (o que o Java espera no uf)', () {
    for (final estado in estadosDoBrasil) {
      expect(estado.sigla, matches(RegExp(r'^[A-Z]{2}$')));
    }
  });

  test('a lista está em ordem alfabética pelo nome', () {
    final nomes = estadosDoBrasil.map((e) => e.nome).toList();
    // Compara sem acento: "Amapá" vem depois de "Alagoas" e antes de "Amazonas".
    String semAcento(String s) => s
        .replaceAll('á', 'a')
        .replaceAll('í', 'i')
        .replaceAll('ã', 'a')
        .replaceAll('ê', 'e')
        .replaceAll('ô', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('é', 'e')
        .replaceAll('ó', 'o')
        .replaceAll('ç', 'c');
    final ordenados = [...nomes]
      ..sort((a, b) => semAcento(a).compareTo(semAcento(b)));
    expect(nomes, ordenados);
  });

  test('nomeDoEstado acha pela sigla e devolve nulo se não existir', () {
    expect(nomeDoEstado('SP'), 'São Paulo');
    expect(nomeDoEstado('RJ'), 'Rio de Janeiro');
    expect(nomeDoEstado('XX'), isNull);
    expect(nomeDoEstado(''), isNull);
  });
}

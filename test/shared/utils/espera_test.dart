import 'package:fe_nexa_app/shared/utils/espera.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('nivelDaEspera', () {
    test('até 60 minutos é curta', () {
      expect(nivelDaEspera(0), NivelEspera.curta);
      expect(nivelDaEspera(60), NivelEspera.curta);
    });

    test('acima de 60 e até 180 minutos é média', () {
      expect(nivelDaEspera(60.1), NivelEspera.media);
      expect(nivelDaEspera(180), NivelEspera.media);
    });

    test('acima de 180 minutos é longa', () {
      expect(nivelDaEspera(180.1), NivelEspera.longa);
      expect(nivelDaEspera(400), NivelEspera.longa);
    });

    test('sem número, é "sem dados"', () {
      expect(nivelDaEspera(null), NivelEspera.semDados);
    });
  });

  group('textoDaEspera', () {
    test('menos de 1 minuto', () {
      expect(textoDaEspera(0), 'Menos de 1 min');
      expect(textoDaEspera(0.4), 'Menos de 1 min');
    });

    test('minutos', () {
      expect(textoDaEspera(40), 'Cerca de 40 min');
      expect(textoDaEspera(40.4), 'Cerca de 40 min');
    });

    test('horas cheias', () {
      expect(textoDaEspera(60), 'Cerca de 1 h');
      expect(textoDaEspera(120), 'Cerca de 2 h');
    });

    test('horas e minutos, com zero à esquerda', () {
      expect(textoDaEspera(65), 'Cerca de 1 h 05');
      expect(textoDaEspera(100), 'Cerca de 1 h 40');
    });
  });
}

import 'package:fe_nexa_app/shared/utils/tempo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('textoHaQuantoTempo', () {
    test('menos de 1 minuto', () {
      expect(textoHaQuantoTempo(Duration.zero), 'há menos de 1 min');
      expect(textoHaQuantoTempo(const Duration(seconds: 59)), 'há menos de 1 min');
    });

    test('relógio atrasado (tempo negativo) não quebra', () {
      expect(textoHaQuantoTempo(const Duration(minutes: -5)), 'há menos de 1 min');
    });

    test('minutos', () {
      expect(textoHaQuantoTempo(const Duration(minutes: 1)), 'há 1 min');
      expect(textoHaQuantoTempo(const Duration(minutes: 12)), 'há 12 min');
      expect(textoHaQuantoTempo(const Duration(minutes: 59)), 'há 59 min');
    });

    test('horas', () {
      expect(textoHaQuantoTempo(const Duration(minutes: 60)), 'há 1 h');
      expect(textoHaQuantoTempo(const Duration(hours: 23, minutes: 59)), 'há 23 h');
    });

    test('dias', () {
      expect(textoHaQuantoTempo(const Duration(hours: 24)), 'há 1 d');
      expect(textoHaQuantoTempo(const Duration(days: 3)), 'há 3 d');
    });
  });
}

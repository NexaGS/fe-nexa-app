/// Escreve há quanto tempo algo aconteceu: "há 12 min", "há 2 h", "há 3 d".
String textoHaQuantoTempo(Duration passou) {
  final minutos = passou.inMinutes;
  // Relógio do celular atrasado pode dar tempo negativo: cai aqui também.
  if (minutos < 1) return 'há menos de 1 min';
  if (minutos < 60) return 'há $minutos min';

  final horas = passou.inHours;
  if (horas < 24) return 'há $horas h';
  return 'há ${passou.inDays} d';
}

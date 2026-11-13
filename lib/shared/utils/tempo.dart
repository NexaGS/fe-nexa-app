/// Escreve há quanto tempo algo aconteceu: "há 12 min", "há 2 h", "há 3 d".
///
/// Recebe a [passou] (agora menos a hora do fato) em vez de calcular com o
/// relógio por dentro. Assim o texto é fácil de testar e a tela decide qual
/// é "agora".
String textoHaQuantoTempo(Duration passou) {
  final minutos = passou.inMinutes;
  // Relógio do celular atrasado pode dar tempo negativo: cai aqui também.
  if (minutos < 1) return 'há menos de 1 min';
  if (minutos < 60) return 'há $minutos min';

  final horas = passou.inHours;
  if (horas < 24) return 'há $horas h';
  return 'há ${passou.inDays} d';
}

/// Em que situação está a espera de uma unidade.
enum NivelEspera { curta, media, longa, dadosAntigos, semDados }

/// Até este tempo, em minutos, a espera é curta.
const double limiteEsperaCurtaMin = 60;

/// Até este tempo, em minutos, a espera é média. Acima disso, é longa.
const double limiteEsperaMediaMin = 180;

/// Diz em qual faixa cai a espera, em minutos.
NivelEspera nivelDaEspera(double? minutos) {
  if (minutos == null) return NivelEspera.semDados;
  if (minutos <= limiteEsperaCurtaMin) return NivelEspera.curta;
  if (minutos <= limiteEsperaMediaMin) return NivelEspera.media;
  return NivelEspera.longa;
}

/// Escreve a espera para a pessoa ler: "Cerca de 40 min", "Cerca de 1 h 05".
String textoDaEspera(double minutos) {
  final total = minutos.round();
  if (total < 1) return 'Menos de 1 min';
  if (total < 60) return 'Cerca de $total min';

  final horas = total ~/ 60;
  final resto = total % 60;
  if (resto == 0) return 'Cerca de $horas h';
  return 'Cerca de $horas h ${resto.toString().padLeft(2, '0')}';
}

/// A espera em poucas palavras, para o número grande do detalhe: "40 min",
/// "1 h 05". É o [textoDaEspera] sem o "Cerca de".
String textoCurtoDaEspera(double minutos) {
  final total = minutos.round();
  if (total < 1) return '< 1 min';
  if (total < 60) return '$total min';

  final horas = total ~/ 60;
  final resto = total % 60;
  if (resto == 0) return '$horas h';
  return '$horas h ${resto.toString().padLeft(2, '0')}';
}

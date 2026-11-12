/// Em que situação está a espera de uma unidade.
///
/// Os três primeiros valores são faixas e saem da regra de [nivelDaEspera]
/// (a legenda do Figma: "até 1 hora", "de 1 a 3 horas", "mais de 3 horas").
/// Os dois últimos não são faixas: dizem que o número não é confiável
/// ([dadosAntigos]) ou que ele não existe ([semDados]).
enum NivelEspera { curta, media, longa, dadosAntigos, semDados }

/// Até este tempo, em minutos, a espera é curta.
const double limiteEsperaCurtaMin = 60;

/// Até este tempo, em minutos, a espera é média. Acima disso, é longa.
const double limiteEsperaMediaMin = 180;

/// Diz em qual faixa cai a espera, em minutos.
///
/// `null` quer dizer que o Java não mandou o número: vira [NivelEspera.semDados].
/// Quem decide se o dado está velho ([NivelEspera.dadosAntigos]) é a tela,
/// porque isso depende da hora da última atualização, e não do tempo de espera.
NivelEspera nivelDaEspera(double? minutos) {
  if (minutos == null) return NivelEspera.semDados;
  if (minutos <= limiteEsperaCurtaMin) return NivelEspera.curta;
  if (minutos <= limiteEsperaMediaMin) return NivelEspera.media;
  return NivelEspera.longa;
}

/// Escreve a espera para a pessoa ler: "Cerca de 40 min", "Cerca de 1 h 05".
///
/// O Java devolve um número só (`tempoEspera`), por isso o texto diz "cerca de".
/// Quando o Java passar a devolver uma faixa (mínimo e máximo), é aqui que o
/// texto muda para "30–50 min".
String textoDaEspera(double minutos) {
  final total = minutos.round();
  if (total < 1) return 'Menos de 1 min';
  if (total < 60) return 'Cerca de $total min';

  final horas = total ~/ 60;
  final resto = total % 60;
  if (resto == 0) return 'Cerca de $horas h';
  return 'Cerca de $horas h ${resto.toString().padLeft(2, '0')}';
}

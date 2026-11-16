/// Uma unidade de saúde, como o Java devolve (`UnidadeSaudeResponse`).
class UnidadeResumo {
  const UnidadeResumo({
    required this.id,
    required this.nome,
    this.cep,
    this.logradouro,
    this.numero,
    this.bairro,
    this.tempoEspera,
    this.tipoUnidade,
    this.municipio,
    this.uf,
    this.distanciaKm,
  });

  /// Lê um item de `conteudo` da resposta de `GET /api/unidades/proximas` ou de
  /// `GET /api/unidades`.
  factory UnidadeResumo.fromJson(Map<String, dynamic> json) {
    return UnidadeResumo(
      id: (json['id'] as num).toInt(),
      nome: json['nomeUnidade'] as String,
      cep: json['cep'] as String?,
      logradouro: json['logradouro'] as String?,
      numero: json['numero'] as String?,
      bairro: json['bairro'] as String?,
      // O Java manda 40.0, mas um 40 inteiro também serve: `num` aceita os dois.
      tempoEspera: (json['tempoEspera'] as num?)?.toDouble(),
      tipoUnidade: json['tipoUnidade'] as String?,
      // Só as versões mais novas do Java mandam estes dois: sem eles, nulo.
      municipio: json['municipio'] as String?,
      uf: json['uf'] as String?,
      // Só a busca por proximidade manda a distância; nas outras listas é nulo.
      distanciaKm: (json['distanciaKm'] as num?)?.toDouble(),
    );
  }

  final int id;
  final String nome;
  final String? cep;
  final String? logradouro;
  final String? numero;
  final String? bairro;

  /// Espera atual em minutos. Nulo = o Java não mandou o número.
  final double? tempoEspera;

  /// Código do CNES como o Java escreve: `CENTRO_DE_SAUDE_UNIDADE_BASICA`.
  final String? tipoUnidade;

  /// Cidade e sigla do estado ("São Paulo" e "SP"). Servem à Busca, que mostra
  /// unidades de todos os estados.
  final String? municipio;
  final String? uf;

  /// Distância em km até a pessoa, como o Java calculou. Nulo fora da busca por
  /// proximidade.
  final double? distanciaKm;

  /// O endereço para ler na tela: "Rua das Acácias, 120 · Vila Nova, São
  /// Paulo". Nulo se o Java não mandou nada de endereço.
  String? get endereco {
    final via = _juntar([logradouro, numero], ', ');
    final regiao = _juntar([bairro, municipio], ', ');
    return _juntar([via, regiao], ' · ');
  }

  /// O endereço no formato que os apps de mapa entendem, com CEP e UF para não
  /// confundir cidades parecidas. Nulo se não há endereço.
  String? get enderecoParaRota {
    final via = _juntar([logradouro, numero], ', ');
    final cidade = _juntar([municipio, uf], ' - ');
    return _juntar([via, bairro, cidade, cep], ', ');
  }

  static String? _juntar(List<String?> partes, String separador) {
    final cheias = [
      for (final parte in partes)
        if (parte != null && parte.trim().isNotEmpty) parte.trim(),
    ];
    return cheias.isEmpty ? null : cheias.join(separador);
  }

  /// Linha de baixo do cartão: a distância (quando vem), o bairro e o tipo.
  List<String> get detalhes => _montarDetalhes(comCidade: false);

  /// Igual a [detalhes], com "Cidade, UF" entre o bairro e o tipo. É a linha da
  /// Busca, onde a lista mistura estados e só o bairro não basta.
  List<String> get detalhesComCidade => _montarDetalhes(comCidade: true);

  List<String> _montarDetalhes({required bool comCidade}) {
    final nomeDoBairro = bairro;
    final tipo = tipoUnidade;
    final cidade = comCidade ? _cidadeEUf : null;
    final distancia = distanciaKm;
    return [
      if (distancia != null) textoDaDistancia(distancia),
      if (nomeDoBairro != null && nomeDoBairro.isNotEmpty) nomeDoBairro,
      ?cidade,
      if (tipo != null && tipo.isNotEmpty) rotuloDoTipo(tipo),
    ];
  }

  /// "São Paulo, SP"; só a cidade ou só a sigla se faltar uma; nulo se faltar as duas.
  String? get _cidadeEUf {
    final cidade = municipio;
    final sigla = uf;
    final temCidade = cidade != null && cidade.isNotEmpty;
    final temSigla = sigla != null && sigla.isNotEmpty;
    if (temCidade && temSigla) return '$cidade, $sigla';
    if (temCidade) return cidade;
    if (temSigla) return sigla;
    return null;
  }
}

/// "850 m", "2,4 km", "3 km" ou "13 km": metros abaixo de 1 km, uma casa
/// decimal (só se não for ",0") até 10 km e inteiro daí em diante.
String textoDaDistancia(double km) {
  if (km < 0.1) return 'menos de 100 m';
  if (km < 1) return '${(km * 1000).round()} m';
  if (km < 10) {
    final umaCasa = km.toStringAsFixed(1);
    final texto = umaCasa.endsWith('.0')
        ? umaCasa.substring(0, umaCasa.length - 2)
        : umaCasa.replaceAll('.', ',');
    return '$texto km';
  }
  return '${km.round()} km';
}

/// Posição, na lista, da unidade com a menor espera. `null` quando não há o que
/// destacar.
int? indiceDaMenorEspera(List<UnidadeResumo> unidades) {
  int? indice;
  double? menor;
  // `true` quando já vimos uma espera maior que a menor: só então o selo
  // significa alguma coisa.
  var existeMaior = false;

  for (var posicao = 0; posicao < unidades.length; posicao++) {
    final espera = unidades[posicao].tempoEspera;
    if (espera == null) continue;

    if (menor == null || espera < menor) {
      if (menor != null) existeMaior = true;
      menor = espera;
      indice = posicao;
    } else if (espera > menor) {
      existeMaior = true;
    }
  }

  return existeMaior ? indice : null;
}

/// Nome do tipo de unidade para a pessoa ler. A chave é o código que o Java
/// manda (o enum `TipoUnidade`).
const _rotulosDosTipos = <String, String>{
  'POSTO_DE_SAUDE': 'Posto de saúde',
  'CENTRO_DE_SAUDE_UNIDADE_BASICA': 'Unidade básica de saúde',
  'POLICLINICA': 'Policlínica',
  'HOSPITAL_GERAL': 'Hospital geral',
  'HOSPITAL_ESPECIALIZADO': 'Hospital especializado',
  'UNIDADE_MISTA': 'Unidade mista',
  'PRONTO_SOCORRO_GERAL': 'Pronto-socorro geral',
  'PRONTO_SOCORRO_ESPECIALIZADO': 'Pronto-socorro especializado',
  'CONSULTORIO_ISOLADO': 'Consultório',
  'UNIDADE_MOVEL_FLUVIAL': 'Unidade móvel fluvial',
  'CLINICA_CENTRO_DE_ESPECIALIDADE': 'Clínica de especialidades',
  'UNIDADE_DE_APOIO_DIAGNOSE_E_TERAPIA': 'Apoio a diagnóstico e terapia',
  'UNIDADE_MOVEL_TERRESTRE': 'Unidade móvel terrestre',
  'UNIDADE_MOVEL_PRE_HOSPITALAR': 'Unidade móvel pré-hospitalar',
  'UNIDADE_DE_VIGILANCIA_EM_SAUDE': 'Vigilância em saúde',
  'COOPERATIVA_DE_TRABALHADORES_NA_SAUDE': 'Cooperativa de saúde',
  'CENTRO_DE_PARTO_NORMAL': 'Centro de parto normal',
  'HOSPITAL_DIA_ISOLADO': 'Hospital-dia',
  'CENTRAL_DE_REGULACAO_DE_SERVICOS_DE_SAUDE': 'Central de regulação',
  'LACEN': 'Laboratório central (Lacen)',
  'CENTRAL_DE_GESTAO_EM_SAUDE': 'Central de gestão em saúde',
  'CENTRO_HEMOTERAPICO': 'Centro hemoterápico',
  'CAPS': 'CAPS',
  'NASF': 'NASF',
  'SAUDE_INDIGENA': 'Saúde indígena',
  'PRONTO_ATENDIMENTO': 'Pronto atendimento',
  'TELESSAUDE': 'Telessaúde',
  'CENTRAL_DE_REGULACAO_MEDICA_DAS_URGENCIAS': 'Regulação de urgências',
  'HOME_CARE': 'Atendimento domiciliar',
  'UNIDADE_RESIDENCIAL': 'Unidade residencial',
  'OFICINA_ORTOPEDICA': 'Oficina ortopédica',
  'POLO_DE_PREVENCAO': 'Polo de prevenção',
  'CENTRO_DE_IMUNIZACAO': 'Centro de imunização',
};

/// Traduz o código do tipo. Se o Java ganhar um tipo novo que ainda não está
/// na tabela, escreve o código de forma legível ("Tipo novo") em vez de quebrar.
String rotuloDoTipo(String codigo) {
  final conhecido = _rotulosDosTipos[codigo];
  if (conhecido != null) return conhecido;

  final legivel = codigo.toLowerCase().replaceAll('_', ' ');
  if (legivel.isEmpty) return legivel;
  return legivel[0].toUpperCase() + legivel.substring(1);
}

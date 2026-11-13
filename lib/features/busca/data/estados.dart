/// Um estado do Brasil: a sigla (`SP`) que o Java entende no filtro `uf` e o
/// nome que a pessoa lê.
class EstadoBr {
  const EstadoBr(this.sigla, this.nome);

  final String sigla;
  final String nome;
}

/// Os 26 estados e o Distrito Federal, em ordem alfabética pelo nome.
///
/// A lista é fixa no app (os estados não mudam) em vez de vir do Java. O custo:
/// um estado sem nenhuma unidade cadastrada aparece mesmo assim, e a Busca
/// mostra "Nenhuma unidade encontrada".
const List<EstadoBr> estadosDoBrasil = [
  EstadoBr('AC', 'Acre'),
  EstadoBr('AL', 'Alagoas'),
  EstadoBr('AP', 'Amapá'),
  EstadoBr('AM', 'Amazonas'),
  EstadoBr('BA', 'Bahia'),
  EstadoBr('CE', 'Ceará'),
  EstadoBr('DF', 'Distrito Federal'),
  EstadoBr('ES', 'Espírito Santo'),
  EstadoBr('GO', 'Goiás'),
  EstadoBr('MA', 'Maranhão'),
  EstadoBr('MT', 'Mato Grosso'),
  EstadoBr('MS', 'Mato Grosso do Sul'),
  EstadoBr('MG', 'Minas Gerais'),
  EstadoBr('PA', 'Pará'),
  EstadoBr('PB', 'Paraíba'),
  EstadoBr('PR', 'Paraná'),
  EstadoBr('PE', 'Pernambuco'),
  EstadoBr('PI', 'Piauí'),
  EstadoBr('RJ', 'Rio de Janeiro'),
  EstadoBr('RN', 'Rio Grande do Norte'),
  EstadoBr('RS', 'Rio Grande do Sul'),
  EstadoBr('RO', 'Rondônia'),
  EstadoBr('RR', 'Roraima'),
  EstadoBr('SC', 'Santa Catarina'),
  EstadoBr('SP', 'São Paulo'),
  EstadoBr('SE', 'Sergipe'),
  EstadoBr('TO', 'Tocantins'),
];

/// O nome do estado de uma sigla, ou `null` se a sigla não existir.
String? nomeDoEstado(String sigla) {
  for (final estado in estadosDoBrasil) {
    if (estado.sigla == sigla) return estado.nome;
  }
  return null;
}

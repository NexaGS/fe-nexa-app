import 'package:fe_nexa_app/features/unidades/data/unidade_resumo.dart';
import 'package:flutter_test/flutter_test.dart';

UnidadeResumo _unidade(int id, double? espera) =>
    UnidadeResumo(id: id, nome: 'Unidade $id', tempoEspera: espera);

void main() {
  group('UnidadeResumo.fromJson', () {
    test('lê todos os campos do exemplo do Swagger', () {
      final unidade = UnidadeResumo.fromJson({
        'id': 1,
        'nomeUnidade': 'UBS Bela Vista - Paulista',
        'cep': '01311000',
        'logradouro': 'Avenida Paulista',
        'numero': '1100',
        'bairro': 'Bela Vista',
        'tempoEspera': 40.0,
        'tipoUnidade': 'CENTRO_DE_SAUDE_UNIDADE_BASICA',
      });

      expect(unidade.id, 1);
      expect(unidade.nome, 'UBS Bela Vista - Paulista');
      expect(unidade.cep, '01311000');
      expect(unidade.logradouro, 'Avenida Paulista');
      expect(unidade.numero, '1100');
      expect(unidade.bairro, 'Bela Vista');
      expect(unidade.tempoEspera, 40.0);
      expect(unidade.tipoUnidade, 'CENTRO_DE_SAUDE_UNIDADE_BASICA');
    });

    test('lê o município e a UF, que o Java manda para a Busca', () {
      final unidade = UnidadeResumo.fromJson({
        'id': 1,
        'nomeUnidade': 'UPA Carioca - Centro',
        'municipio': 'Rio de Janeiro',
        'uf': 'RJ',
      });

      expect(unidade.municipio, 'Rio de Janeiro');
      expect(unidade.uf, 'RJ');
    });

    test('Java antigo, sem município nem UF: ficam nulos', () {
      final unidade = UnidadeResumo.fromJson({'id': 1, 'nomeUnidade': 'A'});
      expect(unidade.municipio, isNull);
      expect(unidade.uf, isNull);
    });

    test('tempoEspera inteiro (40) também vira double', () {
      final unidade = UnidadeResumo.fromJson({
        'id': 1,
        'nomeUnidade': 'A',
        'tempoEspera': 40,
      });
      expect(unidade.tempoEspera, 40.0);
    });

    test('campos opcionais ausentes ficam nulos', () {
      final unidade = UnidadeResumo.fromJson({'id': 1, 'nomeUnidade': 'A'});
      expect(unidade.bairro, isNull);
      expect(unidade.tempoEspera, isNull);
      expect(unidade.tipoUnidade, isNull);
    });

    test('sem id ou sem nome, lança TypeError', () {
      expect(
        () => UnidadeResumo.fromJson({'nomeUnidade': 'A'}),
        throwsA(isA<TypeError>()),
      );
      expect(
        () => UnidadeResumo.fromJson({'id': 1}),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('detalhes', () {
    test('bairro e tipo, nessa ordem', () {
      const unidade = UnidadeResumo(
        id: 1,
        nome: 'A',
        bairro: 'Bela Vista',
        tipoUnidade: 'POLICLINICA',
      );
      expect(unidade.detalhes, ['Bela Vista', 'Policlínica']);
    });

    test('sem bairro nem tipo, a lista é vazia', () {
      expect(const UnidadeResumo(id: 1, nome: 'A').detalhes, isEmpty);
      expect(
        const UnidadeResumo(id: 1, nome: 'A', bairro: '').detalhes,
        isEmpty,
      );
    });
  });

  group('detalhesComCidade', () {
    test('bairro, "Cidade, UF" e tipo, nessa ordem', () {
      const unidade = UnidadeResumo(
        id: 1,
        nome: 'A',
        bairro: 'Centro',
        municipio: 'Rio de Janeiro',
        uf: 'RJ',
        tipoUnidade: 'PRONTO_ATENDIMENTO',
      );
      expect(unidade.detalhesComCidade, [
        'Centro',
        'Rio de Janeiro, RJ',
        'Pronto atendimento',
      ]);
    });

    test('os detalhes da Home não ganham a cidade', () {
      const unidade = UnidadeResumo(
        id: 1,
        nome: 'A',
        bairro: 'Centro',
        municipio: 'Rio de Janeiro',
        uf: 'RJ',
      );
      expect(unidade.detalhes, ['Centro']);
    });

    test('só a cidade ou só a UF, se faltar uma das duas', () {
      const soCidade = UnidadeResumo(id: 1, nome: 'A', municipio: 'Belém');
      const soUf = UnidadeResumo(id: 2, nome: 'B', uf: 'PA');
      expect(soCidade.detalhesComCidade, ['Belém']);
      expect(soUf.detalhesComCidade, ['PA']);
    });

    test('texto vazio conta como ausente', () {
      const unidade = UnidadeResumo(id: 1, nome: 'A', municipio: '', uf: '');
      expect(unidade.detalhesComCidade, isEmpty);
    });
  });

  group('rotuloDoTipo', () {
    test('traduz um código conhecido, com acento', () {
      expect(
        rotuloDoTipo('CENTRO_DE_SAUDE_UNIDADE_BASICA'),
        'Unidade básica de saúde',
      );
    });

    test('código novo vira texto legível em vez de quebrar', () {
      expect(rotuloDoTipo('TIPO_NOVO_DO_CNES'), 'Tipo novo do cnes');
    });
  });

  group('indiceDaMenorEspera', () {
    test('aponta a de menor espera, sem depender de onde ela está', () {
      expect(indiceDaMenorEspera([_unidade(1, 10), _unidade(2, 40)]), 0);
      expect(indiceDaMenorEspera([_unidade(1, 40), _unidade(2, 10)]), 1);
      expect(
        indiceDaMenorEspera([_unidade(1, 200), _unidade(2, 40), _unidade(3, 90)]),
        1,
      );
    });

    test('em empate pela menor espera, vale a primeira (a mais perto)', () {
      expect(
        indiceDaMenorEspera([_unidade(1, 30), _unidade(2, 10), _unidade(3, 10)]),
        1,
      );
    });

    test('todas empatadas: não há o que destacar', () {
      expect(indiceDaMenorEspera([_unidade(1, 0), _unidade(2, 0)]), isNull);
    });

    test('uma unidade só: não há com quem comparar', () {
      expect(indiceDaMenorEspera([_unidade(1, 15)]), isNull);
    });

    test('ignora quem não tem tempo de espera', () {
      expect(
        indiceDaMenorEspera([_unidade(1, null), _unidade(2, 40), _unidade(3, 90)]),
        1,
      );
      expect(indiceDaMenorEspera([_unidade(1, null), _unidade(2, 5)]), isNull);
      expect(indiceDaMenorEspera([_unidade(1, null), _unidade(2, null)]), isNull);
    });

    test('lista vazia: nada a destacar', () {
      expect(indiceDaMenorEspera(<UnidadeResumo>[]), isNull);
    });
  });

  group('distanciaKm', () {
    test('lê a distância do JSON e a põe primeiro nos detalhes', () {
      final unidade = UnidadeResumo.fromJson({
        'id': 1,
        'nomeUnidade': 'A',
        'bairro': 'Bela Vista',
        'tipoUnidade': 'POLICLINICA',
        'distanciaKm': 2.4,
      });
      expect(unidade.distanciaKm, 2.4);
      expect(unidade.detalhes, ['2,4 km', 'Bela Vista', 'Policlínica']);
    });

    test('sem distanciaKm no JSON, fica nula e some dos detalhes', () {
      final unidade = UnidadeResumo.fromJson({
        'id': 1,
        'nomeUnidade': 'A',
        'bairro': 'Bela Vista',
      });
      expect(unidade.distanciaKm, isNull);
      expect(unidade.detalhes, ['Bela Vista']);
    });

    test('um número inteiro também serve', () {
      final unidade = UnidadeResumo.fromJson({
        'id': 1,
        'nomeUnidade': 'A',
        'distanciaKm': 3,
      });
      expect(unidade.distanciaKm, 3.0);
    });
  });

  group('textoDaDistancia', () {
    test('metros, uma casa decimal e inteiro', () {
      expect(textoDaDistancia(0.05), 'menos de 100 m');
      expect(textoDaDistancia(0.85), '850 m');
      expect(textoDaDistancia(2.4), '2,4 km');
      expect(textoDaDistancia(3), '3 km');
      expect(textoDaDistancia(13.2), '13 km');
      expect(textoDaDistancia(2556.6), '2557 km');
    });
  });

  group('endereco', () {
    const completa = UnidadeResumo(
      id: 1,
      nome: 'A',
      cep: '01311000',
      logradouro: 'Rua das Acácias',
      numero: '120',
      bairro: 'Vila Nova',
      municipio: 'São Paulo',
      uf: 'SP',
    );

    test('para ler: rua, número, bairro e cidade', () {
      expect(completa.endereco, 'Rua das Acácias, 120 · Vila Nova, São Paulo');
    });

    test('para a rota: com UF e CEP', () {
      expect(
        completa.enderecoParaRota,
        'Rua das Acácias, 120, Vila Nova, São Paulo - SP, 01311000',
      );
    });

    test('partes vazias ou nulas somem; sem nada, é nulo', () {
      const parcial = UnidadeResumo(id: 1, nome: 'A', bairro: 'Centro', numero: '');
      expect(parcial.endereco, 'Centro');
      expect(const UnidadeResumo(id: 1, nome: 'A').endereco, isNull);
      expect(const UnidadeResumo(id: 1, nome: 'A').enderecoParaRota, isNull);
    });
  });
}

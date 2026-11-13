import 'dart:async';
import 'dart:math' as math;

import 'package:fe_nexa_app/app/theme/nexa_theme.dart';
import 'package:fe_nexa_app/features/auth/data/auth_repository.dart'
    show ErroInesperado, SemConexao;
import 'package:fe_nexa_app/features/busca/aba_buscar.dart';
import 'package:fe_nexa_app/features/busca/data/catalogo_repository.dart';
import 'package:fe_nexa_app/features/unidades/data/favoritas_repository.dart';
import 'package:fe_nexa_app/features/unidades/data/unidade_resumo.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_bottom_nav.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Galeria da aba Buscar: cada estado do Figma, sem precisar do Java.
void main() => runApp(const _GaleriaBuscar());

enum _Cenario {
  catalogo('Catálogo'),
  carregando('Carregando'),
  erroDoServidor('Erro do servidor'),
  semInternet('Sem internet'),
  falhaAoCarregarMais('Falha ao carregar mais'),
  catalogoVazio('Nenhuma unidade cadastrada');

  const _Cenario(this.rotulo);

  final String rotulo;
}

/// 23 unidades, já em ordem alfabética pelo nome (a ordem do Java).
const _unidades = [
  UnidadeResumo(
    id: 1,
    nome: 'Hospital Gaúcho',
    bairro: 'Centro Histórico',
    municipio: 'Porto Alegre',
    uf: 'RS',
    tipoUnidade: 'HOSPITAL_GERAL',
    tempoEspera: 70,
  ),
  UnidadeResumo(
    id: 2,
    nome: 'Hospital Goiabada',
    bairro: 'Mateo Bei',
    municipio: 'São Paulo',
    uf: 'SP',
    tipoUnidade: 'HOSPITAL_GERAL',
    tempoEspera: 20,
  ),
  UnidadeResumo(
    id: 3,
    nome: 'Hospital Santo Amaro',
    bairro: 'Santo Amaro',
    municipio: 'São Paulo',
    uf: 'SP',
    tipoUnidade: 'HOSPITAL_GERAL',
    tempoEspera: 40,
  ),
  UnidadeResumo(
    id: 4,
    nome: 'UBS Abobrinha',
    bairro: 'Maria Cursi',
    municipio: 'São Paulo',
    uf: 'SP',
    tipoUnidade: 'CENTRO_DE_SAUDE_UNIDADE_BASICA',
    tempoEspera: 45,
  ),
  UnidadeResumo(
    id: 5,
    nome: 'UBS Baiana',
    bairro: 'Vitória',
    municipio: 'Salvador',
    uf: 'BA',
    tipoUnidade: 'CENTRO_DE_SAUDE_UNIDADE_BASICA',
    tempoEspera: 25,
  ),
  UnidadeResumo(
    id: 6,
    nome: 'UBS Bela Vista - Paulista',
    bairro: 'Bela Vista',
    municipio: 'São Paulo',
    uf: 'SP',
    tipoUnidade: 'CENTRO_DE_SAUDE_UNIDADE_BASICA',
    tempoEspera: 40,
  ),
  UnidadeResumo(
    id: 7,
    nome: 'UBS Mineira',
    bairro: 'Centro',
    municipio: 'Belo Horizonte',
    uf: 'MG',
    tipoUnidade: 'CENTRO_DE_SAUDE_UNIDADE_BASICA',
    tempoEspera: 50,
  ),
  UnidadeResumo(
    id: 8,
    nome: 'UBS Tatuapé',
    bairro: 'Tatuapé',
    municipio: 'São Paulo',
    uf: 'SP',
    tipoUnidade: 'CENTRO_DE_SAUDE_UNIDADE_BASICA',
    tempoEspera: 25,
  ),
  UnidadeResumo(
    id: 9,
    nome: 'UBS Vila Romana',
    bairro: 'Vila Romana',
    municipio: 'São Paulo',
    uf: 'SP',
    tipoUnidade: 'CENTRO_DE_SAUDE_UNIDADE_BASICA',
    tempoEspera: 10,
  ),
  UnidadeResumo(
    id: 10,
    nome: 'Unidade A',
    bairro: 'São Mateus',
    municipio: 'São Paulo',
    uf: 'SP',
    tipoUnidade: 'CENTRO_DE_SAUDE_UNIDADE_BASICA',
    tempoEspera: 90,
  ),
  UnidadeResumo(
    id: 11,
    nome: 'UPA Carioca',
    bairro: 'Centro',
    municipio: 'Rio de Janeiro',
    uf: 'RJ',
    tipoUnidade: 'PRONTO_ATENDIMENTO',
    tempoEspera: 35,
  ),
  UnidadeResumo(
    id: 12,
    nome: 'UPA Jabuticaba',
    bairro: 'São Mateus',
    municipio: 'São Paulo',
    uf: 'SP',
    tipoUnidade: 'PRONTO_ATENDIMENTO',
    tempoEspera: 15,
  ),
  UnidadeResumo(
    id: 13,
    nome: 'UPA Tiradentes',
    bairro: 'Luz',
    municipio: 'São Paulo',
    uf: 'SP',
    tipoUnidade: 'PRONTO_ATENDIMENTO',
    tempoEspera: 60,
  ),
  UnidadeResumo(
    id: 14,
    nome: 'UPA Vila Mariana',
    bairro: 'Vila Mariana',
    municipio: 'São Paulo',
    uf: 'SP',
    tipoUnidade: 'PRONTO_ATENDIMENTO',
    tempoEspera: 30,
  ),
  UnidadeResumo(
    id: 15,
    nome: 'Posto de Saúde Aurora',
    bairro: 'Aurora',
    municipio: 'Campinas',
    uf: 'SP',
  ),
  UnidadeResumo(
    id: 16,
    nome: 'Posto de Saúde Boa Vista',
    bairro: 'Boa Vista',
    municipio: 'Recife',
    uf: 'PE',
    tempoEspera: 55,
  ),
  UnidadeResumo(
    id: 17,
    nome: 'Posto de Saúde Cidade Nova',
    bairro: 'Cidade Nova',
    municipio: 'Belo Horizonte',
    uf: 'MG',
    tempoEspera: 65,
  ),
  UnidadeResumo(
    id: 18,
    nome: 'Posto de Saúde Estrela',
    bairro: 'Estrela',
    municipio: 'Curitiba',
    uf: 'PR',
    tempoEspera: 15,
  ),
  UnidadeResumo(
    id: 19,
    nome: 'Posto de Saúde Flamboyant',
    bairro: 'Flamboyant',
    municipio: 'Goiânia',
    uf: 'GO',
    tempoEspera: 20,
  ),
  UnidadeResumo(
    id: 20,
    nome: 'Posto de Saúde Girassol',
    bairro: 'Girassol',
    municipio: 'Rio de Janeiro',
    uf: 'RJ',
    tempoEspera: 45,
  ),
  UnidadeResumo(
    id: 21,
    nome: 'Posto de Saúde Horizonte',
    bairro: 'Horizonte',
    municipio: 'Fortaleza',
    uf: 'CE',
    tempoEspera: 35,
  ),
  UnidadeResumo(
    id: 22,
    nome: 'Posto de Saúde Ipê',
    bairro: 'Ipê',
    municipio: 'Salvador',
    uf: 'BA',
    tempoEspera: 25,
  ),
  UnidadeResumo(
    id: 23,
    nome: 'Posto de Saúde Jacarandá',
    bairro: 'Jacarandá',
    municipio: 'São Paulo',
    uf: 'SP',
    tempoEspera: 30,
  ),
];

/// Um Java de mentira: filtra por nome (em qualquer parte, sem ligar para
/// maiúsculas) e por estado, e pagina de verdade.
class _CatalogoDoCenario implements CatalogoRepository {
  _CatalogoDoCenario(this.cenario);

  final _Cenario cenario;
  int _chamadas = 0;
  bool _jaFalhouAoCarregarMais = false;

  @override
  Future<PaginaDeUnidades> pagina({
    String? nome,
    String? uf,
    int pagina = 0,
    int tamanho = 10,
  }) async {
    _chamadas++;
    await Future<void>.delayed(const Duration(milliseconds: 700));

    switch (cenario) {
      case _Cenario.carregando:
        return Completer<PaginaDeUnidades>().future;
      case _Cenario.erroDoServidor:
        if (_chamadas == 1) throw const ErroInesperado();
      case _Cenario.semInternet:
        throw const SemConexao();
      case _Cenario.falhaAoCarregarMais:
        if (pagina == 1 && !_jaFalhouAoCarregarMais) {
          _jaFalhouAoCarregarMais = true;
          throw const SemConexao();
        }
      case _Cenario.catalogoVazio:
        return const PaginaDeUnidades(
          unidades: [],
          pagina: 0,
          totalElementos: 0,
          ultima: true,
        );
      case _Cenario.catalogo:
        break;
    }

    final termo = (nome ?? '').trim().toLowerCase();
    final sigla = (uf ?? '').toUpperCase();
    final filtradas = _unidades
        .where(
          (u) =>
              (termo.isEmpty || u.nome.toLowerCase().contains(termo)) &&
              (sigla.isEmpty || u.uf == sigla),
        )
        .toList();

    final inicio = pagina * tamanho;
    final fim = math.min(inicio + tamanho, filtradas.length);
    return PaginaDeUnidades(
      unidades: inicio >= filtradas.length
          ? const []
          : filtradas.sublist(inicio, fim),
      pagina: pagina,
      totalElementos: filtradas.length,
      ultima: fim >= filtradas.length,
    );
  }
}

/// Favoritas só na memória: somem quando a galeria fecha.
class _FavoritasNaMemoria implements FavoritasRepository {
  final ValueNotifier<Set<int>> _ids = ValueNotifier({2});

  @override
  ValueListenable<Set<int>> get ids => _ids;

  @override
  Future<void> carregar() async {}

  @override
  Future<void> definir(int id, {required bool favorita}) async {
    _ids.value = favorita ? {..._ids.value, id} : ({..._ids.value}..remove(id));
  }
}

class _GaleriaBuscar extends StatefulWidget {
  const _GaleriaBuscar();

  @override
  State<_GaleriaBuscar> createState() => _GaleriaBuscarState();
}

class _GaleriaBuscarState extends State<_GaleriaBuscar> {
  _Cenario _cenario = _Cenario.catalogo;

  late CatalogoRepository _catalogo = _CatalogoDoCenario(_cenario);
  late FavoritasRepository _favoritas = _FavoritasNaMemoria();

  void _escolher(_Cenario cenario) {
    setState(() {
      _cenario = cenario;
      _catalogo = _CatalogoDoCenario(cenario);
      _favoritas = _FavoritasNaMemoria();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Galeria · Buscar',
      debugShowCheckedModeBanner: false,
      theme: buildNexaTheme(),
      home: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    for (final cenario in _Cenario.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cenario.rotulo),
                          selected: cenario == _cenario,
                          onSelected: (_) => _escolher(cenario),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: AbaBuscar(
                  key: ValueKey(_cenario),
                  catalogo: _catalogo,
                  favoritas: _favoritas,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: NexaBottomNav(
          indiceAtual: 1,
          aoSelecionar: (_) {},
        ),
      ),
    );
  }
}

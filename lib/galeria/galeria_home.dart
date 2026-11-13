import 'dart:async';

import 'package:fe_nexa_app/app/theme/nexa_theme.dart';
import 'package:fe_nexa_app/features/auth/data/auth_repository.dart'
    show ErroInesperado, SemConexao;
import 'package:fe_nexa_app/features/home/aba_home.dart';
import 'package:fe_nexa_app/features/home/data/local_repository.dart';
import 'package:fe_nexa_app/features/home/data/localizacao_service.dart';
import 'package:fe_nexa_app/features/unidades/data/favoritas_repository.dart';
import 'package:fe_nexa_app/features/unidades/data/unidade_resumo.dart';
import 'package:fe_nexa_app/features/unidades/data/unidades_repository.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_bottom_nav.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Galeria da aba Home: cada estado do Figma, sem precisar do Java nem do GPS.
void main() => runApp(const _GaleriaHome());

enum _Cenario {
  lista('Lista'),
  carregando('Carregando'),
  erroDoServidor('Erro do servidor'),
  semInternetComDados('Sem internet com dados'),
  semInternetSemDados('Sem internet sem dados'),
  vazio('Nenhuma unidade'),
  gpsDesligado('GPS desligado');

  const _Cenario(this.rotulo);

  final String rotulo;
}

/// Já na ordem em que o Java devolve: da mais perto para a mais longe. Repare
/// que o selo de menor espera cai na Unidade B, e não na primeira.
const _unidades = [
  UnidadeResumo(
    id: 1,
    nome: 'Unidade A',
    bairro: 'Centro',
    tipoUnidade: 'HOSPITAL_GERAL',
    tempoEspera: 215,
  ),
  UnidadeResumo(
    id: 2,
    nome: 'Unidade B',
    bairro: 'Vila Nova',
    tipoUnidade: 'CENTRO_DE_SAUDE_UNIDADE_BASICA',
    tempoEspera: 40,
  ),
  UnidadeResumo(
    id: 3,
    nome: 'Unidade C',
    bairro: 'Bela Vista',
    tipoUnidade: 'PRONTO_ATENDIMENTO',
    tempoEspera: 85,
  ),
  UnidadeResumo(id: 4, nome: 'Unidade E', bairro: 'Mooca'),
];

class _GpsDoCenario implements LocalizacaoService {
  _GpsDoCenario(this.cenario);

  final _Cenario cenario;

  @override
  Future<Posicao> posicaoAtual() async {
    if (cenario == _Cenario.gpsDesligado) throw const GpsDesligado();
    return const Posicao(latitude: -23.56, longitude: -46.65);
  }

  @override
  Future<void> abrirAjustesDoGps() async {}

  @override
  Future<void> abrirAjustesDoApp() async {}
}

class _LocaisDeMentira implements LocalRepository {
  @override
  Future<LocalDescrito> descrever(Posicao posicao) async =>
      const LocalDescrito(bairro: 'Vila Nova', municipio: 'São Paulo');
}

class _UnidadesDoCenario implements UnidadesRepository {
  _UnidadesDoCenario(this.cenario);

  final _Cenario cenario;
  int _chamadas = 0;

  @override
  Future<List<UnidadeResumo>> proximas({
    required double latitude,
    required double longitude,
    int tamanho = 20,
  }) async {
    _chamadas++;
    await Future<void>.delayed(const Duration(milliseconds: 700));

    switch (cenario) {
      case _Cenario.lista:
      case _Cenario.gpsDesligado:
        return _unidades;
      case _Cenario.carregando:
        return Completer<List<UnidadeResumo>>().future;
      case _Cenario.erroDoServidor:
        // Falha na 1ª vez e dá certo no "Tentar de novo".
        if (_chamadas == 1) throw const ErroInesperado();
        return _unidades;
      case _Cenario.semInternetComDados:
        // Carrega na 1ª vez; puxe a lista para baixo e a 2ª falha.
        if (_chamadas == 1) return _unidades;
        throw const SemConexao();
      case _Cenario.semInternetSemDados:
        throw const SemConexao();
      case _Cenario.vazio:
        return const [];
    }
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

class _GaleriaHome extends StatefulWidget {
  const _GaleriaHome();

  @override
  State<_GaleriaHome> createState() => _GaleriaHomeState();
}

class _GaleriaHomeState extends State<_GaleriaHome> {
  _Cenario _cenario = _Cenario.lista;

  late LocalizacaoService _gps = _GpsDoCenario(_cenario);
  late UnidadesRepository _repositorio = _UnidadesDoCenario(_cenario);
  late FavoritasRepository _favoritas = _FavoritasNaMemoria();

  void _escolher(_Cenario cenario) {
    setState(() {
      _cenario = cenario;
      _gps = _GpsDoCenario(cenario);
      _repositorio = _UnidadesDoCenario(cenario);
      _favoritas = _FavoritasNaMemoria();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Galeria · Home',
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
                child: AbaHome(
                  key: ValueKey(_cenario),
                  nome: 'Julio',
                  aoVerTodasAsUnidades: () {},
                  localizacao: _gps,
                  locais: _LocaisDeMentira(),
                  unidades: _repositorio,
                  favoritas: _favoritas,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: NexaBottomNav(
          indiceAtual: 0,
          aoSelecionar: (_) {},
        ),
      ),
    );
  }
}

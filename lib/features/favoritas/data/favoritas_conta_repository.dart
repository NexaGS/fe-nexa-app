import 'dart:async';

import 'package:fe_nexa_app/features/auth/data/auth_repository.dart'
    show SemConexao;
import 'package:fe_nexa_app/features/auth/data/sessao_service.dart';
import 'package:fe_nexa_app/features/favoritas/data/favoritas_remotas.dart';
import 'package:fe_nexa_app/features/unidades/data/favoritas_repository.dart';
import 'package:fe_nexa_app/features/unidades/data/unidade_resumo.dart';
import 'package:flutter/foundation.dart';

abstract interface class FavoritasLista {
  Future<List<UnidadeResumo>> carregarUnidades({
    double? latitude,
    double? longitude,
  });

  Future<UnidadeResumo?> carregarUnidade(int id);
}

class FavoritasRepositoryDaConta
    implements FavoritasRepository, FavoritasLista {
  FavoritasRepositoryDaConta({
    required this._sessoes,
    required this._remotas,
    FavoritasRepositoryLocal? local,
  }) : _local = local ?? FavoritasRepositoryLocal() {
    _sessoes.atual.addListener(_sessaoMudou);
    _ultimaSessaoLogada = _logado;
  }

  final SessaoService _sessoes;
  final FavoritasRemotas _remotas;
  final FavoritasRepositoryLocal _local;

  final ValueNotifier<Set<int>> _ids = ValueNotifier(const {});
  late bool _ultimaSessaoLogada;

  bool get _logado => _sessoes.atual.value != null;

  @override
  ValueListenable<Set<int>> get ids => _ids;

  void _sessaoMudou() {
    if (_logado == _ultimaSessaoLogada) return;
    _ultimaSessaoLogada = _logado;
    unawaited(carregar().catchError((_) {}));
  }

  @override
  Future<void> carregar() async {
    await _local.carregar();

    if (!_logado) {
      _ids.value = _local.ids.value;
      return;
    }

    for (final id in _local.ids.value) {
      try {
        await _remotas.definir(id, favorita: true);
        await _local.definir(id, favorita: false);
      } catch (_) {
      }
    }

    final daConta = await _remotas.listar();
    _ids.value = {
      for (final unidade in daConta) unidade.id,
      ..._local.ids.value,
    };
  }

  @override
  Future<void> definir(int id, {required bool favorita}) async {
    if (!_logado) {
      await _local.definir(id, favorita: favorita);
      _ids.value = _local.ids.value;
      return;
    }

    _ids.value = _comMudanca(_ids.value, id, favorita);
    try {
      await _remotas.definir(id, favorita: favorita);
    } catch (_) {
      _ids.value = _comMudanca(_ids.value, id, !favorita);
      throw const FavoritaNaoSalva();
    }
  }

  @override
  Future<List<UnidadeResumo>> carregarUnidades({
    double? latitude,
    double? longitude,
  }) async {
    if (_logado) {
      return _remotas.listar(latitude: latitude, longitude: longitude);
    }

    await _local.carregar();
    final resultados = await Future.wait([
      for (final id in _local.ids.value) _unidadeOuNulo(id),
    ]);
    return resultados.whereType<UnidadeResumo>().toList();
  }

  @override
  Future<UnidadeResumo?> carregarUnidade(int id) => _unidadeOuNulo(id);

  Future<UnidadeResumo?> _unidadeOuNulo(int id) async {
    try {
      return await _remotas.unidadePorId(id);
    } on SemConexao {
      rethrow;
    } catch (_) {
      return null;
    }
  }

  Set<int> _comMudanca(Set<int> atual, int id, bool favorita) {
    final novo = {...atual};
    if (favorita) {
      novo.add(id);
    } else {
      novo.remove(id);
    }
    return novo;
  }
}

final FavoritasRepositoryDaConta favoritasDaConta = FavoritasRepositoryDaConta(
  sessoes: sessaoService,
  remotas: favoritasRemotas,
);

import 'package:fe_nexa_app/features/favoritas/data/favoritas_conta_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// O aparelho não conseguiu guardar a favorita.
class FavoritaNaoSalva implements Exception {
  const FavoritaNaoSalva();
}

abstract interface class FavoritasRepository {

  ValueListenable<Set<int>> get ids;

  /// Lê o que está guardado no aparelho. Chame uma vez, ao abrir a tela.
  Future<void> carregar();

  Future<void> definir(int id, {required bool favorita});
}

/// Guarda os `id`s em `SharedPreferences` como uma lista de textos: `["12", "40"]`.
class FavoritasRepositoryLocal implements FavoritasRepository {
  static const _chave = 'favoritas_unidades';

  final ValueNotifier<Set<int>> _ids = ValueNotifier(const {});

  @override
  ValueListenable<Set<int>> get ids => _ids;

  @override
  Future<void> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final guardados = prefs.getStringList(_chave) ?? const <String>[];
    _ids.value = guardados.map(int.tryParse).whereType<int>().toSet();
  }

  @override
  Future<void> definir(int id, {required bool favorita}) async {
    // Atualiza a tela antes de gravar: dois toques seguidos não se atropelam
    // e o coração responde na hora.
    _ids.value = _comMudanca(_ids.value, id, favorita);

    try {
      final prefs = await SharedPreferences.getInstance();
      final gravou = await prefs.setStringList(
        _chave,
        _ids.value.map((e) => e.toString()).toList(),
      );
      if (!gravou) throw const FavoritaNaoSalva();
    } catch (_) {
      _ids.value = _comMudanca(_ids.value, id, !favorita);
      throw const FavoritaNaoSalva();
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

final FavoritasRepository favoritasRepository = favoritasDaConta;

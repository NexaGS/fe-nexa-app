import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// O aparelho não conseguiu guardar a favorita.
class FavoritaNaoSalva implements Exception {
  const FavoritaNaoSalva();
}

/// O contrato: as telas favoritam sem saber onde isso fica guardado.
///
/// Hoje as favoritas ficam só no aparelho, para quem tem conta e para
/// visitante. Quando o Java tiver as favoritas da conta (backlog), entra uma
/// segunda implementação e nenhuma tela muda.
abstract interface class FavoritasRepository {
  /// Os `id`s das unidades favoritas. Muda sempre que alguém favorita ou
  /// desfavorita, em qualquer tela. As telas escutam este valor (como o
  /// `useState` compartilhado do React) e se redesenham sozinhas.
  ValueListenable<Set<int>> get ids;

  /// Lê o que está guardado no aparelho. Chame uma vez, ao abrir a tela.
  Future<void> carregar();

  /// Liga ou desliga a favorita de uma unidade. A mudança aparece em [ids] na
  /// hora; se o aparelho não conseguir guardar, volta atrás e lança
  /// [FavoritaNaoSalva].
  Future<void> definir(int id, {required bool favorita});
}

/// Guarda os `id`s em `SharedPreferences` (o "localStorage" do Android/iOS),
/// como uma lista de textos: `["12", "40"]`.
class FavoritasRepositoryLocal implements FavoritasRepository {
  static const _chave = 'favoritas_unidades';

  final ValueNotifier<Set<int>> _ids = ValueNotifier(const {});

  @override
  ValueListenable<Set<int>> get ids => _ids;

  @override
  Future<void> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final guardados = prefs.getStringList(_chave) ?? const <String>[];
    // `tryParse` devolve nulo para lixo; `whereType<int>` descarta esses nulos.
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
      // Desfaz só esta unidade, sem apagar o que mudou enquanto isso.
      _ids.value = _comMudanca(_ids.value, id, !favorita);
      throw const FavoritaNaoSalva();
    }
  }

  /// Uma cópia do conjunto com [id] ligado ou desligado. Sempre uma cópia
  /// nova: o `ValueNotifier` só avisa quando o objeto muda.
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

/// A instância que as telas usam.
final FavoritasRepository favoritasRepository = FavoritasRepositoryLocal();

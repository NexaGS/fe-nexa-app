import 'package:fe_nexa_app/features/perfil/data/preferencias_repository.dart';
import 'package:flutter/foundation.dart';

/// As preferências de mentira: guardam só na memória, sem tocar no aparelho.
class PreferenciasFalso implements PreferenciasRepository {
  PreferenciasFalso({int tamanho = 5, bool localizacao = true})
    : _tamanho = ValueNotifier(tamanho),
      _localizacao = ValueNotifier(localizacao);

  final ValueNotifier<int> _tamanho;
  final ValueNotifier<bool> _localizacao;

  @override
  ValueListenable<int> get tamanhoDaLista => _tamanho;

  @override
  ValueListenable<bool> get usarLocalizacao => _localizacao;

  @override
  Future<void> carregar() async {}

  @override
  Future<void> definirTamanhoDaLista(int quantidade) async =>
      _tamanho.value = quantidade;

  @override
  Future<void> definirUsarLocalizacao(bool usar) async =>
      _localizacao.value = usar;
}

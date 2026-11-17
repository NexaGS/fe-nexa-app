import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// As escolhas da pessoa no Perfil: quantas unidades aparecem nas listas e se o
/// app pode usar a localização. Ficam só neste aparelho, para quem tem conta e
/// para o visitante.
abstract interface class PreferenciasRepository {
  /// Quantas unidades a lista mostra: uma das [opcoesDeTamanho].
  ValueListenable<int> get tamanhoDaLista;

  /// `true` = o app pode usar o GPS para ordenar as unidades por distância.
  ValueListenable<bool> get usarLocalizacao;

  /// Lê o que ficou guardado no aparelho. Chame uma vez, antes de desenhar a
  /// primeira tela.
  Future<void> carregar();

  Future<void> definirTamanhoDaLista(int quantidade);

  Future<void> definirUsarLocalizacao(bool usar);
}

/// As quantidades que o Perfil oferece ("3", "5" e "10").
const opcoesDeTamanho = [3, 5, 10];

/// A quantidade de quem nunca escolheu.
const tamanhoPadraoDaLista = 5;

/// Guarda as escolhas no aparelho com o `shared_preferences`.
class PreferenciasRepositoryLocal implements PreferenciasRepository {
  static const _chaveTamanho = 'preferencia_tamanho_lista';
  static const _chaveLocalizacao = 'preferencia_usar_localizacao';

  final ValueNotifier<int> _tamanho = ValueNotifier(tamanhoPadraoDaLista);
  final ValueNotifier<bool> _localizacao = ValueNotifier(true);

  @override
  ValueListenable<int> get tamanhoDaLista => _tamanho;

  @override
  ValueListenable<bool> get usarLocalizacao => _localizacao;

  @override
  Future<void> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final guardado = prefs.getInt(_chaveTamanho);
    // Um valor fora das opções (arquivo mexido, versão antiga) vira o padrão.
    _tamanho.value = opcoesDeTamanho.contains(guardado)
        ? guardado!
        : tamanhoPadraoDaLista;
    _localizacao.value = prefs.getBool(_chaveLocalizacao) ?? true;
  }

  @override
  Future<void> definirTamanhoDaLista(int quantidade) async {
    if (!opcoesDeTamanho.contains(quantidade)) return;
    // Muda na tela antes de gravar: a escolha responde na hora.
    _tamanho.value = quantidade;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_chaveTamanho, quantidade);
  }

  @override
  Future<void> definirUsarLocalizacao(bool usar) async {
    _localizacao.value = usar;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chaveLocalizacao, usar);
  }
}

/// A instância que as telas usam.
final PreferenciasRepository preferenciasRepository =
    PreferenciasRepositoryLocal();

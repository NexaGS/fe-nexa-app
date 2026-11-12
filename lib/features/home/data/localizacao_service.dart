import 'dart:async';

import 'package:geolocator/geolocator.dart';

/// Um ponto no mapa, no formato que o Java espera.
class Posicao {
  const Posicao({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

/// O GPS do aparelho está desligado.
class GpsDesligado implements Exception {
  const GpsDesligado();
}

/// A pessoa negou a permissão. Dá para pedir de novo.
class PermissaoNegada implements Exception {
  const PermissaoNegada();
}

/// A pessoa marcou "não perguntar de novo". Só ela muda isso, nos ajustes.
class PermissaoNegadaParaSempre implements Exception {
  const PermissaoNegadaParaSempre();
}

/// GPS ligado e permitido, mas não deu posição a tempo (dentro de prédio,
/// por exemplo).
class PosicaoIndisponivel implements Exception {
  const PosicaoIndisponivel();
}

/// O contrato: as telas pedem a posição sem saber que existe o geolocator.
abstract interface class LocalizacaoService {
  Future<Posicao> posicaoAtual();

  /// Abre os ajustes de localização do celular (para ligar o GPS).
  Future<void> abrirAjustesDoGps();

  /// Abre os ajustes do app (para dar a permissão negada "para sempre").
  Future<void> abrirAjustesDoApp();
}

class LocalizacaoServiceGeolocator implements LocalizacaoService {
  @override
  Future<Posicao> posicaoAtual() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const GpsDesligado();
    }

    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }
    // Depois de pedir, o resultado pode vir "deniedForever" direto.
    if (permissao == LocationPermission.deniedForever) {
      throw const PermissaoNegadaParaSempre();
    }
    if (permissao == LocationPermission.denied) {
      throw const PermissaoNegada();
    }

    try {
      final posicao = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 10),
        ),
      );
      return Posicao(
        latitude: posicao.latitude,
        longitude: posicao.longitude,
      );
    } on TimeoutException {
      throw const PosicaoIndisponivel();
    }
  }

  @override
  Future<void> abrirAjustesDoGps() async {
    await Geolocator.openLocationSettings();
  }

  @override
  Future<void> abrirAjustesDoApp() async {
    await Geolocator.openAppSettings();
  }
}

/// A instância que as telas usam. Para testar sem GPS, troque por uma classe
/// que também `implements LocalizacaoService`.
final LocalizacaoService localizacaoService = LocalizacaoServiceGeolocator();

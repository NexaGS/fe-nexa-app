import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// O link do Google Maps com a rota até [destino], saindo de onde a pessoa
/// está. Não precisa de chave de API: o link abre o app do Maps (ou o site).
Uri linkDaRota(String destino) => Uri.https('www.google.com', '/maps/dir/', {
  'api': '1',
  'destination': destino,
});

/// O que o detalhe da unidade faz fora do app. Fica atrás de um contrato para
/// os testes não abrirem o Maps nem a folha de compartilhar de verdade.
abstract interface class AcoesUnidade {
  /// Abre o app de mapas com a rota até [destino]. `false` se não abriu.
  Future<bool> abrirRota(String destino);

  /// Abre a folha de compartilhar do celular com o [texto].
  Future<void> compartilhar(String texto);
}

class AcoesUnidadeDoCelular implements AcoesUnidade {
  const AcoesUnidadeDoCelular();

  @override
  Future<bool> abrirRota(String destino) {
    return launchUrl(linkDaRota(destino), mode: LaunchMode.externalApplication);
  }

  @override
  Future<void> compartilhar(String texto) async {
    await SharePlus.instance.share(ShareParams(text: texto));
  }
}

/// A instância que as telas usam.
const AcoesUnidade acoesUnidade = AcoesUnidadeDoCelular();

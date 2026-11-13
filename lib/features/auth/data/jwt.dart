import 'dart:convert';

/// Lê os dados (claims) de um token JWT, como `nome`, `role` e `exp`.
///
/// O token tem 3 partes separadas por ponto: cabeçalho.dados.assinatura. A do
/// meio é um JSON em base64. Aqui só LEMOS esses dados, para escolher a tela e
/// dar boas-vindas. Quem confere a assinatura e dá permissão de verdade é o
/// Spring.
///
/// Devolve `null` se o texto não for um JWT legível.
Map<String, dynamic>? dadosDoToken(String token) {
  try {
    final partes = token.split('.');
    if (partes.length != 3) return null;
    // "normalize" completa os "=" do final que o base64 do JWT dispensa.
    final miolo = base64Url.normalize(partes[1]);
    final dados = utf8.decode(base64Url.decode(miolo));
    return jsonDecode(dados) as Map<String, dynamic>;
  } catch (_) {
    return null;
  }
}

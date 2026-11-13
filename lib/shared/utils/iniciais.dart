/// As iniciais para o avatar: primeira letra do primeiro nome e do último.
String iniciaisDoNome(String? nomeCompleto) {
  final palavras = (nomeCompleto ?? '')
      .trim()
      .split(RegExp(r'\s+'))
      .where((palavra) => palavra.isNotEmpty)
      .toList();
  if (palavras.isEmpty) return '';

  // `runes` evita cortar no meio uma letra que ocupa dois códigos.
  String primeiraLetra(String palavra) =>
      String.fromCharCode(palavra.runes.first).toUpperCase();

  if (palavras.length == 1) return primeiraLetra(palavras.first);
  return primeiraLetra(palavras.first) + primeiraLetra(palavras.last);
}

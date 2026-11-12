String? primeiroNome(String? nomeCompleto) {
  final texto = nomeCompleto?.trim() ?? '';
  if (texto.isEmpty) return null;
  return texto.split(' ').first;
}
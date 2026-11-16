/// Regras de validação dos formulários de Entrar e Criar conta.
abstract final class Validadores {
  static const senhaMinima = 8;
  static const senhaMaxima = 72;

  static final _formatoEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? nome(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.length < 2) return 'Informe seu nome completo';
    if (texto.length > 100) return 'O nome pode ter até 100 caracteres';
    return null;
  }

  static String? email(String? valor) {
    final texto = valor?.trim() ?? '';
    if (!_formatoEmail.hasMatch(texto) || texto.length > 150) {
      return 'Informe um e-mail válido';
    }
    return null;
  }

  /// Na tela Entrar basta que a senha não esteja vazia.
  static String? senhaDeEntrada(String? valor) {
    if (valor == null || valor.isEmpty) return 'Informe sua senha';
    return null;
  }

  /// Na tela Criar conta vale a regra completa.
  static String? senhaNova(String? valor) {
    final texto = valor ?? '';
    if (texto.length < senhaMinima) {
      return 'A senha precisa ter pelo menos $senhaMinima caracteres';
    }
    if (texto.length > senhaMaxima) {
      return 'A senha pode ter até $senhaMaxima caracteres';
    }
    return null;
  }

  /// Recebe também a senha digitada, para comparar.
  static String? confirmacao(String? valor, String senha) {
    if (valor != senha) return 'As senhas não são iguais';
    return null;
  }
}
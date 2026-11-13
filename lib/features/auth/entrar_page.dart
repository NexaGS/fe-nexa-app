import 'package:fe_nexa_app/features/auth/criar_conta_page.dart';
import 'package:fe_nexa_app/features/auth/data/auth_repository.dart';
import 'package:fe_nexa_app/features/auth/data/sessao_service.dart';
import 'package:fe_nexa_app/features/auth/validadores.dart';
import 'package:fe_nexa_app/features/home/home_page.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_app_bar.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_button.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_snackbar.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_text_field.dart';
import 'package:flutter/material.dart';

class EntrarPage extends StatefulWidget {
  const EntrarPage({super.key});

  @override
  State<EntrarPage> createState() => _EntrarPageState();
}

class _EntrarPageState extends State<EntrarPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();

  bool _carregando = false;

  // Só depois do primeiro toque em "Entrar" os erros passam a atualizar
  // enquanto a pessoa digita. Antes disso, o campo vazio não vira vermelho.
  bool _jaTentou = false;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      setState(() => _jaTentou = true);
      return;
    }

    setState(() => _carregando = true);
    try {
      final sessao = await authRepository.entrar(
        email: _email.text,
        senha: _senha.text,
      );
      await sessaoService.entrou(sessao);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomePage(sessao: sessao)),
        (rota) => false,
      );
    } on CredenciaisInvalidas {
      _avisarErro('E-mail ou senha incorretos. Tente novamente.');
    } on ContaDeColaborador {
      _avisarErro('Esta conta é de colaborador e entra pelo sistema web.');
    } on SemConexao {
      _avisarErro('Sem conexão. Confira a internet e tente de novo.');
    } on ErroInesperado {
      _avisarErro('Algo deu errado. Tente novamente em instantes.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _avisarErro(String mensagem) {
    if (!mounted) return;
    NexaSnackbar.erro(context, mensagem);
  }

  void _esqueciASenha() {
    NexaSnackbar.aviso(context, 'Funcionalidade indisponível no momento.');
  }

  void _abrirCriarConta() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const CriarContaPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NexaAppBar(title: 'Entrar'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Form(
            key: _formKey,
            autovalidateMode: _jaTentou
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NexaTextField(
                  label: 'E-mail',
                  hint: 'nome@exemplo.com',
                  iconName: 'mail',
                  controller: _email,
                  enabled: !_carregando,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validadores.email,
                ),
                const SizedBox(height: 16),
                NexaPasswordField(
                  label: 'Senha',
                  hint: 'Digite sua senha',
                  controller: _senha,
                  enabled: !_carregando,
                  textInputAction: TextInputAction.done,
                  validator: Validadores.senhaDeEntrada,
                  onFieldSubmitted: (_) => _entrar(),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: NexaButton(
                    label: 'Esqueci minha senha',
                    variant: NexaButtonVariant.link,
                    onPressed: _carregando ? null : _esqueciASenha,
                  ),
                ),
                const SizedBox(height: 8),
                NexaButton(
                  label: 'Entrar',
                  labelCarregando: 'Entrando…',
                  carregando: _carregando,
                  onPressed: _entrar,
                ),
                const SizedBox(height: 8),
                Center(
                  child: NexaButton(
                    label: 'Ainda não tenho conta',
                    variant: NexaButtonVariant.link,
                    onPressed: _carregando ? null : _abrirCriarConta,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

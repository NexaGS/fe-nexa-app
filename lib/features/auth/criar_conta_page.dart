import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/features/auth/data/auth_repository.dart';
import 'package:fe_nexa_app/features/auth/validadores.dart';
import 'package:fe_nexa_app/features/home/home_page.dart';
import 'package:fe_nexa_app/shared/widgets/guia_view.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_app_bar.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_button.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_checkbox_field.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_snackbar.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_text_field.dart';
import 'package:flutter/material.dart';

class CriarContaPage extends StatefulWidget {
  const CriarContaPage({super.key});

  @override
  State<CriarContaPage> createState() => _CriarContaPageState();
}

class _CriarContaPageState extends State<CriarContaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _confirmar = TextEditingController();

  bool _carregando = false;

  // Marcado na caixinha de localização. O Spring só cria a conta com `true`.
  bool _aceitouLocalizacao = false;

  // Só depois do primeiro toque em "Criar conta" os erros passam a atualizar
  // enquanto a pessoa digita.
  bool _jaTentou = false;

  // Erro que veio do servidor ("e-mail já cadastrado"), mostrado no campo.
  String? _erroEmail;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  Future<void> _criarConta() async {
    FocusScope.of(context).unfocus(); // fecha o teclado

    if (!_formKey.currentState!.validate()) {
      setState(() => _jaTentou = true);
      return;
    }

    setState(() => _carregando = true);
    try {
      final sessao = await authRepository.registrar(
        nome: _nome.text,
        email: _email.text,
        senha: _senha.text,
        confirmarSenha: _confirmar.text,
        aceitouLocalizacao: _aceitouLocalizacao,
      );
      if (!mounted) return;
      await _mostrarContaCriada();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomePage(nome: sessao.nome)),
        (rota) => false,
      );
    } on EmailJaCadastrado {
      if (!mounted) return;
      setState(() {
        _erroEmail = 'Já existe uma conta com este e-mail. Tente entrar.';
        _jaTentou = true; // a partir daqui os erros acompanham a digitação
        _carregando = false; // reabilita os campos antes de validar de novo
      });
      // Depois que a tela for redesenhada (campos habilitados), roda a
      // validação de novo para o erro do servidor aparecer no campo.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _formKey.currentState?.validate();
      });
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

  Future<void> _mostrarContaCriada() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: NexaColors.scrim,
      builder: (dialogContext) => Dialog(
        backgroundColor: NexaColors.white,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NexaRadius.dialog),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: GuiaView(
                  mood: GuiaMood.sucesso,
                  semanticLabel: 'Guia comemorando',
                  size: 120,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Conta criada', style: NexaText.title),
              const SizedBox(height: 16),
              Text(
                'Agora você já pode comparar unidades perto de você.',
                style: NexaText.body.copyWith(color: NexaColors.inkSoft),
              ),
              const SizedBox(height: 24),
              NexaButton(
                label: 'Começar',
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NexaAppBar(title: 'Criar conta'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Form(
            key: _formKey,
            autovalidateMode: _jaTentou
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NexaTextField(
                  label: 'Nome completo',
                  hint: 'Seu nome e sobrenome',
                  iconName: 'user',
                  controller: _nome,
                  enabled: !_carregando,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: Validadores.nome,
                ),
                const SizedBox(height: 14),
                NexaTextField(
                  label: 'E-mail',
                  hint: 'nome@exemplo.com',
                  iconName: 'mail',
                  controller: _email,
                  enabled: !_carregando,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  // O erro do servidor tem prioridade sobre o de formato.
                  validator: (valor) =>
                      _erroEmail ?? Validadores.email(valor),
                  // Ao editar o e-mail, o erro do servidor deixa de valer.
                  onChanged: (_) {
                    if (_erroEmail != null) setState(() => _erroEmail = null);
                  },
                ),
                const SizedBox(height: 14),
                NexaPasswordField(
                  label: 'Senha',
                  hint: 'Crie uma senha',
                  controller: _senha,
                  enabled: !_carregando,
                  textInputAction: TextInputAction.next,
                  validator: Validadores.senhaNova,
                ),
                const SizedBox(height: 14),
                NexaPasswordField(
                  label: 'Confirmar senha',
                  hint: 'Repita a senha',
                  controller: _confirmar,
                  enabled: !_carregando,
                  textInputAction: TextInputAction.done,
                  validator: (valor) =>
                      Validadores.confirmacao(valor, _senha.text),
                  onFieldSubmitted: (_) => _criarConta(),
                ),
                const SizedBox(height: 8),
                NexaCheckboxField(
                  label: 'Aceito que o Nexa use minha localização para '
                      'mostrar as unidades mais próximas de mim.',
                  enabled: !_carregando,
                  onChanged: (valor) => _aceitouLocalizacao = valor,
                  validator: (valor) => valor == true
                      ? null
                      : 'Para criar a conta, aceite o uso da localização',
                ),
                const SizedBox(height: 16),
                NexaButton(
                  label: 'Criar conta',
                  labelCarregando: 'Criando conta…',
                  carregando: _carregando,
                  onPressed: _criarConta,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

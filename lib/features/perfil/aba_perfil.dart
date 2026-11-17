import 'dart:async';

import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/app/theme/nexa_text.dart';
import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:fe_nexa_app/features/auth/data/auth_repository.dart';
import 'package:fe_nexa_app/features/auth/data/sessao_service.dart';
import 'package:fe_nexa_app/features/perfil/data/preferencias_repository.dart';
import 'package:fe_nexa_app/features/perfil/nexa_avatar.dart';
import 'package:fe_nexa_app/features/perfil/nexa_linha_config.dart';
import 'package:fe_nexa_app/features/perfil/nexa_secao_titulo.dart';
import 'package:fe_nexa_app/features/unidades/nexa_folha_espera.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_button.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_dialogo.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_icon.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_samu_button.dart';
import 'package:fe_nexa_app/shared/widgets/nexa_segmentado.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Aba Perfil: quem está no app, as escolhas da lista, a privacidade e o
/// "Sobre".
///
/// Há dois jeitos, como no Figma:
/// - com conta ([sessao] preenchida): avatar com as iniciais, nome, e-mail, os
///   blocos "Minha busca", "Privacidade" e "Sobre" e o botão "Sair";
/// - visitante ([sessao] nulo): "Visitante", o botão "Entrar ou criar conta" e
///   só os blocos "Minha busca" e "Privacidade".
///
/// Os parâmetros opcionais existem para os testes passarem versões falsas; sem
/// passar nada, a tela usa as reais.
class AbaPerfil extends StatefulWidget {
  const AbaPerfil({
    super.key,
    this.sessao,
    this.aoEntrarOuCriarConta,
    this.aoSair,
    this.preferencias,
    this.sessoes,
    this.versaoDoApp,
  });

  /// Quem está logado. Nulo = visitante.
  final Sessao? sessao;

  /// Leva o visitante para a tela de entrar ou criar conta.
  final VoidCallback? aoEntrarOuCriarConta;

  /// Chamado depois que a sessão foi encerrada: quem monta a casca do app leva a
  /// pessoa de volta para o Início.
  final VoidCallback? aoSair;

  final PreferenciasRepository? preferencias;
  final SessaoService? sessoes;

  /// Lê a versão do app. Nulo = a versão do pacote instalado.
  final Future<String> Function()? versaoDoApp;

  @override
  State<AbaPerfil> createState() => _AbaPerfilState();
}

class _AbaPerfilState extends State<AbaPerfil> {
  PreferenciasRepository get _prefs =>
      widget.preferencias ?? preferenciasRepository;
  SessaoService get _sessoes => widget.sessoes ?? sessaoService;

  String _versao = '';

  @override
  void initState() {
    super.initState();
    // A versão só aparece no "Sobre", que é de quem tem conta.
    if (widget.sessao != null) unawaited(_carregarVersao());
  }

  Future<void> _carregarVersao() async {
    try {
      final leitura = widget.versaoDoApp;
      final versao = leitura != null
          ? await leitura()
          : (await PackageInfo.fromPlatform()).version;
      if (!mounted) return;
      setState(() => _versao = versao);
    } catch (_) {
      // Sem a versão a linha fica sem número; nada mais depende dela.
    }
  }

  Future<void> _pedirParaSair() async {
    final confirmou = await mostrarNexaDialogo(
      context,
      titulo: 'Sair da conta?',
      texto:
          'Suas favoritas continuam guardadas na sua conta e voltam quando '
          'você entrar de novo.',
      rotuloConfirmar: 'Sair',
      rotuloCancelar: 'Cancelar',
      iconName: 'logout',
      destrutivo: true,
    );
    if (!confirmou || !mounted) return;

    await _sessoes.sair();
    if (!mounted) return;
    widget.aoSair?.call();
  }

  @override
  Widget build(BuildContext context) {
    final sessao = widget.sessao;
    final temConta = sessao != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fica parado no alto; só o que vem abaixo rola (frame "Logada Scroll").
          const _Cabecalho(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(
                top: NexaSpacing.xs,
                bottom: NexaSpacing.md,
              ),
              children: [
                _Identidade(sessao: sessao),
                if (!temConta) ...[
                  const SizedBox(height: NexaSpacing.sm),
                  NexaButton(
                    label: 'Entrar ou criar conta',
                    onPressed: widget.aoEntrarOuCriarConta,
                  ),
                ],
                const SizedBox(height: NexaSpacing.md),
                _CartaoMinhaBusca(preferencias: _prefs, temConta: temConta),
                const SizedBox(height: NexaSpacing.sm),
                _CartaoPrivacidade(preferencias: _prefs),
                if (temConta) ...[
                  const SizedBox(height: NexaSpacing.sm),
                  _CartaoSobre(versao: _versao),
                  const SizedBox(height: NexaSpacing.sm),
                  Center(child: _BotaoSair(aoTocar: _pedirParaSair)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Perfil" à esquerda e o botão SAMU à direita.
class _Cabecalho extends StatelessWidget {
  const _Cabecalho();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Perfil',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: NexaText.title,
            ),
          ),
          SizedBox(width: NexaSpacing.sm),
          NexaSamuButton(),
        ],
      ),
    );
  }
}

/// Avatar, nome e e-mail. O visitante vê "Visitante" e o aviso de que os dados
/// ficam só neste aparelho.
class _Identidade extends StatelessWidget {
  const _Identidade({required this.sessao});

  final Sessao? sessao;

  @override
  Widget build(BuildContext context) {
    final conta = sessao;
    final nome = conta?.nome;

    return Row(
      spacing: NexaSpacing.md,
      children: [
        NexaAvatar(nome: nome, visitante: conta == null),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                conta == null ? 'Visitante' : (nome ?? 'Minha conta'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: NexaText.title,
              ),
              Text(
                conta == null
                    ? 'Seus dados ficam só neste aparelho.'
                    : conta.email,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: NexaText.small.copyWith(color: NexaColors.inkSoft),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Moldura dos blocos do Perfil, como no Figma: fundo branco, borda fina de
/// 1 px (a mesma das divisórias), cantos de 20 px e sem sombra. Por dentro, 16
/// de cada lado e 20 em cima e embaixo.
class _Bloco extends StatelessWidget {
  const _Bloco({required this.children, this.espaco = NexaSpacing.sm});

  final List<Widget> children;

  /// Espaço entre os filhos.
  final double espaco;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: NexaSpacing.md,
        vertical: NexaSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: NexaColors.white,
        borderRadius: BorderRadius.circular(NexaRadius.card),
        border: Border.all(color: NexaColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: espaco,
        children: children,
      ),
    );
  }
}

class _CartaoMinhaBusca extends StatelessWidget {
  const _CartaoMinhaBusca({required this.preferencias, required this.temConta});

  final PreferenciasRepository preferencias;
  final bool temConta;

  @override
  Widget build(BuildContext context) {
    return _Bloco(
      children: [
        const NexaSecaoTitulo('Minha busca'),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 6,
          children: [
            Text(
              temConta
                  ? 'Quantidade padrão de unidades na lista'
                  : 'Quantidade de unidades na lista',
              style: NexaText.smallStrong,
            ),
            ValueListenableBuilder<int>(
              valueListenable: preferencias.tamanhoDaLista,
              builder: (context, tamanho, _) => NexaSegmentado(
                opcoes: [for (final n in opcoesDeTamanho) '$n'],
                indiceAtual: opcoesDeTamanho.indexOf(tamanho),
                aoSelecionar: (indice) => unawaited(
                  preferencias.definirTamanhoDaLista(opcoesDeTamanho[indice]),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CartaoPrivacidade extends StatelessWidget {
  const _CartaoPrivacidade({required this.preferencias});

  final PreferenciasRepository preferencias;

  @override
  Widget build(BuildContext context) {
    return _Bloco(
      children: [
        const NexaSecaoTitulo('Privacidade'),
        ValueListenableBuilder<bool>(
          valueListenable: preferencias.usarLocalizacao,
          builder: (context, usar, _) => NexaLinhaConfig(
            titulo: 'Usar minha localização',
            descricao:
                'Só usamos para ordenar unidades por distância. Não '
                'guardamos seu trajeto.',
            ativa: usar,
            aoAlterar: (valor) =>
                unawaited(preferencias.definirUsarLocalizacao(valor)),
          ),
        ),
      ],
    );
  }
}

/// "Sobre": só para quem tem conta.
class _CartaoSobre extends StatelessWidget {
  const _CartaoSobre({required this.versao});

  final String versao;

  @override
  Widget build(BuildContext context) {
    return _Bloco(
      // No Figma o título fica a 4 px das linhas (nos outros blocos, a 12).
      espaco: 4,
      children: [
        const NexaSecaoTitulo('Sobre'),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LinhaSobre(
              iconName: 'help',
              texto: 'Como calculamos a espera',
              fim: const NexaIcon('chevron_right'),
              aoTocar: () => unawaited(mostrarFolhaEspera(context)),
            ),
            const _LinhaSobre(
              iconName: 'flask',
              texto: 'Protótipo demonstrativo · Dados fictícios',
            ),
            _LinhaSobre(
              iconName: 'info',
              texto: 'Versão do app',
              fim: Text(
                versao,
                style: NexaText.small.copyWith(color: NexaColors.inkSoft),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Uma linha do "Sobre": ícone, texto e, à direita, um texto ou seta. Com
/// [aoTocar], a linha toda é um botão.
class _LinhaSobre extends StatelessWidget {
  const _LinhaSobre({
    required this.iconName,
    required this.texto,
    this.fim,
    this.aoTocar,
  });

  final String iconName;
  final String texto;
  final Widget? fim;
  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) {
    final extra = fim;
    final linha = DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: NexaColors.divider)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            spacing: NexaSpacing.md,
            children: [
              NexaIcon(iconName, color: NexaColors.inkSoft),
              Expanded(child: Text(texto, style: NexaText.body)),
              ?extra,
            ],
          ),
        ),
      ),
    );

    if (aoTocar == null) return MergeSemantics(child: linha);
    // O `Material` transparente faz o toque aparecer por cima do fundo branco
    // do bloco; sem ele, a ondinha ficaria escondida atrás da cor.
    return Semantics(
      button: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(onTap: aoTocar, child: linha),
      ),
    );
  }
}

/// "Sair": texto vermelho sublinhado com o ícone de saída.
class _BotaoSair extends StatelessWidget {
  const _BotaoSair({required this.aoTocar});

  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: aoTocar,
      style: TextButton.styleFrom(
        foregroundColor: NexaColors.red,
        minimumSize: const Size(0, NexaSizes.textButtonHeight),
        padding: const EdgeInsets.symmetric(horizontal: NexaSpacing.md),
        shape: const StadiumBorder(),
        textStyle: NexaText.bodyStrong.copyWith(
          decoration: TextDecoration.underline,
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        spacing: NexaSpacing.xs,
        children: [
          NexaIcon('logout', size: 20, color: NexaColors.red),
          Text('Sair'),
        ],
      ),
    );
  }
}

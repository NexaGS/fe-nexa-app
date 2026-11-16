import 'package:fe_nexa_app/app/theme/nexa_tokens.dart';
import 'package:flutter/material.dart';

import '../../app/theme/nexa_colors.dart';
import '../../app/theme/nexa_text.dart';
import 'nexa_icon.dart';

class NexaTextField extends StatelessWidget {
  const NexaTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.iconName,
    this.trailing,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;

  /// ícone sempre a esquerda (iconName é o caminho relativo do icone)
  final String? iconName;

  /// Widget à direita, como o olho da senha.
  final Widget? trailing;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  OutlineInputBorder _borda(Color cor, double largura) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(NexaRadius.input),
      borderSide: BorderSide(color: cor, width: largura)
    );
  }

  @override
  Widget build(BuildContext context) {
    final nomeDoIcone = iconName;
    final corDoTexto = enabled ? NexaColors.ink : NexaColors.inkSoft;

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: NexaText.smallStrong.copyWith(color: corDoTexto)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            enabled: enabled,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            textCapitalization: textCapitalization,
            validator: validator,
            onChanged: onChanged,
            onFieldSubmitted: onFieldSubmitted,
            style: NexaText.body.copyWith(color: corDoTexto),
            cursorColor: NexaColors.ink,
            errorBuilder: (context, mensagem) => _MensagemDeErro(mensagem),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: NexaText.body.copyWith(color: NexaColors.inkSoft),
              filled: true,
              fillColor: enabled ? NexaColors.white : NexaColors.cardBorder,
              contentPadding: EdgeInsets.fromLTRB(
                nomeDoIcone == null ? 16 : 0,
                14,
                16,
                14,
              ),
              prefixIcon: nomeDoIcone == null
                  ? null
                  : Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: NexaIcon(nomeDoIcone, color: NexaColors.inkSoft),
              ),
              prefixIconConstraints: const BoxConstraints(),
              suffixIcon: trailing,
              enabledBorder: _borda(NexaColors.outline, 1),
              focusedBorder: _borda(NexaColors.ink, 2),
              errorBorder: _borda(NexaColors.red, 2),
              focusedErrorBorder: _borda(NexaColors.red, 2),
              disabledBorder: _borda(NexaColors.divider, 1),
            ),
          ),
        ],
    );
  }
}

class _MensagemDeErro extends StatelessWidget {
  const _MensagemDeErro(this.mensagem);

  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NexaIcon('alert', size: 18, color: NexaColors.red),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              mensagem,
              style: NexaText.small.copyWith(
                color: NexaColors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Campo de senha: igual ao [NexaTextField], mas com o texto escondido e um
/// olho à direita para mostrar ou esconder. Precisa ser `StatefulWidget` porque
/// "está escondida?" é uma informação que muda com o toque.
class NexaPasswordField extends StatefulWidget {
  const NexaPasswordField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.enabled = true,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool enabled;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<NexaPasswordField> createState() => _NexaPasswordFieldState();
}

class _NexaPasswordFieldState extends State<NexaPasswordField> {
  bool _oculta = true;

  @override
  Widget build(BuildContext context) {
    return NexaTextField(
      label: widget.label,
      controller: widget.controller,
      hint: widget.hint,
      enabled: widget.enabled,
      obscureText: _oculta,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      trailing: IconButton(
        tooltip: _oculta ? 'Mostrar senha' : 'Ocultar senha',
        onPressed: widget.enabled
            ? () => setState(() => _oculta = !_oculta)
            : null,
        icon: NexaIcon(
          _oculta ? 'eye' : 'eye_off',
          size: 22,
          color: widget.enabled ? NexaColors.ink : NexaColors.inkSoft,
        ),
      ),
    );
  }
}

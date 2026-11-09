# Assets

Tudo que o app carrega em tempo de execução vive em `assets/` e está declarado no `pubspec.yaml`.

```text
assets/
├── fonts/
│   ├── Figtree-Regular.ttf     400
│   ├── Figtree-Medium.ttf      500
│   ├── Figtree-SemiBold.ttf    600
│   ├── Figtree-Bold.ttf        700
│   └── OFL.txt                 licença da fonte
├── guia/
│   ├── lottie/                 6 animações (.json)
│   └── poses/                  6 poses paradas (.svg)
├── icons/                      33 ícones (.svg, 24 px)
└── images/
    └── logo_mark.svg           símbolo da logo
```

Pacotes usados: [`lottie`](https://pub.dev/packages/lottie) para as animações e [`flutter_svg`](https://pub.dev/packages/flutter_svg) para SVG.

## O Guia

Personagem do app, criado a partir do símbolo da logo. O nome "Guia" é provisório.

### Animações

Lottie, 240 x 240, 30 quadros por segundo.

| Arquivo | Duração | Toca | Pose parada | Onde aparece |
| --- | --- | --- | --- | --- |
| `boas_vindas.json` | 4,0 s | repete | `neutro.svg` | Início |
| `carregando.json` | 2,4 s | repete | `esperando.svg` | Lista carregando |
| `vazio.json` | 4,0 s | repete | `procurando.svg` | Nenhuma unidade encontrada |
| `erro.json` | 3,0 s | uma vez | `preocupado.svg` | Erro de servidor |
| `sucesso.json` | 3,0 s | uma vez | `alegre.svg` | Conta criada |
| `favoritar.json` | 2,0 s | uma vez | `icons/heart_filled.svg` | Botão de coração (ao favoritar) |

`olhando.svg` existe como pose, sem animação associada por enquanto.

### Regras de uso

- O Guia aparece **só** em: boas-vindas, carregando, nenhum resultado, erro e sucesso.
- **Nunca** aparece na lista de unidades, no detalhe, no SAMU, em formulários nem em avisos de espera.
- Não reage ao tempo de espera e não fala por balão: o texto da tela diz tudo.
- Quem ligou "remover animações" no celular vê a pose parada (coluna "Pose parada" acima).

### Como carregar

Reduzir movimento: perguntar ao sistema e escolher entre pose e animação.

```dart
final reduzir = MediaQuery.disableAnimationsOf(context);

Semantics(
  label: 'Procurando unidades',
  child: reduzir
      ? SvgPicture.asset('assets/guia/poses/esperando.svg')
      : Lottie.asset('assets/guia/lottie/carregando.json', repeat: true),
)
```

Para as animações que tocam uma vez (`erro`, `sucesso`, `favoritar`), use `repeat: false`.

## Logo

`images/logo_mark.svg`: o símbolo com quatro barras nos pontos cardeais e quatro setas nas diagonais, com a barra superior em `green` e o resto em `ink`. Usado a 36 px ao lado da palavra "Nexa" (estilo `NexaText.wordmark`).

## Ícones

33 arquivos em `assets/icons/`, 24 x 24, traço de 1,75 px com pontas arredondadas, cor `#151C18` (`ink`).

| Grupo | Arquivos |
| --- | --- |
| Navegação | `home`, `search`, `heart`, `user`, `back`, `close`, `chevron_right`, `navigation` |
| Favoritar | `heart`, `heart_filled` (preenchido em `green`) |
| Campos | `mail`, `eye`, `eye_off`, `locate`, `pin` |
| Estado | `check`, `alert`, `info`, `help`, `wifi_off`, `refresh`, `seal_check` |
| Unidade | `walk`, `clock`, `timer`, `users`, `ticket`, `phone`, `history`, `monitor`, `flask` |
| Conta | `logout`, `share`, `user_check` |

Para trocar a cor de um ícone:

```dart
SvgPicture.asset(
  'assets/icons/search.svg',
  width: 24,
  height: 24,
  colorFilter: const ColorFilter.mode(NexaColors.inkSoft, BlendMode.srcIn),
)
```

Observações:

- Os ícones foram **redesenhados** no estilo do conjunto Lucide a partir do protótipo, porque os arquivos originais do Figma não puderam ser baixados. Se o Figma tiver ícones próprios, exporte-os de lá e substitua. Confirme também a licença (Lucide é ISC) antes de publicar.
- Na navegação inferior, o item ativo usa uma versão preenchida do ícone (no protótipo, ele é desenhado na hora). Ao montar a barra, decidir entre ícones extras `*_filled.svg` ou preencher via código.
- `heart_filled.svg` e `seal_check.svg` trazem as próprias cores; não use `colorFilter` neles.

## Fonte

**Figtree**, pesos 400, 500, 600 e 700, em TTF estático. Baixada de <https://github.com/erikdkennedy/figtree> (pasta `fonts/ttf`) em 08/11/2026. Licença SIL Open Font License 1.1, em `assets/fonts/OFL.txt` (a licença exige que acompanhe os arquivos da fonte).

A fonte está embutida no app, então o texto aparece certo mesmo sem internet. Não usamos o pacote `google_fonts`.

## Adicionar um asset novo

1. Colocar o arquivo na pasta certa.
2. Se for uma pasta nova, declará-la em `flutter: assets:` no `pubspec.yaml`.
3. Parar o app e rodar de novo (o hot reload não pega mudanças de assets).
4. Registrar o arquivo neste documento.

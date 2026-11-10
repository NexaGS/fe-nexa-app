# Design system (Porcelana)

Tradução do Figma para código. Tudo aqui vive em `lib/app/theme/`:

| Arquivo | O que tem |
| --- | --- |
| `nexa_colors.dart` | `NexaColors`: paleta |
| `nexa_text.dart` | `NexaText`: estilos de texto (Figtree) |
| `nexa_tokens.dart` | `NexaRadius`, `NexaSpacing`, `NexaSizes`, `NexaShadows` |
| `nexa_theme.dart` | `buildNexaTheme()`: junta cores, fonte e textos no `ThemeData` |

**Regra:** nenhuma tela ou widget escreve cor, tamanho de fonte, raio ou sombra na mão. Se faltar um valor, ele entra primeiro no Figma e depois aqui.

## Cores

| Constante | Hex | Uso |
| --- | --- | --- |
| `ink` | `#151C18` | Texto principal, ícones |
| `inkSoft` | `#566159` | Texto secundário, legendas, ícones inativos |
| `outline` | `#78857D` | Borda de campos e do botão contorno |
| `background` | `#F6F7F3` | Fundo das telas |
| `cardBorder` | `#EEF0E9` | Borda de cartões; fundo de campo desabilitado |
| `divider` | `#E1E5DC` | Linhas divisórias, borda da pílula SAMU, borda de campo desabilitado |
| `white` | `#FFFFFF` | Cartões, campos, barra de navegação |
| `scrim` | `#151C18` a 50% | Fundo escurecido atrás de diálogos e folhas |
| `lime` | `#B7D36B` | Botão primário |
| `primrose` | `#DDEFA4` | Item ativo da navegação, avatar, ação do snackbar |
| `cream` | `#EEF6D5` | Fundo do selo "Menor espera perto de você" |
| `peach` | `#FFE6D3` | Acento do Guia |
| `green` | `#3F6B10` | Espera curta (ponto), coração favoritado, ícone de caminhada |
| `greenDark` | `#2F4F10` | Texto de espera curta, selo |
| `orange` | `#92400E` | Espera média |
| `red` | `#B42318` | Espera longa, erros, ícone do SAMU |
| `slate` | `#4F646B` | "Sem dados recentes" |
| `slateSurface` | `#EEF2F3` | Fundo associado ao `slate` |
| `info` | `#1D5FA8` | Avisos informativos |
| `infoSurface` | `#E3F0FB` | Fundo associado ao `info` |

### Estado da espera

A espera de cada unidade tem sempre ponto colorido **e** texto (a cor nunca é o único sinal):

| Estado | Texto | Ponto | Cor do texto |
| --- | --- | --- | --- |
| Curta | "Espera curta" | `green` | `greenDark` |
| Média | "Espera média" | `orange` | `orange` |
| Longa | "Espera longa" | `red` | `red` |
| Sem dado | "Sem dados recentes" (ícone de ajuda) | — | `slate` |

## Texto

Fonte **Figtree**, pesos 400, 500, 600 e 700, embutida em `assets/fonts/`. O `height` do Flutter é um multiplicador: linha dividida pelo tamanho (34 / 28).

| Estilo | Tamanho / linha | Peso | Extra | Onde |
| --- | --- | --- | --- | --- |
| `display` | 28 / 34 | 700 | tracking -0,56 | Título da tela Início |
| `title` | 22 / 28 | 600 | | Títulos de tela e saudação |
| `waitBand` | 22 / 28 | 600 | tracking -0,22 | Faixa de espera nos cartões |
| `bigNumber` | 44 / 48 | 700 | | Número grande do detalhe |
| `body` | 16 / 24 | 400 | | Texto corrido |
| `bodyMedium` | 16 / 24 | 500 | | Nome do local no cabeçalho |
| `bodyStrong` | 16 / 24 | 600 | | Rótulo de botão, nome da unidade |
| `small` | 14 / 20 | 400 | | Metadados do cartão |
| `smallStrong` | 14 / 20 | 600 | | Rótulos de campo, links, estado da espera |
| `caption` | 12 / 16 | 400 | | Avisos, rótulos da navegação |
| `wordmark` | 21 / 21 | 700 | tracking -0,63 | Palavra "Nexa" |

Variações pontuais (por exemplo, texto de erro 14/20 em peso 500, rótulo ativo da navegação 12/16 em peso 700, ação do snackbar 14/20 em peso 700) saem de um estilo existente com `copyWith`. Se uma variação se repetir, ela vira estilo novo.

Texto secundário não é um estilo: é o mesmo estilo com outra cor.

```dart
Text('Veja quais unidades...', style: NexaText.body.copyWith(color: NexaColors.inkSoft))
```

## Raios

| Constante | Valor | Onde |
| --- | --- | --- |
| `NexaRadius.pill` | 999 | Botões, chips, pílula SAMU, selo |
| `NexaRadius.card` | 20 | Cartões de unidade |
| `NexaRadius.input` | 16 | Campos de texto |
| `NexaRadius.dialog` | 28 | Diálogos |

O snackbar usa raio 12 (valor avulso do Figma; vira constante quando o componente for criado).

## Espaçamentos

Os valores que se repetem no Figma são 8, 12, 16, 20 e 24 (`NexaSpacing.xs` a `xl`). A margem lateral padrão das telas é 24 (`screenPadding`); telas de lista usam 16.

## Tamanhos

| Constante                       | Valor | Onde |
|---------------------------------| --- | --- |
| `buttonHeight`                  | 52 | Botões primário e contorno |
| `textButtonHeight`              | 48 | Botão de texto |
| `inputHeight`                   | 52 | Campos de texto |
| `bottomNavHeight`               | 80 | Barra de navegação inferior |
| `navPillWidth` x `navPillHeight` | 64 x 32 | Pílula do item ativo da navegação |
| `minTouchTarget`                | 44 | Menor área de toque aceitável |
| `heartButton`                   | 48 | Botão de coração |
| `logoMark`                      | 36 | Símbolo da logo |
| `guia`                          | 220 | Guia nas telas |
|`NexaRadius.snackbar`              | 12 | Avisos curtos |

## Sombra

`NexaShadows.card`: `0 1px 1.5px` com a tinta a 6%, usada nos cartões de unidade.

## Como o tema entra no app

`buildNexaTheme()` define a família Figtree, o fundo das telas, um `ColorScheme` claro (primária `lime`, texto `ink`, erro `red`) e mapeia alguns estilos do Material para `NexaText` (`bodyMedium`, `titleLarge`, `labelLarge` etc.), para que widgets padrão já nasçam com a cara do Nexa. O Material 3 é o padrão do Flutter atual, então não há flag para ligar.

## Ao mudar o Figma

1. Atualizar o valor em `NexaColors`, `NexaText` ou `nexa_tokens.dart`.
2. Atualizar a tabela correspondente neste documento.
3. Rodar `flutter analyze` e conferir as telas afetadas.

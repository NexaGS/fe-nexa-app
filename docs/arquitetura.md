# Arquitetura

Como o app Nexa é organizado e por quê. Este documento descreve o que já existe e o que está decidido para o que ainda não existe; o que está em aberto aparece no fim.

## Objetivo

Mostrar, para quem precisa de atendimento, o tempo de espera estimado nas unidades de saúde próximas, para decidir para onde ir antes de sair de casa. O app tem 31 estados de tela no Figma (ver [`telas.md`](telas.md)), com conta opcional: dá para usar sem entrar e guardar favoritas no aparelho.

## Princípios

1. **Interface primeiro, dados de mentira.** Cada tela é construída e testada com dados fixos. Só depois entra o Spring.
2. **Uma pasta por assunto.** Tudo de uma funcionalidade fica junto (`features/<nome>/`). O que várias usam fica em `shared/`.
3. **Estilo em um lugar só.** Cores, textos, raios e tamanhos vêm de `lib/app/theme/`. Nenhuma tela escreve `Color(0x...)` nem `fontSize` na mão.
4. **Acessibilidade desde o começo.** Reduzir movimento, leitor de tela, áreas de toque de pelo menos 44 px, fonte grande.
5. **Poucas dependências.** Hoje só `flutter_svg` e `lottie`. Cada pacote novo entra quando uma tela precisar dele.

## Estrutura de pastas

```text
lib/
├── main.dart                ponto de entrada: chama runApp(NexaApp)
├── app/
│   ├── app.dart             MaterialApp: título, tema e primeira tela
│   └── theme/
│       ├── nexa_colors.dart     paleta Porcelana
│       ├── nexa_text.dart       estilos de texto (Figtree)
│       ├── nexa_tokens.dart     raios, espaçamentos, tamanhos e sombras
│       └── nexa_theme.dart      ThemeData que junta tudo
├── shared/
│   └── widgets/             componentes genéricos (prefixo Nexa)
└── features/
    ├── inicio/              Início
    ├── auth/                Entrar, Criar conta
    ├── unidades/            Lista, Unidade (detalhe)
    ├── busca/               Buscar (campo, itens da lista de locais)
    ├── favoritas/           Favoritas
    └── perfil/              Perfil
```

| Pasta | Regra |
| --- | --- |
| `app/` | Configuração do app inteiro: tema agora, rotas depois. Não tem tela. |
| `shared/widgets/` | Um componente vai para cá quando é claramente genérico (botão, logo, campo) ou quando uma segunda tela passa a usá-lo. Peça de uso único fica dentro da própria feature. |
| `features/<nome>/` | Telas e peças daquele assunto. Quando o Spring entrar, cada feature ganha uma subpasta `data/` (modelos e repositório), sem tocar nas outras. |

## Convenções

- **Arquivos** em `snake_case.dart`; **classes** em `PascalCase`; um widget principal por arquivo.
- **Imports** sempre pelo pacote: `import 'package:fe_nexa_app/app/theme/nexa_colors.dart';`. Nada de `../../`.
- **Prefixo `Nexa`** nos componentes do nosso design (`NexaButton`, `NexaTextField`), para não confundir com `FilledButton`, `TextField` e afins do Flutter.
- **Telas** terminam em `Page` (`InicioPage`); nomes de pasta de feature em português, iguais ao nome da tela no Figma.
- **Textos da interface** em português do Brasil. Identificadores técnicos seguem o vocabulário do Flutter; termos de domínio (Unidade, Favorita) ficam em português.
- **`const`** em tudo que puder. O analisador avisa; aceite a sugestão (`Ctrl+.` no editor).
- **Commits pequenos**, um por componente ou tela, depois de `flutter analyze`.

## Fluxo de dados (planejado)

```text
Tela (Page)  ->  estado da tela  ->  Repositório  ->  fonte de dados
                                                     ├── mock (dados fixos)   <- primeiro
                                                     └── Spring (HTTP)        <- depois
```

A tela nunca sabe de onde os dados vêm. O repositório é uma interface (por exemplo, `UnidadesRepository`) com duas implementações: uma que devolve dados fixos e outra que chama o Spring. Trocar uma pela outra não muda nenhuma tela.

## Integração com o Spring Boot

Ainda não existe contrato da API. Pelas telas, o back-end precisa oferecer pelo menos:

| Capacidade | Telas que dependem |
| --- | --- |
| Criar conta e entrar (com mensagens de erro para e-mail ou senha incorretos) | Criar conta, Entrar |
| Listar unidades próximas com tempo de espera estimado | Lista, Busca |
| Buscar por local e devolver as unidades daquele ponto | Busca |
| Detalhe da unidade e como a espera é calculada | Unidade, Como calculamos |
| Favoritas da conta (guardar e remover na nuvem) | Favoritas |
| Dados do perfil e sair da conta | Perfil |

Visitantes guardam favoritas **no aparelho**; quem tem conta guarda **na nuvem** (é o que o texto da tela Início diz).

Antes de começar essa etapa: definir o formato do JSON de cada resposta, o esquema de autenticação e como o app se comporta sem internet (existe a tela "Lista · sem internet (cache)", ou seja, haverá cache local).

## Decisões

| Tema | Decisão por enquanto | Quando revisar |
| --- | --- | --- |
| Navegação | `Navigator` do próprio Flutter | Se as rotas crescerem, avaliar `go_router` |
| Estado | `setState` e `ValueNotifier` | Quando o compartilhamento de estado entre telas doer (favoritas, usuário logado) |
| HTTP | Não escolhido | Junto com o contrato da API |
| Tema | Material 3 com `ColorScheme.light` e tokens próprios | Se houver modo escuro |
| Fonte | Figtree embutida no app (funciona sem internet) | — |

## Acessibilidade

- **Reduzir movimento:** o Guia consulta `MediaQuery.disableAnimationsOf(context)` e, se verdadeiro, mostra a pose parada em vez da animação (tabela em [`assets.md`](assets.md)).
- **Leitor de tela:** desenhos decorativos ficam fora da árvore de semântica; o Guia leva um rótulo descritivo.
- **Área de toque:** mínimo de 44 px (`NexaSizes.minTouchTarget`).
- **Fonte grande:** as telas precisam aguentar o tamanho de fonte máximo do sistema sem estourar a tela (rolagem quando preciso).
- **Cor não é o único sinal:** o estado de espera sempre vem com texto, não só com a cor.

## Qualidade

- `flutter analyze` sem avisos antes de cada commit.
- `flutter test` para o que for lógica e para o esqueleto de cada tela.
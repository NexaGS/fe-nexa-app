# Nexa — app mobile (Flutter)

Aplicativo para **comparar o tempo de espera em unidades de saúde antes de sair de casa**. Este repositório é o front-end, em Flutter/Dart. O back-end será um serviço Java com Spring Boot, ainda não conectado.

A ordem de trabalho é: interface primeiro, com dados de mentira; só depois a conexão com o Spring. O plano completo está em [`docs/roadmap.md`](docs/roadmap.md).

## Como rodar

Pré-requisitos: Flutter SDK com Dart `^3.12.2` (confira com `flutter --version`) e um celular Android com depuração USB ou um emulador.

```powershell
flutter pub get      # baixa os pacotes (flutter_svg, lottie)
flutter run          # roda no aparelho ou emulador
flutter analyze      # corretor do código; o ideal é "No issues found!"
flutter test         # testes automáticos
```

Mudou o `pubspec.yaml` (pacotes, assets ou fontes)? Pare o app e rode de novo; o hot reload não pega essas mudanças.

## Estrutura

```text
fe-nexa-app/
├── assets/
│   ├── fonts/            Figtree (4 pesos) + licença OFL
│   ├── guia/
│   │   ├── lottie/       animações do Guia (.json)
│   │   └── poses/        poses paradas do Guia (.svg)
│   ├── icons/            ícones (.svg, 24 px)
│   └── images/           logo_mark.svg
├── docs/                 documentação da aplicação
├── lib/
│   ├── main.dart         ponto de entrada
│   ├── app/
│   │   ├── app.dart      MaterialApp (tema e primeira tela)
│   │   └── theme/        cores, textos, tokens e tema
│   ├── shared/
│   │   └── widgets/      componentes usados em várias telas
│   └── features/         uma pasta por assunto
│       ├── inicio/       Início
│       ├── auth/         Entrar, Criar conta
│       ├── unidades/     Lista, Unidade, Busca
│       ├── favoritas/    Favoritas
│       └── perfil/       Perfil
├── test/
└── pubspec.yaml
```

As pastas de `widgets` e `features` ainda estão vazias (só um `.gitkeep`, para o Git enxergá-las). O que vai em cada uma está em [`docs/widgets.md`](docs/widgets.md) e [`docs/telas.md`](docs/telas.md).

## Documentação

| Documento | Conteúdo |
| --- | --- |
| [`docs/arquitetura.md`](docs/arquitetura.md) | Princípios, camadas, convenções, decisões e plano de integração com o Spring |
| [`docs/design-system.md`](docs/design-system.md) | Cores, textos, raios, tamanhos e sombras (Figma para código) |
| [`docs/assets.md`](docs/assets.md) | Guia, logo, ícones, fonte, licenças e como carregar cada tipo |
| [`docs/telas.md`](docs/telas.md) | As 31 telas, nós do Figma, pasta de cada uma e navegação |
| [`docs/widgets.md`](docs/widgets.md) | Catálogo e especificação dos componentes (ainda sem código) |
| [`docs/roadmap.md`](docs/roadmap.md) | Ordem de construção e pontos em aberto |

## Design e protótipo

- Figma: <https://www.figma.com/design/AUXujrUnSnl1BxEcAWHdPm/Untitled> (chave do arquivo `AUXujrUnSnl1BxEcAWHdPm`)

## Licenças dos assets

- **Figtree**: SIL Open Font License 1.1. O texto da licença está em [`assets/fonts/OFL.txt`](assets/fonts/OFL.txt).
- **Ícones**: desenhados no estilo do conjunto Lucide (licença ISC). Confirme a origem antes de publicar o app; ver [`docs/assets.md`](docs/assets.md).
- **Guia e logo**: criação própria do projeto.

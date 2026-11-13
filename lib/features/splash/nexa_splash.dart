import 'dart:math' as math;

import 'package:fe_nexa_app/app/theme/nexa_colors.dart';
import 'package:fe_nexa_app/features/splash/splash_config.dart';
import 'package:flutter/material.dart';

/// Abertura do Nexa: um pulso vira radar, o radar desenha a marca e uma íris
/// clara abre a tela. Cores e velocidade ficam em [SplashConfig].
///
/// Toque na tela para pular. Com "reduzir movimento" ligado no aparelho, mostra
/// só o quadro final.
class NexaSplash extends StatefulWidget {
  const NexaSplash({super.key, required this.destino});

  /// Tela que aparece quando a abertura termina.
  final Widget destino;

  @override
  State<NexaSplash> createState() => _NexaSplashState();
}

class _NexaSplashState extends State<NexaSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controle;
  bool _iniciou = false;
  bool _saiu = false;

  @override
  void initState() {
    super.initState();
    _controle = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds:
            (_SplashPainter.duracao * 1000 / SplashConfig.velocidade).round(),
      ),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) _seguir();
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_iniciou) return;
    _iniciou = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controle.value = 1;
      Future<void>.delayed(const Duration(milliseconds: 600), _seguir);
    } else {
      _controle.forward();
    }
  }

  @override
  void dispose() {
    _controle.dispose();
    super.dispose();
  }

  void _seguir() {
    if (_saiu || !mounted) return;
    _saiu = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => widget.destino,
        transitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (_, animacao, _, filho) =>
            FadeTransition(opacity: animacao, child: filho),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SplashConfig.corInicial,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _seguir,
        child: Semantics(
          label: 'Nexa',
          child: AnimatedBuilder(
            animation: _controle,
            builder: (_, _) => CustomPaint(
              size: Size.infinite,
              painter: _SplashPainter(_controle.value * _SplashPainter.duracao),
            ),
          ),
        ),
      ),
    );
  }
}

class _K {
  const _K(this.t, this.v, [this.curva]);
  final double t;
  final double v;
  final Curve? curva;
}

/// Desenha a abertura num instante [t] (em segundos). A linha do tempo é a
/// mesma do protótipo em SVG aprovado.
class _SplashPainter extends CustomPainter {
  _SplashPainter(this.t);

  final double t;

  static const duracao = 4.0;

  static const _batida1 = 0.30;
  static const _batida2 = 0.52;
  static const _varreduraInicio = 0.75;
  static const _varreduraDur = 1.0;
  static const _irisInicio = 2.0;
  static const _irisDur = 0.95;
  static const _nomeInicio = 2.55;

  static const _raio = 88.0;
  static const _curvaPop = Cubic(0.34, 1.56, 0.64, 1);
  static const _curvaIris = Cubic(0.76, 0, 0.24, 1);
  static const _curvaExpo = Cubic(0.16, 1, 0.3, 1);

  // Marca: centro em (0,0). Barras nos eixos, setas nas diagonais.
  static const _barras = <(String, double, double, double, double, double)>[
    // id, ângulo (° a partir do norte), x1, y1, x2, y2
    ('N', 0, 0, -54, 0, -74),
    ('E', 90, 54, 0, 74, 0),
    ('S', 180, 0, 54, 0, 74),
    ('W', 270, -54, 0, -74, 0),
  ];
  static const _setas = <(double, List<Offset>)>[
    (45, [Offset(57.915, -37.575), Offset(31.815, -31.815), Offset(37.575, -57.915)]),
    (135, [Offset(37.575, 57.915), Offset(31.815, 31.815), Offset(57.915, 37.575)]),
    (225, [Offset(-57.915, 37.575), Offset(-31.815, 31.815), Offset(-37.575, 57.915)]),
    (315, [Offset(-37.575, -57.915), Offset(-31.815, -31.815), Offset(-57.915, -37.575)]),
  ];

  double _fase(double inicio, double dur, [Curve curva = Curves.linear]) =>
      curva.transform(((t - inicio) / dur).clamp(0.0, 1.0));

  double _kf(List<_K> quadros) {
    if (t <= quadros.first.t) return quadros.first.v;
    for (var i = 0; i < quadros.length - 1; i++) {
      final a = quadros[i];
      final b = quadros[i + 1];
      if (t < b.t) {
        final u = (t - a.t) / (b.t - a.t);
        return a.v + (b.v - a.v) * (a.curva ?? Curves.linear).transform(u);
      }
    }
    return quadros.last.v;
  }

  Paint _traco(Color cor, double largura) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = largura
    ..color = cor;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height * 0.45);
    // 1.3 é a escala do protótipo (tela de 390 px de largura).
    final k = 1.3 * (size.shortestSide / 390).clamp(0.85, 1.35);

    canvas.drawRect(Offset.zero & size, Paint()..color = SplashConfig.corInicial);

    canvas.save();
    canvas.translate(centro.dx, centro.dy);
    canvas.scale(k);
    _camadaInicial(canvas, k);
    canvas.restore();

    _camadaClara(canvas, size, centro, k);
  }

  // ---------- fundo colorido: pulso, radar e marca sendo desenhada ----------
  void _camadaInicial(Canvas canvas, double k) {
    final radar = SplashConfig.corRadar;
    final disco = Rect.fromCircle(center: Offset.zero, radius: _raio);

    // Anel-guia, desenhado pela varredura.
    final guia = _fase(_varreduraInicio, _varreduraDur);
    final guiaOp = _kf(const [
      _K(0, 0.5),
      _K(_varreduraInicio + _varreduraDur, 0.5, Curves.easeIn),
      _K(_irisInicio + 0.3, 0),
    ]);
    if (guia > 0 && guiaOp > 0) {
      canvas.drawArc(disco, -math.pi / 2, 2 * math.pi * guia, false,
          _traco(radar.withValues(alpha: guiaOp), 1.5));
    }

    // Ondas do pulso.
    for (final b in const [_batida1, _batida2]) {
      if (t < b) continue;
      final e = const Cubic(0.2, 0.7, 0.3, 1)
          .transform(((t - b - 0.01) / 0.69).clamp(0.0, 1.0));
      final op = 0.55 * (1 - e);
      if (op > 0) {
        canvas.drawCircle(Offset.zero, 10 * (0.4 + 3.8 * e),
            _traco(radar.withValues(alpha: op), 1.5 / k));
      }
    }

    // Varredura do radar.
    final angulo = 360 * _fase(_varreduraInicio, _varreduraDur);
    var opVarredura = 0.0;
    if (t >= _varreduraInicio) {
      final fim = _varreduraInicio + _varreduraDur;
      opVarredura = t <= fim
          ? 1.0
          : 1 - Curves.easeOut.transform(((t - fim) / 0.2).clamp(0.0, 1.0));
    }
    if (opVarredura > 0) {
      final a = angulo * math.pi / 180;
      for (var i = 0; i < 20; i++) {
        final op = 0.34 * math.pow(1 - i / 20, 1.7) * opVarredura;
        final inicio = -math.pi / 2 + a - (i + 1) * 3.2 * math.pi / 180;
        canvas.drawArc(
          disco,
          inicio,
          3.3 * math.pi / 180,
          true,
          Paint()..color = radar.withValues(alpha: op.toDouble()),
        );
      }
      canvas.drawLine(
        Offset.zero,
        Offset(_raio * math.sin(a), -_raio * math.cos(a)),
        _traco(radar.withValues(alpha: 0.95 * opVarredura), 2),
      );
    }

    // Marca: cada peça aparece quando a varredura passa por ela.
    for (final (id, ang, x1, y1, x2, y2) in _barras) {
      final tp = _varreduraInicio + _varreduraDur * ang / 360;
      if (t < tp) continue;
      final pop = _curvaPop.transform(((t - tp) / 0.55).clamp(0.0, 1.0));
      final cor = id == 'N'
          ? radar
          : Color.lerp(radar, SplashConfig.corMarca,
              Curves.easeOut.transform(((t - tp) / 0.7).clamp(0.0, 1.0)))!;
      canvas.save();
      canvas.scale(0.55 + 0.45 * pop);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2),
          _traco(cor.withValues(alpha: pop.clamp(0.0, 1.0)), 11));
      canvas.restore();
    }
    for (final (ang, pontos) in _setas) {
      final tp = _varreduraInicio + _varreduraDur * ang / 360;
      if (t < tp) continue;
      final pop = _curvaPop.transform(((t - tp) / 0.55).clamp(0.0, 1.0));
      final desenho =
          const Cubic(0.65, 0, 0.35, 1).transform(((t - tp) / 0.4).clamp(0.0, 1.0));
      final cor = Color.lerp(radar, SplashConfig.corMarca,
          Curves.easeOut.transform(((t - tp) / 0.7).clamp(0.0, 1.0)))!;
      final caminho = Path()
        ..moveTo(pontos[0].dx, pontos[0].dy)
        ..lineTo(pontos[1].dx, pontos[1].dy)
        ..lineTo(pontos[2].dx, pontos[2].dy);
      final metrica = caminho.computeMetrics().first;
      canvas.save();
      canvas.scale(0.55 + 0.45 * pop);
      canvas.drawPath(metrica.extractPath(0, metrica.length * desenho),
          _traco(cor.withValues(alpha: pop.clamp(0.0, 1.0)), 9));
      canvas.restore();
    }

    // Ponto do pulso (bate duas vezes e some quando a íris começa).
    final escalaPonto = _kf(const [
      _K(0, 1),
      _K(0.25, 1, Cubic(0.2, 0.9, 0.3, 1)),
      _K(0.35, 1.9, Curves.easeInOut),
      _K(0.47, 1, Cubic(0.2, 0.9, 0.3, 1)),
      _K(0.5, 1),
      _K(0.58, 2.5, Curves.easeInOut),
      _K(0.82, 1),
      _K(1.75, 1, Curves.easeIn),
      _K(2.15, 0),
    ]);
    final opPonto = _kf(const [
      _K(0, 1),
      _K(1.75, 1, Curves.easeIn),
      _K(2.15, 0),
    ]);
    if (opPonto > 0) {
      canvas.drawCircle(Offset.zero, 5 * escalaPonto,
          Paint()..color = radar.withValues(alpha: opPonto));
    }
  }

  // ---------- íris clara: marca escura e nome ----------
  void _camadaClara(Canvas canvas, Size size, Offset centro, double k) {
    final e = _fase(_irisInicio, _irisDur, _curvaIris);
    if (e <= 0) return;

    final cantoMaisLonge = [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ].map((c) => (c - centro).distance).reduce(math.max);
    final raio = (cantoMaisLonge + 6) * e;

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: centro, radius: raio)));
    canvas.drawRect(Offset.zero & size, Paint()..color = SplashConfig.corFinal);

    // Marca final (cheia), com uma respirada na barra do norte.
    final respiro = _kf(const [
      _K(0, 11),
      _K(_irisInicio + _irisDur, 11, Curves.easeInOut),
      _K(_irisInicio + _irisDur + 0.25, 16, Curves.easeInOut),
      _K(_irisInicio + _irisDur + 0.7, 11),
    ]);
    canvas.save();
    canvas.translate(centro.dx, centro.dy);
    canvas.scale(k);
    for (final (id, _, x1, y1, x2, y2) in _barras) {
      canvas.drawLine(
        Offset(x1, y1),
        Offset(x2, y2),
        _traco(id == 'N' ? NexaColors.green : NexaColors.ink, id == 'N' ? respiro : 11),
      );
    }
    for (final (_, pontos) in _setas) {
      final caminho = Path()
        ..moveTo(pontos[0].dx, pontos[0].dy)
        ..lineTo(pontos[1].dx, pontos[1].dy)
        ..lineTo(pontos[2].dx, pontos[2].dy);
      canvas.drawPath(caminho, _traco(NexaColors.ink, 9));
    }
    canvas.restore();

    _nome(canvas, size, centro, k / 1.3);
    canvas.restore();

    // Anel de luz na borda da íris.
    canvas.drawCircle(centro, raio,
        _traco(SplashConfig.corRadar.withValues(alpha: (1 - e).clamp(0.0, 1.0)), 2.5));
  }

  /// "Nexa": cada letra sobe de trás de uma linha de base.
  void _nome(Canvas canvas, Size size, Offset centro, double s) {
    const letras = 'Nexa';
    final tamanho = 58 * s;
    final pintores = [
      for (final l in letras.split(''))
        TextPainter(
          text: TextSpan(
            text: l,
            style: TextStyle(
              fontFamily: 'Figtree',
              fontWeight: FontWeight.w700,
              fontSize: tamanho,
              letterSpacing: -0.03 * tamanho,
              color: NexaColors.ink,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(),
    ];
    final largura = pintores.fold<double>(0, (soma, p) => soma + p.width);
    final linhaBase = centro.dy + 188 * s;

    canvas.save();
    canvas.clipRect(
        Rect.fromLTRB(0, linhaBase - 50 * s, size.width, linhaBase + 14 * s));
    var x = centro.dx - largura / 2;
    for (var i = 0; i < pintores.length; i++) {
      final p = pintores[i];
      final sobe = 72 * s * (1 - _fase(_nomeInicio + 0.07 * i, 0.85, _curvaExpo));
      final base = p.computeDistanceToActualBaseline(TextBaseline.alphabetic);
      p.paint(canvas, Offset(x, linhaBase - base + sobe));
      x += p.width;
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SplashPainter antigo) => antigo.t != t;
}

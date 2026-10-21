import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/recipes/data/models/data.dart';
import '../../features/recipes/presentation/controllers/app_state.dart';
import 'theme.dart';

void toast(BuildContext context, String message) {
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(
    content:
        Text(message, style: ts(14, w: FontWeight.w800, color: Colors.white)),
    backgroundColor: Pal.primary,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.fromLTRB(24, 0, 24, 96),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    duration: const Duration(seconds: 2),
  ));
}

String plural(int n, String one, String many) => n <= 1 ? one : many;

// ───────────────────────── Mascotte ─────────────────────────

/// La petite marmite Mijou, dessinée en code (viewBox 72 x 72 du design).
class MijouMascot extends StatelessWidget {
  final double size;
  final bool wink;
  const MijouMascot({super.key, this.size = 72, this.wink = false});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
            painter: _MascotPainter(wink: wink, sparkle: size >= 70)),
      );
}

class _MascotPainter extends CustomPainter {
  final bool wink, sparkle;
  _MascotPainter({required this.wink, required this.sparkle});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 72);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..color = Pal.primary
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    Paint fill(Color c) => Paint()..color = c;

    void oval(double l, double t, double w, double h, Color c) {
      final r = Rect.fromLTWH(l, t, w, h);
      canvas.drawOval(r, fill(c));
      canvas.drawOval(r, line);
    }

    void rrect(double l, double t, double w, double h, double rad, Color c) {
      final r = RRect.fromRectAndRadius(
          Rect.fromLTWH(l, t, w, h), Radius.circular(rad));
      canvas.drawRRect(r, fill(c));
      canvas.drawRRect(r, line);
    }

    // anses
    oval(2.88, 33.12, 17.28, 14.4, Pal.pale);
    oval(51.84, 33.12, 17.28, 14.4, Pal.pale);
    // pieds
    rrect(21.6, 59.04, 6, 8.07, 3, Pal.pale);
    rrect(46.8, 59.04, 6, 8.07, 3, Pal.pale);
    // marmite
    rrect(12.24, 25.2, 47.52, 36, 16, Pal.pale);
    // bouton du couvercle
    oval(30.96, 9.36, 10.08, 9.36, Pal.primary);
    // couvercle
    oval(9.36, 16.56, 53.28, 15.84, const Color(0xFFE6F5EC));

    // visage
    final eye = fill(Pal.ink);
    canvas.drawOval(const Rect.fromLTWH(24.48, 37.44, 3.24, 4.68), eye);
    if (wink) {
      final w = Paint()
        ..style = PaintingStyle.stroke
        ..color = Pal.ink
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(const Offset(44.3, 39.6), const Offset(49.6, 39.6), w);
    } else {
      canvas.drawOval(const Rect.fromLTWH(44.28, 37.44, 3.24, 4.68), eye);
    }
    canvas.drawOval(const Rect.fromLTWH(18, 44.64, 7.2, 3.6), fill(Pal.cheek));
    canvas.drawOval(
        const Rect.fromLTWH(46.8, 44.64, 7.2, 3.6), fill(Pal.cheek));
    final smile = Path()
      ..moveTo(30.24, 46.6)
      ..quadraticBezierTo(36, 53.2, 41.76, 46.6);
    canvas.drawPath(
      smile,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Pal.ink
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );

    if (sparkle) {
      final c = const Offset(4.5, 4.5);
      final star = Path()
        ..moveTo(c.dx, c.dy - 4.5)
        ..quadraticBezierTo(c.dx, c.dy, c.dx + 4.5, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + 4.5)
        ..quadraticBezierTo(c.dx, c.dy, c.dx - 4.5, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - 4.5)
        ..close();
      canvas.drawPath(star, fill(Pal.ink));
    }
  }

  @override
  bool shouldRepaint(covariant _MascotPainter old) => old.wink != wink;
}

// ───────────────────────── Briques ─────────────────────────

/// Photo de recette. Dépose tes images dans assets/images/<id>.png
class PhotoBox extends StatelessWidget {
  final Recipe recipe;
  final double height;
  final double? width;
  final double radius;
  const PhotoBox({
    super.key,
    required this.recipe,
    required this.height,
    this.width,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          height: height,
          width: width ?? double.infinity,
          child: Image.asset(
            recipe.photo,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Pal.pale,
              alignment: Alignment.center,
              child: Text(recipe.emoji,
                  style: TextStyle(fontSize: height > 100 ? 44 : 30)),
            ),
          ),
        ),
      );
}

class Tag extends StatelessWidget {
  final String text;
  final Color bg, fg;
  final Color? border;
  const Tag(this.text,
      {super.key, this.bg = Pal.pale, this.fg = Pal.ink, this.border});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(100),
          border: border == null ? null : Border.all(color: border!),
        ),
        child:
            Text(text, style: ts(14, w: FontWeight.w800, color: fg, h: 1.35)),
      );
}

/// Pastille de filtre sélectionnable.
class FilterChipPill extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const FilterChipPill(this.text,
      {super.key, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? Pal.primary : const Color(0xFFFFF7F8),
            borderRadius: BorderRadius.circular(100),
            border: selected ? null : Border.all(color: Pal.border),
          ),
          child: Text(text,
              style: ts(14,
                  w: FontWeight.w800,
                  color: selected ? Colors.white : Pal.ink,
                  h: 1.35)),
        ),
      );
}

class PillButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? imageAsset;
  final VoidCallback? onTap;
  final bool soft;
  const PillButton(this.label,
      {super.key,
      this.icon,
      this.imageAsset,
      this.onTap,
      this.soft = false});

  @override
  Widget build(BuildContext context) {
    final fg = soft ? Pal.primary : Colors.white;
    return Material(
      color: soft ? Pal.pale : Pal.primary,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: SizedBox(
          height: 54,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(label,
                    overflow: TextOverflow.ellipsis,
                    style: ts(15, w: FontWeight.w800, color: fg, h: 1.35)),
              ),
              if (icon != null || imageAsset != null) ...[
                const SizedBox(width: 10),
                if (imageAsset != null)
                  Image.asset(imageAsset!, width: 22, height: 22)
                else
                  Icon(icon, size: 19, color: fg),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class RoundBtn extends StatelessWidget {
  final double size, iconSize;
  final Color color, iconColor;
  final IconData icon;
  final VoidCallback? onTap;
  final bool outlined;
  const RoundBtn({
    super.key,
    required this.icon,
    this.size = 42,
    this.iconSize = 22,
    this.color = Pal.chip,
    this.iconColor = Pal.primary,
    this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: outlined ? Border.all(color: Pal.border) : null,
          ),
          child: Icon(icon, size: iconSize, color: iconColor),
        ),
      );
}

/// En-tête crème aux coins arrondis en bas.
class PageHeader extends StatelessWidget {
  final String title, subtitle;
  final Widget? leading, trailing;
  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
        decoration: const BoxDecoration(
          color: Pal.cream,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: ts(27, w: FontWeight.w800, h: 1.35)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: ts(14, color: Pal.inkSoft, h: 1.35)),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 12), trailing!],
          ],
        ),
      );
}

/// Barre « mijou » avec avatar (accueil et menu).
class BrandBar extends StatelessWidget {
  final VoidCallback onAvatar;
  const BrandBar({super.key, required this.onAvatar});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Pal.cream,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const MijouMascot(size: 38),
                  const SizedBox(width: 7),
                  Text('mijou',
                      style: ts(29, w: FontWeight.w900, color: Pal.primary)),
                ]),
                GestureDetector(
                  onTap: onAvatar,
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Pal.chip,
                      shape: BoxShape.circle,
                      border: Border.all(color: Pal.primary, width: 1.5),
                    ),
                    child: Text(kUserName[0],
                        style: ts(14, w: FontWeight.w800, color: Pal.primary)),
                  ),
                ),
              ],
            ),
            const Positioned(
              left: 164,
              top: 11,
              child: Icon(Icons.favorite_rounded, size: 16, color: Pal.cheek),
            ),
          ],
        ),
      );
}

// ───────────────────────── Navbar flottante ─────────────────────────

class MijouNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const MijouNavBar({super.key, required this.index, required this.onTap});

  static const _icons = [
    /*Icons.home_rounded,
    Icons.kitchen_rounded,
    Icons.favorite_rounded,
    Icons.shopping_basket_rounded,*/
    'assets/images/home.png',
    'assets/images/frigo.png',
    'assets/images/favourite.png',
    'assets/images/course.png',
  ];
  static const _labels = ['Accueil', 'Mon frigo', 'Favoris', 'Courses'];

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: context.read<AppState>(),
        builder: (context, _) {
          final count = context.read<AppState>().toBuy;
          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Pal.cream,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: shadowNav,
                ),
                child: Row(
                  children: List.generate(4, (i) {
                    final active = i == index;
                    return Expanded(
                      flex: active ? 147 : 66,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onTap(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          height: 52,
                          decoration: BoxDecoration(
                            color: active ? Pal.pale : Colors.transparent,
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              if (active) ...[
                                Positioned(
                                  left: 10,
                                  top: 2,
                                  child: TweenAnimationBuilder<double>(
                                    key: ValueKey('bubble$index'),
                                    tween: Tween(begin: 0.6, end: 1),
                                    duration: const Duration(milliseconds: 450),
                                    curve: Curves.elasticOut,
                                    builder: (_, v, child) =>
                                        Transform.scale(scale: v, child: child),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: const BoxDecoration(
                                        color: Pal.primary,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0x38C73568),
                                            blurRadius: 4,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          _icons[i],
                                          width: 14,
                                          height: 14,
                                          fit: BoxFit.contain,
                                          color: Colors.white,
                                          colorBlendMode: BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 50,
                                  top: 0,
                                  bottom: 0,
                                  right: 4,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(_labels[i],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: ts(14, w: FontWeight.w800)),
                                  ),
                                ),
                              ] else
                                Center(
                                  child: Image.asset(
                                    _icons[i],
                                    width: 26,
                                    height: 26,
                                    fit: BoxFit.contain,
                                    color: Pal.primary,
                                    colorBlendMode: BlendMode.srcIn,
                                  ),
                                ),
                              if (i == 3 && count > 0)
                                Positioned(
                                  top: active ? -8 : 0,
                                  left: active ? 36 : null,
                                  right: active ? null : 6,
                                  child: Container(
                                    width: 19,
                                    height: 19,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Pal.primary,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Pal.cream, width: 2),
                                    ),
                                    child: Text('$count',
                                        style: ts(11,
                                            w: FontWeight.w800,
                                            color: Colors.white)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          );
        },
      );
}

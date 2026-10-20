import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/theme.dart';
import '../../../../core/utils/widgets.dart';
import '../../data/models/data.dart';
import '../controllers/app_state.dart';

void openRecipe(BuildContext context, Recipe r) => Navigator.of(context)
    .push(MaterialPageRoute<void>(builder: (_) => DetailPage(recipe: r)));

// ───────────────────────── Détail d'une recette ─────────────────────────

class DetailPage extends StatefulWidget {
  final Recipe recipe;
  const DetailPage({super.key, required this.recipe});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int _servings = kBaseServings;
  bool _added = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.recipe;
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: context.read<AppState>(),
          builder: (context, _) {
            final s = context.read<AppState>();
            final miss = s.missing(r);
            final have = r.ings.where((i) => s.has(i.key)).toList();
            final fav = s.favorites.contains(r.id);
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              children: [
                // actions
                SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(Icons.arrow_back_rounded,
                            size: 22, color: Pal.primary),
                      ),
                      Text(r.kicker, style: ts(14, h: 1.35)),
                      RoundBtn(
                        size: 40,
                        color: Pal.pale,
                        icon: fav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        onTap: () => s.toggleFav(r.id),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 21),
                Stack(
                  children: [
                    PhotoBox(recipe: r, height: 219),
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: Tag(r.badge, bg: Pal.card, border: Pal.border),
                    ),
                  ],
                ),
                const SizedBox(height: 21),
                Text(r.name, style: ts(28, w: FontWeight.w800, h: 1.35)),
                const SizedBox(height: 8),
                Text(r.intro, style: ts(14, h: 1.35)),
                const SizedBox(height: 8),
                Wrap(spacing: 9, runSpacing: 8, children: [
                  Tag('${r.minutes} min'),
                  Tag(r.level, bg: Pal.peach),
                  Tag(r.third, bg: Pal.greenBox),
                ]),
                const SizedBox(height: 21),
                Text('Dans ton panier',
                    style: ts(19, w: FontWeight.w800, h: 1.35)),
                const SizedBox(height: 12),
                _servingsRow(),
                const SizedBox(height: 12),
                if (have.isNotEmpty) _haveBox(r, have),
                if (miss.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _missBox(r, miss),
                  const SizedBox(height: 12),
                  PillButton(
                    _added
                        ? 'Ajouté à ta liste !'
                        : 'Ajouter le manquant aux courses',
                    icon: _added ? Icons.check_rounded : null,
                    imageAsset:
                        _added ? null : 'assets/images/panier.png',
                    soft: true,
                    onTap: _added
                        ? null
                        : () {
                            s.addMissing(r, _servings);
                            setState(() => _added = true);
                            toast(context, 'C’est dans ta petite liste !');
                          },
                  ),
                ],
                const SizedBox(height: 21),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Et hop, en cuisine !',
                        style: ts(19, w: FontWeight.w800, h: 1.35)),
                    Text('${r.steps.length} étapes',
                        style: ts(14,
                            w: FontWeight.w800, color: Pal.primary, h: 1.35)),
                  ],
                ),
                const SizedBox(height: 17),
                for (var i = 0; i < r.steps.length; i++) _step(i, r.steps[i]),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Pal.peach,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(children: [
                    const MijouMascot(size: 48),
                    const SizedBox(width: 10),
                    Expanded(child: Text(r.tip, style: ts(14, h: 1.35))),
                  ]),
                ),
                const SizedBox(height: 21),
                PillButton(
                  'Lancer le mode cuisine',
                  icon: Icons.restaurant_rounded,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (_) => CookingPage(recipe: r)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _servingsRow() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Pour $_servings ${plural(_servings, 'personne', 'personnes')}',
              style: ts(14, h: 1.35)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Pal.card,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: Pal.border),
            ),
            child: Row(children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed:
                    _servings > 1 ? () => setState(() => _servings--) : null,
                icon: const Icon(Icons.remove_rounded, size: 16),
                color: Pal.ink,
              ),
              Text('$_servings', style: ts(14, w: FontWeight.w800, h: 1.35)),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed:
                    _servings < 12 ? () => setState(() => _servings++) : null,
                icon: const Icon(Icons.add_rounded, size: 16),
                color: Pal.ink,
              ),
            ]),
          ),
        ],
      );

  Widget _haveBox(Recipe r, List<Ing> have) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Pal.greenBox,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DÉJÀ DANS TON FRIGO · ${have.length}/${r.ings.length}',
                style:
                    ts(14, w: FontWeight.w800, color: Pal.greenDeep, h: 1.35)),
            const SizedBox(height: 11),
            for (final i in have)
              Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: Row(children: [
                  const Icon(Icons.check_rounded,
                      size: 15, color: Pal.greenDeep),
                  const SizedBox(width: 8),
                  Expanded(child: Text(i.name, style: ts(14, h: 1.35))),
                  Text(fmtQty(i, _servings),
                      style: ts(14, w: FontWeight.w800, h: 1.35)),
                ]),
              ),
          ],
        ),
      );

  Widget _missBox(Recipe r, List<Ing> miss) => Column(
        children: [
          for (final i in miss)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Pal.pale,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(children: [
                const Icon(Icons.add_rounded, size: 17, color: Pal.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(i.name, style: ts(14, w: FontWeight.w800, h: 1.35)),
                      const SizedBox(height: 2),
                      Text(
                          miss.length == 1
                              ? 'Le seul petit manquant'
                              : 'Un petit manquant',
                          style: ts(14, color: Pal.primary, h: 1.35)),
                    ],
                  ),
                ),
                Text(fmtQty(i, _servings),
                    style: ts(14, w: FontWeight.w800, h: 1.35)),
              ]),
            ),
        ],
      );

  Widget _step(int i, CookStep st) => Padding(
        padding: const EdgeInsets.only(bottom: 17),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration:
                  const BoxDecoration(color: Pal.pale, shape: BoxShape.circle),
              child: Text('${i + 1}',
                  style:
                      ts(14, w: FontWeight.w800, color: Pal.primary, h: 1.35)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(st.title, style: ts(15, w: FontWeight.w800, h: 1.35)),
                  const SizedBox(height: 4),
                  Text(st.text, style: ts(14, h: 1.35)),
                ],
              ),
            ),
          ],
        ),
      );
}

// ───────────────────────── Mode cuisine ─────────────────────────

class CookingPage extends StatefulWidget {
  final Recipe recipe;
  const CookingPage({super.key, required this.recipe});

  @override
  State<CookingPage> createState() => _CookingPageState();
}

class _CookingPageState extends State<CookingPage> {
  static const _moods = [
    'C’est parti !',
    'Ça sent déjà bon…',
    'Presque là…',
    'À table !'
  ];

  int _step = 0;
  int _left = 0;
  bool _running = false;
  bool _sound = true;
  Timer? _timer;

  CookStep get _cur => widget.recipe.steps[_step];

  @override
  void initState() {
    super.initState();
    _left = _cur.minutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goTo(int i) {
    _timer?.cancel();
    setState(() {
      _step = i;
      _running = false;
      _left = _cur.minutes * 60;
    });
  }

  void _toggleTimer() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
      return;
    }
    if (_left <= 0) _left = _cur.minutes * 60;
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_left <= 1) {
        t.cancel();
        setState(() {
          _left = 0;
          _running = false;
        });
        toast(context, 'Ding ! Le minuteur est terminé');
      } else {
        setState(() => _left--);
      }
    });
  }

  void _next() {
    if (_step < widget.recipe.steps.length - 1) {
      _goTo(_step + 1);
    } else {
      _timer?.cancel();
      toast(context, 'Bravo $kUserName, c’est prêt !');
      Navigator.of(context).pop();
    }
  }

  String get _clock {
    final m = (_left ~/ 60).toString().padLeft(2, '0');
    final s = (_left % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.recipe;
    final last = _step == r.steps.length - 1;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      _timer?.cancel();
                      Navigator.of(context).pop();
                    },
                    child: const Icon(Icons.close_rounded,
                        size: 22, color: Pal.primary),
                  ),
                  Text(r.name, style: ts(14, w: FontWeight.w800, h: 1.35)),
                  GestureDetector(
                    onTap: () => setState(() => _sound = !_sound),
                    child: Icon(
                      _sound
                          ? Icons.volume_up_rounded
                          : Icons.volume_off_rounded,
                      size: 22,
                      color: Pal.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ÉTAPE ${_step + 1} SUR ${r.steps.length}',
                      style: ts(14,
                          w: FontWeight.w800, color: Pal.primary, h: 1.35)),
                  Text(_moods[_step % _moods.length],
                      style: ts(14, w: FontWeight.w600, h: 1.35)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (var i = 0; i < r.steps.length; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: 6,
                        decoration: BoxDecoration(
                          color: i <= _step ? Pal.primary : Pal.pale,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              Text(_cur.title, style: ts(36, w: FontWeight.w800, h: 1.25)),
              const SizedBox(height: 14),
              Text(_cur.cook, style: ts(22, w: FontWeight.w600, h: 1.35)),
              const SizedBox(height: 14),
              Row(children: [
                const MijouMascot(size: 72),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Pal.pale,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Pal.border),
                    ),
                    child: Text(_cur.tip,
                        style: ts(14, w: FontWeight.w600, h: 1.35)),
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              _timerCard(),
              const SizedBox(height: 24),
              Row(children: [
                RoundBtn(
                  size: 54,
                  color: Colors.white,
                  outlined: true,
                  icon: Icons.arrow_back_rounded,
                  onTap: _step == 0 ? null : () => _goTo(_step - 1),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PillButton(
                    last ? 'C’est prêt !' : 'Étape suivante',
                    icon: last
                        ? Icons.check_rounded
                        : Icons.arrow_forward_rounded,
                    onTap: _next,
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timerCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Pal.timerBg,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Pal.border),
          boxShadow: shadowTimer,
        ),
        child: Column(
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.timer_outlined, size: 18, color: Pal.primary),
              const SizedBox(width: 7),
              Text('LE PETIT MINUTEUR',
                  style:
                      ts(14, w: FontWeight.w800, color: Pal.primary, h: 1.35)),
            ]),
            const SizedBox(height: 12),
            Text(_clock, style: ts(54, w: FontWeight.w800, h: 1.35)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RoundBtn(
                  size: 46,
                  iconSize: 19,
                  color: Colors.white,
                  outlined: true,
                  icon: Icons.replay_rounded,
                  onTap: () {
                    _timer?.cancel();
                    setState(() {
                      _running = false;
                      _left = _cur.minutes * 60;
                    });
                  },
                ),
                const SizedBox(width: 12),
                Material(
                  color: Pal.primary,
                  shape: const StadiumBorder(),
                  child: InkWell(
                    customBorder: const StadiumBorder(),
                    onTap: _toggleTimer,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        height: 46,
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(
                              _running
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 19,
                              color: Colors.white),
                          const SizedBox(width: 9),
                          Text(_running ? 'Pause' : 'Démarrer',
                              style: ts(14,
                                  w: FontWeight.w800,
                                  color: Colors.white,
                                  h: 1.35)),
                        ]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => setState(() => _left += 60),
                  child: Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Pal.border),
                    ),
                    child: Text('+1 min',
                        style: ts(11, w: FontWeight.w800, h: 1.2)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/theme.dart';
import '../../../../core/utils/widgets.dart';
import '../../../recipes/data/models/data.dart';
import '../../../recipes/presentation/controllers/app_state.dart';
import '../../../recipes/presentation/pages/recipe_page.dart';
import '../widgets/pantry_category_section.dart';

// ───────────────────────── Mon frigo ─────────────────────────

class FridgePage extends StatefulWidget {
  const FridgePage({super.key});

  @override
  State<FridgePage> createState() => _FridgePageState();
}

class _FridgePageState extends State<FridgePage> {
  final _ctrl = TextEditingController();

  void _add() {
    final v = _ctrl.text.trim();
    if (v.isEmpty) return;
    context.read<AppState>().addPantry(v);
    _ctrl.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: context.read<AppState>(),
        builder: (context, _) {
          final s = context.read<AppState>();
          final n = s.pantry.length;
          return Column(
            children: [
              PageHeader(
                title: 'Mon petit frigo',
                subtitle:
                    '$n ${plural(n, 'ingrédient', 'ingrédients')}, déjà plein d’idées.',
                trailing: RoundBtn(
                  icon: Icons.qr_code_scanner_rounded,
                  onTap: () => toast(context, 'Bientôt : scanne ton frigo !'),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 22),
                  children: [
                    _search(),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Pal.pale,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          const MijouMascot(size: 48),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Même trois fois rien, ça compte.\nTon frigo a du talent !',
                              style: ts(14, h: 1.35),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    for (var c = 0; c < kCats.length; c++)
                      PantryCategorySection(
                        category: kCats[c],
                        chipColor: c < 3 ? Pal.pale : Pal.chip,
                      ),
                    const SizedBox(height: 4),
                    PillButton(
                      'Trouve-moi une recette',
                      icon: Icons.auto_awesome_rounded,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                            builder: (_) => const ResultsPage()),
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text('Tu peux modifier les quantités à tout moment.',
                        style: ts(14, color: Pal.inkSoft, h: 1.35)),
                  ],
                ),
              ),
            ],
          );
        },
      );

  Widget _search() => Container(
        height: 50,
        padding: const EdgeInsets.only(left: 15, right: 6),
        decoration: BoxDecoration(
          color: Pal.field,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: Pal.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, size: 20, color: Pal.inkSoft),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _ctrl,
                onSubmitted: (_) => _add(),
                textInputAction: TextInputAction.done,
                style: ts(14),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  hintText: 'Ajouter un ingrédient…',
                  hintStyle: ts(14, color: Pal.inkSoft),
                ),
              ),
            ),
            IconButton(
              onPressed: _add,
              icon: const Icon(Icons.add_rounded, color: Pal.primary),
            ),
          ],
        ),
      );
}

// ───────────────────────── Résultats ─────────────────────────

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  static const _filters = [
    'Rapide',
    'Healthy',
    'Enfants',
    'Économique',
    'Végétarien'
  ];
  String? _filter = 'Rapide';

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          bottom: false,
          child: ListenableBuilder(
            listenable: context.read<AppState>(),
            builder: (context, _) {
              final s = context.read<AppState>();
              final list = kRecipes
                  .where((r) =>
                      _filter == null ||
                      r.tags.contains(_filter!.toLowerCase()))
                  .toList();
              return Column(
                children: [
                  PageHeader(
                    title: 'Ça mijote déjà !',
                    subtitle:
                        '${list.length} ${plural(list.length, 'idée', 'idées')} avec tes ${s.pantry.length} ingrédients',
                    leading: RoundBtn(
                      size: 44,
                      icon: Icons.arrow_back_rounded,
                      outlined: true,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    trailing: RoundBtn(
                      size: 44,
                      color: Pal.border,
                      icon: Icons.tune_rounded,
                      onTap: () => setState(() => _filter = null),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
                      children: [
                        Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: [
                            for (final f in _filters)
                              FilterChipPill(
                                f,
                                selected: _filter == f,
                                onTap: () => setState(
                                    () => _filter = _filter == f ? null : f),
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(children: [
                          const MijouMascot(size: 42),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Un petit manque ? On le glisse\ndans ta liste de courses.',
                              style: ts(14, h: 1.35),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 18),
                        if (list.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(
                                'Aucune idée pour ce filtre, essaie-en un autre !',
                                style: ts(14, color: Pal.inkSoft)),
                          ),
                        for (var i = 0; i < list.length; i++)
                          _card(context, list[i], i),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: MijouNavBar(
          index: 1,
          onTap: (i) {
            context.read<AppState>().setTab(i);
            Navigator.of(context).popUntil((r) => r.isFirst);
          },
        ),
      );

  Widget _card(BuildContext context, Recipe r, int i) {
    final s = context.read<AppState>();
    final miss = s.missing(r);
    final all = miss.isEmpty;
    final fav = s.favorites.contains(r.id);
    return GestureDetector(
      onTap: () => openRecipe(context, r),
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Pal.card,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Pal.border),
          boxShadow: shadowSoft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                PhotoBox(recipe: r, height: i == 0 ? 155 : 128),
                Positioned(
                  left: 9,
                  top: 9,
                  child: all
                      ? const Tag('Tout est dans ton frigo',
                          bg: Pal.greenBg, fg: Pal.greenInk)
                      : Tag(
                          '${s.haveCount(r)} ingrédients sur ${r.ings.length}',
                          bg: Pal.chip),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: RoundBtn(
                    size: 32,
                    iconSize: 18,
                    icon: fav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    onTap: () => s.toggleFav(r.id),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.name, style: ts(18, w: FontWeight.w800, h: 1.35)),
                      const SizedBox(height: 2),
                      Text(r.sub, style: ts(14, h: 1.35)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${r.minutes} min',
                        style: ts(14, w: FontWeight.w800, h: 1.35)),
                    Text(r.level, style: ts(14, w: FontWeight.w800, h: 1.35)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(children: [
              Icon(
                all
                    ? Icons.check_circle_outline_rounded
                    : Icons.shopping_basket_outlined,
                size: 14,
                color: all ? Pal.greenInk : Pal.inkSoft,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  all
                      ? 'Tu as tout, youpi !'
                      : 'Il te manque : ${miss.map((m) => m.miss ?? m.name.toLowerCase()).join(', ')}',
                  style: ts(14, color: all ? Pal.greenInk : Pal.ink, h: 1.35),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

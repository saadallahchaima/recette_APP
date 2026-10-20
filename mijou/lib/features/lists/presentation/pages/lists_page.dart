import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/theme.dart';
import '../../../../core/utils/widgets.dart';
import '../../../recipes/data/models/data.dart';
import '../../../recipes/presentation/controllers/app_state.dart';
import '../../../recipes/presentation/pages/recipe_page.dart';

// ───────────────────────── Favoris ─────────────────────────

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool _easyOnly = false;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: AppState.i,
        builder: (context, _) {
          final s = AppState.i;
          final favs = kRecipes.where((r) => s.favorites.contains(r.id)).toList();
          final shown = _easyOnly ? favs.where((r) => r.minutes <= 30).toList() : favs;
          return Column(
            children: [
              PageHeader(
                title: 'Mes petits chouchous',
                subtitle: 'Les bonnes idées qu’on garde au chaud.',
                trailing: RoundBtn(
                  color: Pal.pale,
                  icon: Icons.search_rounded,
                  onTap: () => toast(context, 'La recherche arrive bientôt !'),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
                  children: [
                    Wrap(spacing: 8, children: [
                      FilterChipPill('Tout · ${favs.length}',
                          selected: !_easyOnly, onTap: () => setState(() => _easyOnly = false)),
                      FilterChipPill('Les dîners faciles',
                          selected: _easyOnly, onTap: () => setState(() => _easyOnly = true)),
                    ]),
                    const SizedBox(height: 20),
                    for (var i = 0; i < shown.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: i == 0 ? _big(context, shown[i]) : _compact(context, shown[i]),
                      ),
                    _message(shown.isEmpty),
                  ],
                ),
              ),
            ],
          );
        },
      );

  String _availability(Recipe r) {
    final miss = AppState.i.missing(r);
    return miss.isEmpty
        ? 'Tu as tout, youpi !'
        : 'Il te manque : ${miss.map((m) => m.miss ?? m.name.toLowerCase()).join(', ')}';
  }

  Widget _big(BuildContext context, Recipe r) {
    final all = AppState.i.missing(r).isEmpty;
    return GestureDetector(
      onTap: () => openRecipe(context, r),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _cardDeco(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(children: [
              PhotoBox(recipe: r, height: 174),
              Positioned(
                right: 10,
                top: 10,
                child: RoundBtn(
                  size: 34,
                  iconSize: 19,
                  color: Pal.pale,
                  icon: Icons.favorite_rounded,
                  onTap: () => AppState.i.toggleFav(r.id),
                ),
              ),
            ]),
            const SizedBox(height: 11),
            Text(r.name, style: ts(19, w: FontWeight.w800, h: 1.35)),
            const SizedBox(height: 4),
            Text('${r.minutes} min · ${r.level} · Pour $kBaseServings',
                style: ts(14, color: Pal.inkSoft, h: 1.35)),
            const SizedBox(height: 4),
            Text(_availability(r),
                style: ts(14, color: all ? Pal.greenInk : Pal.primary, h: 1.35)),
          ],
        ),
      ),
    );
  }

  Widget _compact(BuildContext context, Recipe r) {
    final all = AppState.i.missing(r).isEmpty;
    return GestureDetector(
      onTap: () => openRecipe(context, r),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _cardDeco(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PhotoBox(recipe: r, height: 114, width: 104),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(r.name, style: ts(16, w: FontWeight.w800, h: 1.35)),
                      ),
                      GestureDetector(
                        onTap: () => AppState.i.toggleFav(r.id),
                        child: const Icon(Icons.favorite_rounded, size: 17, color: Pal.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text('${r.minutes} min · ${r.level} · Pour $kBaseServings',
                      style: ts(14, color: Pal.inkSoft, h: 1.35)),
                  const SizedBox(height: 7),
                  Text(_availability(r),
                      style: ts(14,
                          w: FontWeight.w800,
                          color: all ? Pal.greenInk : Pal.primary,
                          h: 1.35)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDeco() => BoxDecoration(
        color: const Color(0xFFFFF7F9),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Pal.border),
        boxShadow: shadowSoft,
      );

  Widget _message(bool empty) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7F9),
          borderRadius: BorderRadius.circular(28),
          boxShadow: shadowSoft,
        ),
        child: Row(children: [
          const MijouMascot(size: 62),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(empty ? 'Pas encore de chouchou' : 'Une idée qui te plaît ?',
                    style: ts(15, w: FontWeight.w800, h: 1.35)),
                const SizedBox(height: 4),
                Text(
                  empty
                      ? 'Touche un petit cœur sur une recette\net elle viendra ici.'
                      : 'Un petit cœur et hop,\nelle reste avec toi.',
                  style: ts(14, h: 1.35),
                ),
              ],
            ),
          ),
        ]),
      );
}

// ───────────────────────── Liste de courses ─────────────────────────

class ShoppingPage extends StatelessWidget {
  const ShoppingPage({super.key});

  Future<void> _askItem(BuildContext context) async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Pal.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text('Et autre chose ?', style: ts(19, w: FontWeight.w800)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: ts(14),
          onSubmitted: (v) => Navigator.of(ctx).pop(v),
          decoration: InputDecoration(
            hintText: 'Du pain, des yaourts…',
            hintStyle: ts(14, color: Pal.inkSoft),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Annuler', style: ts(14, w: FontWeight.w800, color: Pal.inkSoft)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text),
            child: Text('Ajouter', style: ts(14, w: FontWeight.w800, color: Pal.primary)),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (name != null) AppState.i.addCustom(name);
  }

  void _share(BuildContext context) {
    final s = AppState.i;
    final lines = s.shopping
        .where((i) => !i.checked)
        .map((i) => '- ${i.name}${i.qty.isEmpty ? '' : ' (${i.qty})'}')
        .join('\n');
    Clipboard.setData(ClipboardData(text: 'Ma petite liste Mijou :\n$lines'));
    toast(context, 'Liste copiée, colle-la où tu veux !');
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: AppState.i,
        builder: (context, _) {
          final s = AppState.i;
          final todo = s.shopping.where((i) => !i.checked).length;

          // ingrédients déjà à la maison pour les recettes de la liste
          final ids = s.shopping.map((i) => i.recipeId).whereType<String>().toSet();
          final home = <String>[];
          for (final id in ids) {
            final r = recipeById(id);
            for (final ing in r.ings.where((i) => s.has(i.key))) {
              final label = '${fmtQty(ing, kBaseServings)} ${ing.name.toLowerCase()}';
              if (!home.contains(label)) home.add(label);
            }
          }

          return Column(
            children: [
              PageHeader(
                title: 'La petite liste',
                subtitle: 'Un seul arrêt et le dîner est dans le sac.',
                trailing: RoundBtn(
                  outlined: true,
                  icon: Icons.share_rounded,
                  onTap: () => _share(context),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                        color: Pal.pale,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: shadowSoft,
                      ),
                      child: Row(children: [
                        const MijouMascot(size: 78),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                todo == 0
                                    ? 'Tout est dans le sac !'
                                    : todo == 1
                                        ? 'Juste un petit truc !'
                                        : '$todo petites choses !',
                                style: ts(20, w: FontWeight.w800, h: 1.35),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                todo == 0
                                    ? 'Rien à acheter pour le moment.\nBravo, $kUserName !'
                                    : 'Le reste est déjà chez toi.\nBien joué, ton frigo.',
                                style: ts(14, color: Pal.inkSoft, h: 1.35),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('À glisser dans le panier',
                            style: ts(19, w: FontWeight.w800, h: 1.35)),
                        Text('$todo ${plural(todo, 'article', 'articles')}',
                            style: ts(14, w: FontWeight.w800, h: 1.35)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    for (final cat in kCats) _group(cat, s),
                    GestureDetector(
                      onTap: () => _askItem(context),
                      child: Container(
                        height: 46,
                        padding: const EdgeInsets.symmetric(horizontal: 17),
                        decoration: BoxDecoration(
                          color: Pal.field,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: Pal.border),
                        ),
                        child: Row(children: [
                          const Icon(Icons.add_rounded, size: 18, color: Pal.primary),
                          const SizedBox(width: 10),
                          Text('Et autre chose pour la maison…',
                              style: ts(14, color: Pal.inkSoft, h: 1.35)),
                        ]),
                      ),
                    ),
                    if (home.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(17),
                        decoration: BoxDecoration(
                          color: Pal.cream,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Icon(Icons.check_circle_outline_rounded,
                                  size: 18, color: Pal.primary),
                              const SizedBox(width: 7),
                              Text('Pas besoin de racheter',
                                  style: ts(14, w: FontWeight.w800, h: 1.35)),
                            ]),
                            const SizedBox(height: 11),
                            Text(home.join(' · '),
                                style: ts(14, color: Pal.inkSoft, h: 1.35)),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    PillButton('Partager ma petite liste',
                        icon: Icons.share_rounded, onTap: () => _share(context)),
                    const SizedBox(height: 10),
                    Text('À deux, les courses sont encore plus légères.',
                        style: ts(14, color: Pal.inkSoft, h: 1.35)),
                  ],
                ),
              ),
            ],
          );
        },
      );

  Widget _group(Cat cat, AppState s) {
    final items = s.shopping.where((i) => i.cat == cat.name).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Pal.field,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Pal.border),
        boxShadow: shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(cat.name.toUpperCase(),
              style: ts(14, w: FontWeight.w800, color: Pal.inkSoft, h: 1.35)),
          const SizedBox(height: 13),
          for (final it in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => s.toggleShop(it),
                child: Row(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: it.checked ? Pal.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Pal.primary, width: 1.5),
                    ),
                    child: it.checked
                        ? const Icon(Icons.check_rounded, size: 17, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(it.name,
                            style: ts(17,
                                w: FontWeight.w800,
                                h: 1.35,
                                color: it.checked ? Pal.inkSoft : Pal.ink,
                                deco: it.checked ? TextDecoration.lineThrough : null)),
                        const SizedBox(height: 3),
                        Text(it.note, style: ts(14, color: Pal.inkSoft, h: 1.35)),
                      ],
                    ),
                  ),
                  if (it.qty.isNotEmpty)
                    Text(it.qty, style: ts(17, w: FontWeight.w800, h: 1.35)),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

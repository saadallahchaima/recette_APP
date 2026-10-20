import 'package:flutter/material.dart';

import 'data.dart';
import 'pages_recipe.dart';
import 'theme.dart';
import 'widgets.dart';

void openMenu(BuildContext context) => Navigator.of(context)
    .push(MaterialPageRoute<void>(builder: (_) => const MenuPage()));

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppState.i;
    return ListenableBuilder(
      listenable: s,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
        children: [
          BrandBar(onAvatar: () => openMenu(context)),
          const SizedBox(height: 18),
          Text('Coucou $kUserName,\non mange quoi ?',
              style: ts(27, w: FontWeight.w800, h: 1.35)),
          const SizedBox(height: 5),
          Text('Les bonnes idées sont déjà dans ton frigo.',
              style: ts(14, color: Pal.inkSoft, h: 1.35)),
          const SizedBox(height: 18),
          _hero(),
          const SizedBox(height: 18),
          Text('Les petits bonheurs du jour',
              style: ts(19, w: FontWeight.w800, h: 1.35)),
          const SizedBox(height: 13),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _ideaCard(context, recipeById('coquillettes'))),
              const SizedBox(width: 13),
              Expanded(child: _ideaCard(context, recipeById('galettes'))),
            ],
          ),
          const SizedBox(height: 18),
          Row(children: [
            const Icon(Icons.auto_awesome_rounded, size: 17, color: Pal.greenInk),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Fait maison, pas besoin d’en faire des tonnes.',
                  style: ts(14, color: Pal.greenInk, h: 1.35)),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _hero() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Pal.pale,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Pal.pale),
          boxShadow: shadowSoft,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Un fond de placard,\nplein de possibilités.',
                          style: ts(19, w: FontWeight.w800, h: 1.35)),
                      const SizedBox(height: 6),
                      Text('Dis-moi ce que tu as,\nje m’occupe des idées !',
                          style: ts(14, h: 1.35)),
                    ],
                  ),
                ),
                const SizedBox(width: 9),
                const MijouMascot(size: 96),
              ],
            ),
            const SizedBox(height: 16),
            Builder(
              builder: (context) => PillButton(
                'J’ajoute mes ingrédients',
                icon: Icons.add_rounded,
                onTap: () => AppState.i.tab.value = 1,
              ),
            ),
          ],
        ),
      );

  Widget _ideaCard(BuildContext context, Recipe r) => GestureDetector(
        onTap: () => openRecipe(context, r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PhotoBox(recipe: r, height: 132),
            const SizedBox(height: 8),
            Text(r.name, style: ts(16, w: FontWeight.w800, h: 1.35)),
            const SizedBox(height: 8),
            Text('${r.minutes} min · ${r.level}',
                style: ts(14, color: Pal.inkSoft, h: 1.35)),
          ],
        ),
      );
}

/// « État menu ouvert » : s'ouvre depuis l'avatar.
class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, String, VoidCallback)>[
      (Icons.person_outline_rounded, 'Mon profil', 'Mes préférences, mes recettes',
          () => toast(context, 'Ton profil arrive bientôt !')),
      (Icons.shield_outlined, 'Préférences', 'Allergies, régimes, goûts',
          () => toast(context, 'Les préférences arrivent bientôt !')),
      (Icons.group_outlined, 'Ma famille', 'Partager les courses et les idées',
          () => toast(context, 'Ta famille arrive bientôt !')),
      (Icons.favorite_border_rounded, 'Recettes préférées',
          'Mes meilleures idées en un coup d’œil', () {
        AppState.i.tab.value = 2;
        Navigator.of(context).pop();
      }),
      (Icons.help_outline_rounded, 'Aide', 'Conseils, minuteur et bonnes pratiques',
          () => toast(context, 'Mijou est là si tu as un souci !')),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
          children: [
            BrandBar(onAvatar: () => Navigator.of(context).pop()),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Pal.pale,
                borderRadius: BorderRadius.circular(28),
                boxShadow: shadowSoft,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Coucou $kUserName !',
                            style: ts(19, w: FontWeight.w800, h: 1.35)),
                        const SizedBox(height: 6),
                        Text('Mijou te fait un petit coucou.',
                            style: ts(14, h: 1.35)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 9),
                  const MijouMascot(size: 96, wink: true),
                ],
              ),
            ),
            const SizedBox(height: 26),
            for (final it in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Pal.pale,
                  borderRadius: BorderRadius.circular(26),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(26),
                    onTap: it.$4,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Pal.chip,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(it.$1, size: 22, color: Pal.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(it.$2, style: ts(16, w: FontWeight.w800, h: 1.35)),
                                const SizedBox(height: 2),
                                Text(it.$3,
                                    style: ts(14, color: Pal.inkSoft, h: 1.35)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: MijouNavBar(
        index: 0,
        onTap: (i) {
          AppState.i.tab.value = i;
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
